#!/bin/bash
#
# fix-blobs.sh - repair the non-text blobs in this vendor tree that a plain
# git clone / raw fetch cannot represent correctly. Run ONCE locally, then
# commit & push:
#
#     bash fix-blobs.sh
#     git add -A && git commit -m "vendor: de-symlink gatekeeper blobs" && git push
#
# Why this is needed
# ------------------
# gatekeeper.trustonic.so and gatekeeper.default.so are stored in git as
# SYMLINKS (-> libMcGatekeeper.so / libSoftGatekeeper.so). Anything that
# fetches them over raw HTTP (e.g. a recovery prepare-blobs script) receives
# the 18/20-byte link-target string instead of a real library, which makes the
# gatekeeper@1.0 HAL abort (SIGABRT loop) and FBE decryption hang at
# "Attempting to decrypt FBE for user 0". Replacing the symlinks with real
# copies makes every consumer (git, raw HTTP, tarball) get a valid ELF.

set -u
HW="proprietary/vendor/lib64/hw"

if [ ! -d "$HW" ]; then
    echo "!! Run this from the vendor repo root (expected $HW to exist)."; exit 1
fi

echo "== De-symlink gatekeeper HAL impl modules =="
for pair in "gatekeeper.trustonic.so:libMcGatekeeper.so" \
            "gatekeeper.default.so:libSoftGatekeeper.so"; do
    link="${pair%%:*}"; target="${pair##*:}"
    if [ -s "$HW/$target" ] && [ "$(head -c4 "$HW/$target" | tr -d '\0')" = "$(printf '\x7fELF')" ]; then
        rm -f "$HW/$link"
        cp "$HW/$target" "$HW/$link"
        echo "  [ok]  $link  <-  $target  ($(wc -c < "$HW/$link") bytes)"
    else
        echo "  [FAIL] $HW/$target is missing or not a real ELF - cannot rebuild $link"
    fi
done

# Optional: pull the COMPLETE Trustonic mcRegistry + TEE binaries from a
# connected device to fill in the ~23 driver TAs (fingerprint, video codecs,
# DRM/Widevine, sensors, m4u) that are missing from this tree. These are NOT
# required for FBE decryption, but are needed for those features in recovery.
# Boot the device to stock userdebug (adb root) or TWRP, then:
#     bash fix-blobs.sh --from-device
if [ "${1:-}" = "--from-device" ]; then
    echo "== Pull complete mcRegistry + TEE blobs from device =="
    adb wait-for-device || { echo "no adb device"; exit 1; }
    adb root >/dev/null 2>&1 || true
    mkdir -p proprietary/vendor/app/mcRegistry
    adb pull /vendor/app/mcRegistry/. proprietary/vendor/app/mcRegistry/ && echo "  [ok] mcRegistry synced"
fi

echo
echo "Done. Review with 'git status', then:"
echo "    git add -A && git commit -m 'vendor: de-symlink gatekeeper blobs' && git push"
