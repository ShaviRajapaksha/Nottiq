<div align="center">

# Nottiq

**A personal macOS sticky-notes app — a work in progress, built and tested for my own use.**

</div>

## About

Nottiq is a native macOS sticky-notes application I'm building for myself as a personal project. It is not published, not distributed, and not intended for download or general use at this time. Everything here reflects my own ongoing experimentation and testing.

## Status

Work in progress. This app is being developed and tested locally by me. It may change significantly, break, or be restructured at any point. There are no releases, no installers, and no public downloads.

## What it does (so far)

- Create notes as independent floating windows on the desktop
- Keep notes visible across spaces and above other windows
- Multiple pastel colors, per-note window levels (normal / always on top / always on back)
- Automatic JSON persistence and window-position restore on relaunch
- Menu-bar-only mode, with a drag-to-Applications DMG build script for personal testing

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