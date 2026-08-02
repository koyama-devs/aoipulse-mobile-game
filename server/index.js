import cors from "cors";
import express from "express";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { customAlphabet } from "nanoid";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DATA_PATH = path.join(__dirname, "data.json");
const PORT = Number(process.env.PORT || 8787);
const roomCode = customAlphabet("ABCDEFGHJKLMNPQRSTUVWXYZ23456789", 6);
const idGen = customAlphabet("abcdefghijklmnopqrstuvwxyz0123456789", 16);

const MODES = new Set(["classic", "sprint", "ultra", "daily", "adventure", "norotate"]);
const ATTACK_TYPES = new Set(["garbage", "banana", "bomb"]);
const ATTACK_COOLDOWN_MS = 6000;
const ATTACK_MAX_PER_MATCH = 12;
const EVENT_CAP = 40;
const BOARD_KEYS = ["sprint", "ultra", "classic", "adventure", "norotate"];

function emptyLeaderboards() {
  return { daily: {}, sprint: [], ultra: [], classic: [], adventure: [], norotate: [] };
}

function nextEventId(room) {
  room.nextEventId = (room.nextEventId || 0) + 1;
  return room.nextEventId;
}

function eventsSince(room, sinceId) {
  const sid = Math.max(0, Number(sinceId) || 0);
  const list = Array.isArray(room.events) ? room.events : [];
  return list.filter((e) => (e.id || 0) > sid);
}

function loadDb() {
  if (!fs.existsSync(DATA_PATH)) {
    return { players: {}, rooms: {}, leaderboards: emptyLeaderboards() };
  }
  try {
    const raw = JSON.parse(fs.readFileSync(DATA_PATH, "utf8"));
    raw.leaderboards = raw.leaderboards || {};
    for (const k of BOARD_KEYS) {
      if (!Array.isArray(raw.leaderboards[k])) raw.leaderboards[k] = [];
    }
    if (!raw.leaderboards.daily || typeof raw.leaderboards.daily !== "object") {
      raw.leaderboards.daily = {};
    }
    return raw;
  } catch {
    return { players: {}, rooms: {}, leaderboards: emptyLeaderboards() };
  }
}

function saveDb() {
  fs.writeFileSync(DATA_PATH, JSON.stringify(db, null, 2));
}

function todayKey(d = new Date()) {
  return d.toISOString().slice(0, 10);
}

function dailySeed(day = todayKey()) {
  let h = 2166136261;
  for (let i = 0; i < day.length; i++) {
    h ^= day.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  return h >>> 0;
}

function publicPlayer(p) {
  return { id: p.id, name: p.name, xp: p.xp || 0, createdAt: p.createdAt };
}

function publicRoom(room) {
  return {
    code: room.code,
    mode: room.mode,
    hostId: room.hostId,
    status: room.status,
    seed: room.seed,
    startedAt: room.startedAt,
    createdAt: room.createdAt,
    players: room.players.map((p) => ({
      id: p.id,
      name: p.name,
      ready: !!p.ready,
      finished: !!p.finished,
      score: p.score ?? 0,
      lines: p.lines ?? 0,
      timeMs: p.timeMs ?? 0,
      stage: p.stage ?? 1,
      result: p.result ?? null,
    })),
  };
}

function compareAdventure(a, b) {
  const sa = a.stage || 1;
  const sb = b.stage || 1;
  if (sb !== sa) return sb - sa;
  const sc = (b.score || 0) - (a.score || 0);
  if (sc !== 0) return sc;
  return (a.timeMs || 1e12) - (b.timeMs || 1e12);
}

function rankRoomPlayers(room) {
  const finished = room.players.filter((p) => p.finished);
  if (room.mode === "sprint") {
    // Lower time is better; incomplete last.
    return [...finished].sort((a, b) => (a.timeMs || 1e12) - (b.timeMs || 1e12));
  }
  if (room.mode === "adventure") {
    return [...finished].sort(compareAdventure);
  }
  // Higher score wins (ultra/classic/daily)
  return [...finished].sort((a, b) => (b.score || 0) - (a.score || 0));
}

function pushLeaderboard(list, entry, limit = 50) {
  const next = [...list.filter((e) => e.playerId !== entry.playerId), entry];
  next.sort((a, b) => {
    if (entry.board === "sprint") return (a.timeMs || 1e12) - (b.timeMs || 1e12);
    if (entry.board === "adventure") return compareAdventure(a, b);
    return (b.score || 0) - (a.score || 0);
  });
  return next.slice(0, limit);
}

let db = loadDb();

// Cleanup old rooms periodically (6h)
setInterval(() => {
  const cutoff = Date.now() - 6 * 60 * 60 * 1000;
  let changed = false;
  for (const code of Object.keys(db.rooms)) {
    if ((db.rooms[code].createdAt || 0) < cutoff) {
      delete db.rooms[code];
      changed = true;
    }
  }
  if (changed) saveDb();
}, 10 * 60 * 1000);

const app = express();
app.use(cors());
app.use(express.json({ limit: "256kb" }));

app.get("/api/health", (_req, res) => {
  res.json({ ok: true, service: "aoipulse", time: Date.now(), dailySeed: dailySeed() });
});

app.post("/api/player/register", (req, res) => {
  const name = String(req.body?.name || "").trim().slice(0, 16) || "Player";
  const existingId = String(req.body?.playerId || "");
  if (existingId && db.players[existingId]) {
    db.players[existingId].name = name;
    saveDb();
    return res.json({ player: publicPlayer(db.players[existingId]) });
  }
  const id = idGen();
  db.players[id] = { id, name, xp: 0, createdAt: Date.now() };
  saveDb();
  res.json({ player: publicPlayer(db.players[id]) });
});

app.post("/api/rooms", (req, res) => {
  const playerId = String(req.body?.playerId || "");
  const mode = String(req.body?.mode || "sprint");
  const player = db.players[playerId];
  if (!player) return res.status(400).json({ error: "Unknown player" });
  if (!MODES.has(mode) || mode === "daily") {
    return res.status(400).json({ error: "Room mode must be classic, sprint, ultra, adventure, or norotate" });
  }
  let code = roomCode();
  while (db.rooms[code]) code = roomCode();
  const room = {
    code,
    mode,
    hostId: playerId,
    status: "lobby",
    seed: 0,
    startedAt: 0,
    createdAt: Date.now(),
    players: [{ id: playerId, name: player.name, ready: true, finished: false }],
  };
  db.rooms[code] = room;
  saveDb();
  res.json({ room: publicRoom(room) });
});

app.post("/api/rooms/:code/join", (req, res) => {
  const code = String(req.params.code || "").toUpperCase();
  const playerId = String(req.body?.playerId || "");
  const room = db.rooms[code];
  const player = db.players[playerId];
  if (!room) return res.status(404).json({ error: "Room not found" });
  if (!player) return res.status(400).json({ error: "Unknown player" });
  if (room.status !== "lobby") return res.status(400).json({ error: "Match already started" });
  if (room.players.length >= 8) return res.status(400).json({ error: "Room full (max 8)" });
  if (!room.players.find((p) => p.id === playerId)) {
    room.players.push({ id: playerId, name: player.name, ready: false, finished: false });
    saveDb();
  }
  res.json({ room: publicRoom(room) });
});

app.post("/api/rooms/:code/ready", (req, res) => {
  const code = String(req.params.code || "").toUpperCase();
  const playerId = String(req.body?.playerId || "");
  const ready = !!req.body?.ready;
  const room = db.rooms[code];
  if (!room) return res.status(404).json({ error: "Room not found" });
  const p = room.players.find((x) => x.id === playerId);
  if (!p) return res.status(400).json({ error: "Not in room" });
  p.ready = ready;
  saveDb();
  res.json({ room: publicRoom(room) });
});

app.post("/api/rooms/:code/start", (req, res) => {
  const code = String(req.params.code || "").toUpperCase();
  const playerId = String(req.body?.playerId || "");
  const room = db.rooms[code];
  if (!room) return res.status(404).json({ error: "Room not found" });
  if (room.hostId !== playerId) return res.status(403).json({ error: "Only host can start" });
  if (room.status !== "lobby") return res.status(400).json({ error: "Already started" });
  if (room.players.length < 1) return res.status(400).json({ error: "Need players" });
  room.status = "playing";
  room.seed = (Math.random() * 0xffffffff) >>> 0;
  room.startedAt = Date.now();
  room.events = [];
  room.nextEventId = 0;
  for (const p of room.players) {
    p.finished = false;
    p.score = 0;
    p.lines = 0;
    p.timeMs = 0;
    p.stage = 1;
    p.result = null;
    p.lastAttackAt = 0;
    p.attackUses = 0;
  }
  saveDb();
  res.json({ room: publicRoom(room), events: [] });
});

app.get("/api/rooms/:code", (req, res) => {
  const code = String(req.params.code || "").toUpperCase();
  const room = db.rooms[code];
  if (!room) return res.status(404).json({ error: "Room not found" });
  const since = req.query?.since;
  const ranked = rankRoomPlayers(room).map((p, i) => ({
    rank: i + 1,
    id: p.id,
    name: p.name,
    score: p.score || 0,
    lines: p.lines || 0,
    timeMs: p.timeMs || 0,
    stage: p.stage || 1,
  }));
  res.json({
    room: publicRoom(room),
    ranking: ranked,
    events: eventsSince(room, since),
  });
});

app.post("/api/rooms/:code/attack", (req, res) => {
  const code = String(req.params.code || "").toUpperCase();
  const playerId = String(req.body?.playerId || "");
  const type = String(req.body?.type || "");
  const room = db.rooms[code];
  if (!room) return res.status(404).json({ error: "Room not found" });
  if (room.mode !== "adventure") return res.status(400).json({ error: "Attacks only in adventure rooms" });
  if (room.status !== "playing") return res.status(400).json({ error: "Match not playing" });
  if (!ATTACK_TYPES.has(type)) return res.status(400).json({ error: "Invalid attack type" });
  const p = room.players.find((x) => x.id === playerId);
  if (!p) return res.status(400).json({ error: "Not in room" });
  if (p.finished) return res.status(400).json({ error: "Already finished" });

  const now = Date.now();
  const uses = p.attackUses || 0;
  if (uses >= ATTACK_MAX_PER_MATCH) {
    return res.status(400).json({ error: "Attack limit reached" });
  }
  if ((p.lastAttackAt || 0) + ATTACK_COOLDOWN_MS > now) {
    return res.status(400).json({ error: "Attack cooldown" });
  }

  const targets = room.players.filter((x) => x.id !== playerId && !x.finished);
  if (targets.length === 0) {
    return res.status(400).json({ error: "No opponents" });
  }

  if (!Array.isArray(room.events)) room.events = [];
  const ev = {
    id: nextEventId(room),
    fromId: playerId,
    fromName: p.name,
    type,
    at: now,
  };
  room.events.push(ev);
  if (room.events.length > EVENT_CAP) {
    room.events = room.events.slice(-EVENT_CAP);
  }
  p.lastAttackAt = now;
  p.attackUses = uses + 1;
  saveDb();

  res.json({
    room: publicRoom(room),
    event: ev,
    events: eventsSince(room, Math.max(0, ev.id - 1)),
    attackUses: p.attackUses,
    cooldownMs: ATTACK_COOLDOWN_MS,
  });
});

app.post("/api/rooms/:code/finish", (req, res) => {
  const code = String(req.params.code || "").toUpperCase();
  const playerId = String(req.body?.playerId || "");
  const room = db.rooms[code];
  const player = db.players[playerId];
  if (!room) return res.status(404).json({ error: "Room not found" });
  if (!player) return res.status(400).json({ error: "Unknown player" });
  const p = room.players.find((x) => x.id === playerId);
  if (!p) return res.status(400).json({ error: "Not in room" });
  if (room.status !== "playing" && room.status !== "finished") {
    return res.status(400).json({ error: "Match not playing" });
  }

  const score = Math.max(0, Math.min(10_000_000, Number(req.body?.score) || 0));
  const lines = Math.max(0, Math.min(1000, Number(req.body?.lines) || 0));
  let timeMs = Math.max(0, Math.min(3_600_000, Number(req.body?.timeMs) || 0));
  if (!timeMs && room.startedAt) timeMs = Date.now() - room.startedAt;
  const stage = Math.max(1, Math.min(999, Number(req.body?.stage) || 1));

  p.finished = true;
  p.score = score;
  p.lines = lines;
  p.timeMs = timeMs;
  p.stage = stage;
  p.result = { score, lines, timeMs, stage, at: Date.now() };

  // XP reward
  player.xp = (player.xp || 0) + Math.max(10, Math.floor(score / 100) + lines * 2 + stage * 5);

  // Global boards
  const entry = {
    playerId,
    name: player.name,
    score,
    lines,
    timeMs,
    stage,
    mode: room.mode,
    board: room.mode,
    at: Date.now(),
  };
  if (!db.leaderboards[room.mode]) db.leaderboards[room.mode] = [];
  db.leaderboards[room.mode] = pushLeaderboard(db.leaderboards[room.mode], entry);

  if (room.players.every((x) => x.finished)) room.status = "finished";
  saveDb();

  const ranked = rankRoomPlayers(room).map((rp, i) => ({
    rank: i + 1,
    id: rp.id,
    name: rp.name,
    score: rp.score || 0,
    lines: rp.lines || 0,
    timeMs: rp.timeMs || 0,
    stage: rp.stage || 1,
  }));
  res.json({ room: publicRoom(room), ranking: ranked, player: publicPlayer(player) });
});

app.get("/api/leaderboard/:board", (req, res) => {
  const board = String(req.params.board || "daily");
  if (board === "daily") {
    const day = todayKey();
    const map = db.leaderboards.daily[day] || {};
    const list = Object.values(map).sort((a, b) => (b.score || 0) - (a.score || 0)).slice(0, 50);
    return res.json({ board, day, seed: dailySeed(day), entries: list });
  }
  const list = (db.leaderboards[board] || []).slice(0, 50);
  res.json({ board, entries: list });
});

app.post("/api/daily/submit", (req, res) => {
  const playerId = String(req.body?.playerId || "");
  const player = db.players[playerId];
  if (!player) return res.status(400).json({ error: "Unknown player" });
  const day = todayKey();
  const seed = dailySeed(day);
  const clientSeed = Number(req.body?.seed);
  if (clientSeed && clientSeed !== seed) {
    return res.status(400).json({ error: "Stale daily seed" });
  }
  const score = Math.max(0, Math.min(10_000_000, Number(req.body?.score) || 0));
  const lines = Math.max(0, Math.min(1000, Number(req.body?.lines) || 0));
  const timeMs = Math.max(0, Math.min(3_600_000, Number(req.body?.timeMs) || 0));
  if (!db.leaderboards.daily[day]) db.leaderboards.daily[day] = {};
  const prev = db.leaderboards.daily[day][playerId];
  if (!prev || score > (prev.score || 0)) {
    db.leaderboards.daily[day][playerId] = {
      playerId,
      name: player.name,
      score,
      lines,
      timeMs,
      at: Date.now(),
    };
  }
  player.xp = (player.xp || 0) + Math.max(10, Math.floor(score / 120) + lines);
  saveDb();
  const entries = Object.values(db.leaderboards.daily[day])
    .sort((a, b) => (b.score || 0) - (a.score || 0))
    .slice(0, 50);
  res.json({ day, seed, entries, player: publicPlayer(player) });
});

app.get("/api/daily", (_req, res) => {
  const day = todayKey();
  res.json({ day, seed: dailySeed(day) });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`AOIPulse server on http://0.0.0.0:${PORT}`);
});
