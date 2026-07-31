# AOIPulse

A modern falling-blocks puzzle game for mobile, built with **Godot 4.3**.
Published by **Aoitex**.

Offline gameplay • menu + settings • SFX/music • vibration • local high score  
Ready to export to **Google Play** and the **Apple App Store**.

---

## Features

- Classic 10×20 falling-blocks with 7 tetromino shapes
- 7-bag randomiser, ghost piece, wall kicks, lock delay, **hold**
- Soft drop / hard drop, score / level / lines, **combo toasts**
- Main menu (animated) + settings (SFX, music, vibration)
- Procedural audio (move / rotate / clear / tetris / game over + loop music)
- Line-clear flash + optional haptic feedback
- Touch gestures **and** on-screen buttons
- Local best-score + settings persistence
- Store icons (512 / 1024) + Android / iOS export presets (`com.aoitex.aoipulse`)
- Listing copy in `STORE_LISTING.md` (EN/VI)

---

## Controls

**Touch**
- Swipe left / right → move
- Swipe down → soft drop
- Tap playfield → rotate
- Buttons: `◀  ⟳  ▼  ⤓  ▶`   `II` pause

**Keyboard (desktop testing)**
- Arrows / `A D` move · `S` soft drop · `Up`/`X`/`W` rotate · `Z` CCW
- `Space` hard drop · `P`/`Esc` pause · `Enter` start / restart

---

## Run locally

1. Install **Godot 4.3+** (standard build): https://godotengine.org/download
2. Open Godot → **Import** → select this folder’s `project.godot`
3. Press **F5**

Regenerate audio assets (optional):

```bash
python tools/gen_audio.py
```

---

## Project layout

```
aoipulse/
  project.godot
  export_presets.cfg
  PRIVACY.md / privacy.html
  STORE_LISTING.md
  run.bat
  assets/icons/           # store + launcher icons
  assets/store/           # screenshots + feature graphic
  assets/audio/
  scenes/Main.tscn
  scripts/Main.gd
  tools/
```

---

## Export to the stores

### Android (Google Play)
1. Install Android SDK + JDK 17, download Godot export templates
2. Editor Settings → Export → Android: set SDK / keystore paths
3. Create a release keystore:
   ```
   keytool -genkey -v -keystore aoipulse.keystore -alias aoipulse \
     -keyalg RSA -keysize 2048 -validity 10000
   ```
4. Project → Export → **Android** → fill signing → export **AAB**
5. Upload `build/AOIPulse.aab` in Play Console  
   Package: `com.aoitex.aoipulse`

### iOS (App Store)
1. Needs a Mac + Xcode + Apple Developer Program
2. Project → Export → **iOS** → set Team ID / bundle id
3. Open the generated Xcode project → Archive → App Store Connect  
   Bundle ID: `com.aoitex.aoipulse`

### Store checklist
- Icon PNGs (Play 512, App Store 1024)
- Screenshots
- Short + full description
- Hosted privacy policy (use `PRIVACY.md` content)
- Content rating questionnaire

---

## License note

Gameplay is an original falling-blocks implementation. The name **AOIPulse** and
publisher **Aoitex** are yours to register on the stores. Do **not** use the
trademark “Tetris” in the store listing.
