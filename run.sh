#!/bin/bash
set -e
swift build
cp .build/debug/Nottiq Nottiq.app/Contents/MacOS/Nottiq
open Nottiq.app
