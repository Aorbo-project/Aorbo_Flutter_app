#!/bin/bash
# Runs an integration test on a small, a middle and a large iPhone simulator,
# saving a video and screenshots of each (Codemagic only, needs a Mac).
#   bash scripts/ios_sim_test.sh integration_test/ios_launch_test.dart
set -u
TEST_FILE="$1"
OUT="$PWD/ios_test_output"
mkdir -p "$OUT"

# "<udid>|<name>" for each size: the newest iOS runtime's small/middle/large iPhone.
DEVICES=$(xcrun simctl list devices available -j | python3 -c '
import json, re, sys
runtimes = json.load(sys.stdin)["devices"]
ios = sorted((k for k in runtimes if "iOS" in k and runtimes[k]),
             key=lambda k: [int(n) for n in re.findall(r"\d+", k.split("iOS")[-1])])
phones = [d for d in runtimes[ios[-1]] if d["name"].startswith("iPhone")]
def pick(pattern):
    hits = [d for d in phones if re.search(pattern, d["name"])]
    return hits[-1] if hits else None
for d in filter(None, [pick(r"SE|\d+e\b"), pick(r"^iPhone \d+$"), pick(r"Pro Max")]):
    print(d["udid"] + "|" + d["name"])
')
echo "Devices:"
echo "$DEVICES"
[ -n "$DEVICES" ] || { echo "No iPhone simulators found"; exit 1; }

FAILED=0
while IFS='|' read -r UDID NAME; do
  DIR="$OUT/$(echo "$NAME" | tr ' ()' '---')"
  mkdir -p "$DIR"
  echo "=== $NAME ==="
  xcrun simctl boot "$UDID"
  xcrun simctl bootstatus "$UDID" -b > /dev/null
  xcrun simctl io "$UDID" recordVideo --force "$DIR/video.mp4" &
  VIDEO=$!

  flutter test "$TEST_FILE" -d "$UDID" 2>&1 < /dev/null | tee "$DIR/log.txt" | while IFS= read -r LINE; do
    echo "$LINE"
    case "$LINE" in
      *SHOT:*) xcrun simctl io "$UDID" screenshot "$DIR/${LINE##*SHOT:}.png" > /dev/null 2>&1 ;;
    esac
  done
  RESULT=${PIPESTATUS[0]}

  kill -INT "$VIDEO" 2>/dev/null
  wait "$VIDEO" 2>/dev/null
  xcrun simctl shutdown "$UDID"
  echo "=== $NAME: exit $RESULT ==="
  [ "$RESULT" -eq 0 ] || FAILED=1
done <<< "$DEVICES"

exit "$FAILED"
