"""Generate lightweight procedural WAV SFX + loop music for AOIPulse."""
from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "assets" / "audio"
SAMPLE_RATE = 22050


def write_wav(path: Path, samples: list[float], rate: int = SAMPLE_RATE) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(rate)
        frames = bytearray()
        for s in samples:
            v = max(-1.0, min(1.0, s))
            frames += struct.pack("<h", int(v * 32767))
        w.writeframes(frames)


def env(i: int, n: int, attack: float = 0.01, release: float = 0.2) -> float:
    t = i / max(n - 1, 1)
    a = min(1.0, t / max(attack, 1e-6))
    r = min(1.0, (1.0 - t) / max(release, 1e-6))
    return a * r


def tone(freq: float, dur: float, vol: float = 0.35, kind: str = "sine") -> list[float]:
    n = int(SAMPLE_RATE * dur)
    out: list[float] = []
    for i in range(n):
        t = i / SAMPLE_RATE
        phase = 2 * math.pi * freq * t
        if kind == "square":
            s = 1.0 if math.sin(phase) >= 0 else -1.0
        elif kind == "triangle":
            s = 2.0 * abs(2.0 * ((t * freq) % 1.0) - 1.0) - 1.0
        else:
            s = math.sin(phase)
        out.append(s * vol * env(i, n, 0.01, 0.25))
    return out


def chirp(f0: float, f1: float, dur: float, vol: float = 0.3) -> list[float]:
    n = int(SAMPLE_RATE * dur)
    out: list[float] = []
    for i in range(n):
        t = i / SAMPLE_RATE
        f = f0 + (f1 - f0) * (i / max(n - 1, 1))
        s = math.sin(2 * math.pi * f * t)
        out.append(s * vol * env(i, n, 0.005, 0.3))
    return out


def noise_burst(dur: float, vol: float = 0.2) -> list[float]:
    # Deterministic pseudo-noise (no import random) for reproducible assets.
    n = int(SAMPLE_RATE * dur)
    out: list[float] = []
    x = 1234567
    for i in range(n):
        x = (1103515245 * x + 12345) & 0x7FFFFFFF
        s = (x / 0x7FFFFFFF) * 2.0 - 1.0
        out.append(s * vol * env(i, n, 0.001, 0.5))
    return out


def mix(*parts: list[float]) -> list[float]:
    length = max((len(p) for p in parts), default=0)
    out = [0.0] * length
    for p in parts:
        for i, v in enumerate(p):
            out[i] += v
    peak = max((abs(v) for v in out), default=1.0) or 1.0
    if peak > 1.0:
        out = [v / peak for v in out]
    return out


def concat(*parts: list[float]) -> list[float]:
    out: list[float] = []
    for p in parts:
        out.extend(p)
    return out


def silence(dur: float) -> list[float]:
    return [0.0] * int(SAMPLE_RATE * dur)


def make_music(dur: float = 16.0) -> list[float]:
    # Soft looping arpeggio: Am / F / C / G style tones.
    notes = [220.0, 261.63, 329.63, 392.0, 329.63, 261.63]
    step = 0.25
    out: list[float] = []
    t = 0.0
    idx = 0
    while t < dur:
        f = notes[idx % len(notes)]
        # Chord pad + arp pluck.
        pad = tone(f / 2, step, 0.08, "triangle")
        pluck = tone(f, step * 0.7, 0.16, "sine")
        chunk = mix(pad, pluck)
        # Ensure exact step length.
        target = int(SAMPLE_RATE * step)
        if len(chunk) < target:
            chunk.extend([0.0] * (target - len(chunk)))
        else:
            chunk = chunk[:target]
        out.extend(chunk)
        t += step
        idx += 1
    return out


def main() -> None:
    assets = {
        "move.wav": tone(520, 0.04, 0.18, "square"),
        "rotate.wav": chirp(420, 720, 0.07, 0.22),
        "soft.wav": tone(180, 0.035, 0.12, "triangle"),
        "lock.wav": mix(tone(140, 0.08, 0.22, "triangle"), noise_burst(0.05, 0.08)),
        "hard.wav": mix(chirp(300, 80, 0.12, 0.28), noise_burst(0.08, 0.1)),
        "clear.wav": concat(
            tone(523.25, 0.08, 0.25),
            tone(659.25, 0.08, 0.25),
            tone(783.99, 0.12, 0.28),
        ),
        "tetris.wav": concat(
            tone(523.25, 0.07, 0.25),
            tone(659.25, 0.07, 0.25),
            tone(783.99, 0.07, 0.28),
            tone(1046.5, 0.18, 0.3),
        ),
        "gameover.wav": concat(
            tone(392, 0.18, 0.25, "triangle"),
            tone(311, 0.22, 0.25, "triangle"),
            tone(233, 0.35, 0.28, "triangle"),
        ),
        "ui.wav": tone(660, 0.05, 0.18, "sine"),
        "music.wav": make_music(16.0),
    }
    for name, samples in assets.items():
        path = ROOT / name
        write_wav(path, samples)
        print(f"wrote {path} ({len(samples)} samples)")


if __name__ == "__main__":
    main()
