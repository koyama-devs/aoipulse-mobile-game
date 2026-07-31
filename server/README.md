# AOIPulse Online Server

Lightweight Node API for rooms, races, and leaderboards.

## Run locally

```bash
cd server
npm install
npm start
```

Server: `http://127.0.0.1:8787`

In the game: **Settings → Server URL** (default already points here) → SAVE PROFILE.

## Flow

1. Players register a display name
2. Host creates a **Sprint** or **Ultra** room → share 6-letter code
3. Friends join → Ready → Host starts
4. Everyone plays the **same seed**
5. Results submit → live room ranking + global boards

## Deploy

Any Node host works (Railway, Render, Fly.io, VPS):

```bash
npm install
npm start
```

Set `PORT` if needed. Then put your public HTTPS URL into `online_config.json` / Settings.

## Endpoints

- `GET /api/health`
- `POST /api/player/register`
- `POST /api/rooms`
- `POST /api/rooms/:code/join|ready|start|finish`
- `GET /api/rooms/:code`
- `GET /api/leaderboard/:board` (`daily|sprint|ultra|classic`)
- `GET /api/daily` · `POST /api/daily/submit`
