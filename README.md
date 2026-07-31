# AOIPulse

A modern falling-blocks puzzle for mobile — **Godot 4.3** — by **Aoitex**.

Offline modes · online room races · daily challenge · leaderboards  
Ready to export for **Google Play** / **App Store**.

---

## What's new in this build

- **Modes:** Classic, Sprint (40 lines), Ultra (2:00), Daily Challenge
- **Online Race:** create/join rooms (up to 8), shared seed, live ranking
- **Leaderboards:** Daily / Sprint / Ultra
- **Juice:** combos, particles, screen shake, themes unlock with XP
- **Profile:** display name + custom server URL

---

## Play locally

1. Godot 4.3+ → Import `project.godot` → **F5** (or `run.bat`)
2. For online features, start the API:

```bash
cd server
npm install
npm start
```

Default server: `http://127.0.0.1:8787` (change in **Settings**).

### Online quick test
1. Device/PC A: Online Race → Create Sprint Room → note code  
2. Device/PC B: same Wi‑Fi/server URL → Join Room  
3. Host taps **Start Match** → race → rankings

> Android emulator → PC server: use `http://10.0.2.2:8787`  
> Phones on LAN: use your PC LAN IP, e.g. `http://192.168.x.x:8787`

---

## Project layout

```
aoipulse/
  project.godot
  online_config.json
  scripts/Main.gd
  scripts/OnlineClient.gd
  server/                 # Node rooms + leaderboards API
  assets/icons|store|audio
  STORE_LISTING.md
  privacy.html
```

See `server/README.md` for deploy notes and `STORE_LISTING.md` for store copy.

---

## Export

Android package / iOS bundle: `com.aoitex.aoipulse`  
Internet permission enabled for online races.

Do **not** use the trademark “Tetris” in store listings.
