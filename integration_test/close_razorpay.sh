#!/usr/bin/env bash
# Host helper for app_journey_test: when Razorpay's checkout window is on the
# phone, press Back (and confirm "cancel" if Razorpay asks), so the test can
# check the app's "Payment cancelled" card. Usage: close_razorpay.sh <device>
ADB=${ADB:-adb}; D="$1"; end=$((SECONDS+900))
while [ $SECONDS -lt $end ]; do
  if "$ADB" -s "$D" shell dumpsys activity activities 2>/dev/null | grep -m1 topResumedActivity | grep -q com.razorpay.CheckoutActivity; then
    sleep 5
    "$ADB" -s "$D" shell input keyevent KEYCODE_BACK; sleep 3
    # Razorpay may ask "cancel payment?": tap a Yes / Cancel button if shown.
    MSYS_NO_PATHCONV=1 "$ADB" -s "$D" shell uiautomator dump /sdcard/rzp.xml >/dev/null 2>&1
    b=$(MSYS_NO_PATHCONV=1 "$ADB" -s "$D" shell cat /sdcard/rzp.xml 2>/dev/null | grep -oiE 'text="(yes[^"]*|cancel payment|exit)"[^>]*bounds="\[[0-9]+,[0-9]+\]\[[0-9]+,[0-9]+\]"' | head -1 | grep -oE '\[[0-9]+,[0-9]+\]\[[0-9]+,[0-9]+\]')
    if [ -n "$b" ]; then
      set -- $(echo "$b" | tr '[],' '   '); "$ADB" -s "$D" shell input tap $(( ($1+$3)/2 )) $(( ($2+$4)/2 ))
    fi
    echo "closed razorpay at $SECONDS s"; sleep 8
  fi
  sleep 2
done
