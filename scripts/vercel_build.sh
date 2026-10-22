#!/bin/bash
set -e

echo "=== VALIXIS Portal: Vercel Web Build Started ==="

# 1. Ensure .env exists so Flutter asset bundler doesn't fail
if [ ! -f .env ]; then
  echo "[Vercel Build] Generating .env from .env.example..."
  cp .env.example .env
fi

# 2. Install Flutter SDK if not present in Vercel build cache
if [ ! -d "$HOME/flutter" ]; then
  echo "[Vercel Build] Cloning Flutter SDK (stable channel)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
fi

# 3. Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"

echo "[Vercel Build] Flutter SDK version:"
flutter --version

# 4. Install dependencies
echo "[Vercel Build] Installing pub dependencies..."
flutter pub get

# 5. Build Flutter Web release bundle
echo "[Vercel Build] Building Flutter Web bundle..."
flutter build web --release

echo "=== VALIXIS Portal: Vercel Web Build Succeeded ==="
