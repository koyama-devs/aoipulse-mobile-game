# AOIPulse

A modern falling-blocks puzzle for mobile — **Godot 4.3** — by **Aoitex**.

Offline modes · online room races · daily challenge · leaderboards  
Ready to export for **Google Play** / **App Store**.

---

## What's new in this build

- **Modes:** Classic, **Adventure** (stage challenges), Sprint (40 lines), Ultra (2:00), Daily Challenge
- **Adventure:** bombs with countdown, treasure chests / items, rising garbage, boss waves every 5 stages
- **Online Race:** create/join rooms (up to 8), shared seed, live ranking
- **Leaderboards:** Daily / Sprint / Ultra
- **Juice:** combos, particles, screen shake, themes unlock with XP
- **Profile:** display name + custom server URL
- **UI:** Japanese menus, fixed play HUD layout, centred content column
- **Look:** Aoitex house palette (teal + coral) as the default theme

---

## Play locally

1. Godot 4.3+ → Import `project.godot` → **F5** (or `run.bat`)
2. For online features, start the API:

```bash
cd server
npm install
npm start
```

Shipped default (no setup needed): `https://aoipulse-server.onrender.com`  
(`online_config.json` + `OnlineClient.gd`). Override in **Settings** only for a custom/local server.

### Online quick test
1. Device/PC A: Online Race → Create Sprint Room → note code  
2. Device/PC B: same server (default Render URL) → Join Room  
3. Host taps **Start Match** → race → rankings

> Local server for dev: run `server/` then set Settings to `http://127.0.0.1:8787`  
> Android emulator → PC: `http://10.0.2.2:8787`  
> Same Wi‑Fi LAN: `http://192.168.x.x:8787`

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
