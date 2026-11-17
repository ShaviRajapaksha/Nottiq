# Nottiq

**A personal macOS sticky-notes app — a work in progress, built and tested for my own use.**

<img width="2880" height="1800" alt="WhatsApp Image 2026-11-18 at 00 23 08" src="https://github.com/user-attachments/assets/d1b43773-958b-4215-b53a-8b496da48302" />
<img width="2880" height="1800" alt="WhatsApp Image 2026-11-18 at 00 23 08 copy" src="https://github.com/user-attachments/assets/de3501cc-9414-425b-8b4a-9a29ed7f1533" />
<img width="1600" height="1000" alt="WhatsApp Image 2026-11-18 at 00 16 47" src="https://github.com/user-attachments/assets/e2eca133-b78c-4227-9b41-531618cbb905" />
<img width="1600" height="1000" alt="WhatsApp Image 2026-11-18 at 00 16 47 (1)" src="https://github.com/user-attachments/assets/dde0b1e6-c4b2-40b7-bd37-dfd1173d0300" />
</div>

## About

Nottiq is a native macOS sticky-notes application I'm building for myself as a personal project. It is not published, not distributed, and not intended for download or general use at this time. Everything here reflects my own ongoing experimentation and testing.

## Status

Work in progress. This app is being developed and tested locally by me. It may change significantly, break, or be restructured at any point. There are no releases, no installers, and no public downloads.

## How Nottiq differs from macOS Stickies

macOS ships with **Stickies.app**, a simple notes app. Nottiq is not a replacement or a clone — it's a different take on the same idea, built from scratch with a few deliberate design choices that Stickies doesn't make.

| | **macOS Stickies** | **Nottiq** |
|---|---|---|
| **Persistence** | Binary `.rtfd` files managed by the system | Plain, human-readable JSON — notes are portable and inspectable |
| **Window levels** | Notes always float above other windows | Per-note control: Normal, Always on Top, or **Always on Back** (sits *behind* other windows, like a wallpaper layer) |
| **Window state** | Restored by the system, no per-note control | Explicit per-note frame saving & restore, independent of Spaces |
| **App presence** | Always runs as a normal Dock app | Menu-bar-only mode; the Dock icon appears only while a note is open |
| **Color palette** | Classic 6-color sticky palette | Pastel palette tuned for the glass UI, changed per-note from a menu |
| **Visual style** | Flat classic sticky | Glass / HUD material with layered lighting and rounded corners |
| **Distribution** | Bundled with macOS | Personal source project built with Swift Package Manager; not distributed |
| **Interaction** | Drag anywhere on the note | Dedicated drag header, so editing text never moves the window |
| **Multiple spaces** | Notes follow the active Space | Notes can be pinned across **all** Spaces and shown in full-screen auxiliary mode |

In short: Stickies is a system utility. Nottiq is a personal experiment in what a lightweight, glass-styled, always-available note layer could feel like on macOS — with more explicit control over window behavior and a data format you can read and version yourself.

## What it does (so far)

- Create notes as independent floating windows on the desktop
- Keep notes visible across spaces and above (or behind) other windows
- Multiple pastel colors, per-note window levels (normal / always on top / always on back)
- Automatic JSON persistence and window-position restore on relaunch
- Menu-bar-only mode, with a drag-to-Applications DMG build script for personal testing
- Dedicated drag header so text editing and window dragging never conflict
- Glass-style UI with rounded corners and layered lighting

## What it intentionally doesn't do (yet)

- No sync, no iCloud, no cloud storage
- No rich text, attachments, or images (plain text only)
- No search across notes
- No import from Stickies
- No app icon, no signing, no notarization

## Project structure

- `Sources/Nottiq/` — all app source code (Swift + SwiftUI + AppKit)
- `Package.swift` — Swift Package Manager manifest
- `Nottiq.app/` — local development bundle used by `run.sh`
- `build-release.sh` — builds `dist/Nottiq.app` and `dist/Nottiq.dmg` for personal use
- `run.sh` — builds and launches the local development bundle

## Building for personal testing

This project is built with Swift Package Manager and requires macOS 14+ and the Xcode Command Line Tools.

```bash
# Quick build & launch (development)
./run.sh

# Release build & DMG (personal distribution only)
./build-release.sh

