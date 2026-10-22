#!/bin/bash
set -e

echo "=== VALIXIS Portal: Vercel Web Build Started ==="

# 1. Generate or prepare .env file
if [ ! -f .env ]; then
  echo "[Vercel Build] Initializing .env from .env.example..."
  cp .env.example .env
fi

# 2. Inject Vercel Environment Variables into .env if defined
if [ -n "$SUPABASE_URL" ]; then
  echo "[Vercel Build] Injecting SUPABASE_URL from Vercel environment..."
  sed -i "s|SUPABASE_URL=.*|SUPABASE_URL=$SUPABASE_URL|g" .env || echo "SUPABASE_URL=$SUPABASE_URL" >> .env
fi

if [ -n "$SUPABASE_ANON_KEY" ]; then
  echo "[Vercel Build] Injecting SUPABASE_ANON_KEY from Vercel environment..."
  sed -i "s|SUPABASE_ANON_KEY=.*|SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY|g" .env || echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env
fi

if [ -n "$WHATSAPP_SERVICE_URL" ]; then
  echo "[Vercel Build] Injecting WHATSAPP_SERVICE_URL from Vercel environment..."
  sed -i "s|WHATSAPP_SERVICE_URL=.*|WHATSAPP_SERVICE_URL=$WHATSAPP_SERVICE_URL|g" .env || echo "WHATSAPP_SERVICE_URL=$WHATSAPP_SERVICE_URL" >> .env
fi

# 3. Install Flutter SDK if not present in Vercel build cache
if [ ! -d "$HOME/flutter" ]; then
  echo "[Vercel Build] Cloning Flutter SDK (stable channel)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
fi

# 4. Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"

echo "[Vercel Build] Flutter SDK version:"
flutter --version

# 5. Install dependencies
echo "[Vercel Build] Installing pub dependencies..."
flutter pub get

# 6. Build Flutter Web release bundle
echo "[Vercel Build] Building Flutter Web bundle..."
flutter build web --release

echo "=== VALIXIS Portal: Vercel Web Build Succeeded ==="
