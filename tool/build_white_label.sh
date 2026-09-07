#!/usr/bin/env bash
#
# Cuts a single white-labeled Android build for one institute.
#
# This app is compiled per-institute — one build = one institute. There is
# no shared "reskin at runtime" APK: colors are baked in via --dart-define,
# the launcher icon is regenerated in-place before the build, and the app
# label/applicationId are overridden via Gradle properties. A normal
# `flutter build`/`flutter run` with none of this touched is completely
# unaffected — every override defaults to the stock Tuoora values.
#
# Usage:
#   tool/build_white_label.sh \
#     --institute-id 42 \
#     --app-name "Bright Future Academy" \
#     --package-id com.brightfuture.academy \
#     --logo /path/to/square_logo.png \
#     --primary-color "#2563EB" \
#     [--primary-color-light "#DCE9FE"] \
#     [--google-services-json /path/to/google-services.json] \
#     [--format apk|appbundle]   (default: appbundle, what Play Console wants)
#
# BEFORE YOU RUN THIS, two things this script cannot do for you:
#
#   1. Firebase: google-services.json in this repo is registered to
#      com.app.tuoora only. A different --package-id needs its own Firebase
#      app (Firebase Console → Add app → Android, using that package name)
#      and its own google-services.json passed via --google-services-json,
#      or push notifications will silently fail to initialize for that build.
#
#   2. Play Console + signing: each institute needs its own Play Console
#      listing (package IDs are permanent and unique per app on the Store)
#      and a signing key for it — either a dedicated upload keystore or Play
#      App Signing. This script builds and signs with whatever
#      android/keystore.properties currently points at; swap that (or pass
#      a different one) before running if this institute needs its own key.
#
# Recommended workflow: do this on a dedicated `whitelabel/<institute-slug>`
# git branch that never merges to main, and commit the generated icon/
# manifest changes there — that keeps main clean and gives you a paper
# trail to rebuild from for that institute's next update.

set -euo pipefail

FORMAT="appbundle"
GOOGLE_SERVICES_JSON=""
PRIMARY_COLOR_LIGHT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --institute-id) INSTITUTE_ID="$2"; shift 2 ;;
    --app-name) APP_NAME="$2"; shift 2 ;;
    --package-id) PACKAGE_ID="$2"; shift 2 ;;
    --logo) LOGO_PATH="$2"; shift 2 ;;
    --primary-color) PRIMARY_COLOR="$2"; shift 2 ;;
    --primary-color-light) PRIMARY_COLOR_LIGHT="$2"; shift 2 ;;
    --google-services-json) GOOGLE_SERVICES_JSON="$2"; shift 2 ;;
    --format) FORMAT="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

for var in INSTITUTE_ID APP_NAME PACKAGE_ID LOGO_PATH PRIMARY_COLOR; do
  if [[ -z "${!var:-}" ]]; then
    flag=$(echo "$var" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    echo "Missing required --$flag (see the header of this script)" >&2
    exit 1
  fi
done

if [[ ! -f "$LOGO_PATH" ]]; then
  echo "Logo not found: $LOGO_PATH" >&2
  exit 1
fi

if [[ "$FORMAT" != "apk" && "$FORMAT" != "appbundle" ]]; then
  echo "--format must be apk or appbundle" >&2
  exit 1
fi

# Hex color -> the 0xAARRGGBB int literal --dart-define expects.
to_dart_color() {
  local hex="${1#\#}"
  hex=$(echo "$hex" | tr '[:lower:]' '[:upper:]')
  printf '0xFF%s' "$hex"
}

PRIMARY_COLOR_DART=$(to_dart_color "$PRIMARY_COLOR")
if [[ -n "$PRIMARY_COLOR_LIGHT" ]]; then
  PRIMARY_COLOR_LIGHT_DART=$(to_dart_color "$PRIMARY_COLOR_LIGHT")
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

if [[ -n "$GOOGLE_SERVICES_JSON" ]]; then
  if [[ ! -f "$GOOGLE_SERVICES_JSON" ]]; then
    echo "google-services.json not found: $GOOGLE_SERVICES_JSON" >&2
    exit 1
  fi
  cp "$GOOGLE_SERVICES_JSON" android/app/google-services.json
  echo "Installed institute-specific google-services.json."
else
  echo "WARNING: no --google-services-json given — keeping the default one" >&2
  echo "(registered to com.app.tuoora). If --package-id differs, push" >&2
  echo "notifications will not work in this build." >&2
fi

# Regenerate the launcher icon from the institute's logo without touching
# pubspec.yaml's own flutter_launcher_icons config (that config keeps
# producing the default Tuoora icon for every other build).
ICON_CONFIG=$(mktemp -t white_label_icons.XXXX.yaml)
trap 'rm -f "$ICON_CONFIG"' EXIT

cat > "$ICON_CONFIG" <<YAML
flutter_launcher_icons:
  android: true
  ios: true
  remove_alpha_ios: true
  background_color_ios: "#FFFFFF"
  image_path: "$LOGO_PATH"
  image_path_ios: "$LOGO_PATH"
  adaptive_icon_background: "$PRIMARY_COLOR"
  adaptive_icon_foreground: "$LOGO_PATH"
YAML

echo "Regenerating launcher icon from $LOGO_PATH..."
dart run flutter_launcher_icons -f "$ICON_CONFIG"

DART_DEFINES=(
  "--dart-define=INSTITUTE_ID=$INSTITUTE_ID"
  "--dart-define=BRAND_PRIMARY_COLOR=$PRIMARY_COLOR_DART"
)
if [[ -n "$PRIMARY_COLOR_LIGHT" ]]; then
  DART_DEFINES+=("--dart-define=BRAND_PRIMARY_COLOR_LIGHT=$PRIMARY_COLOR_LIGHT_DART")
fi

echo "Building $FORMAT for institute $INSTITUTE_ID ($APP_NAME, $PACKAGE_ID)..."
flutter build "$FORMAT" --release \
  "-PappId=$PACKAGE_ID" \
  "-PappLabel=$APP_NAME" \
  "${DART_DEFINES[@]}"

echo
echo "Done. Output:"
if [[ "$FORMAT" == "appbundle" ]]; then
  echo "  build/app/outputs/bundle/release/app-release.aab"
else
  echo "  build/app/outputs/flutter-apk/app-release.apk"
fi
echo
echo "Reminder: the launcher icon files under android/app/src/main/res and"
echo "ios/Runner/Assets.xcassets were just overwritten for this institute."
echo "Commit them to a dedicated whitelabel/<institute-slug> branch if you"
echo "want a record to rebuild from later — don't merge that to main."
