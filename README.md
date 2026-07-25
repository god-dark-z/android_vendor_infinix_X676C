# Proprietary vendor tree for the Infinix NOTE 12 2023 (X676C)

Proprietary blobs and generated build files for the Infinix NOTE 12 2023
(`X676C`, MediaTek Helio G99 / MT6789), extracted from the stock XOS
**Android 13** firmware (`X676C-GL`, build `240313V1027`).

Mounts at `vendor/infinix/X676C`. Branch: `main-X676C`.

## Layout

| File / dir              | Purpose                                                             |
| ----------------------- | :------------------------------------------------------------------ |
| `proprietary/`          | Stock blobs (vendor, system_ext, odm vintf manifests, mcRegistry TAs) |
| `Android.bp`            | Soong modules: app imports and vintf manifest fragment prebuilts     |
| `X676C-vendor.mk`       | `PRODUCT_COPY_FILES` / `PRODUCT_PACKAGES` for all blobs              |
| `BoardConfigVendor.mk`  | Board-level vendor config, included from the device tree             |

Inherited automatically by the [device tree](https://github.com/dark-z-666/android_device_infinix_X676C)
(`X676C-vendor.mk` from `device.mk`, `BoardConfigVendor.mk` from `BoardConfig.mk`).

## Maintenance notes (read before regenerating!)

`Android.bp` and `X676C-vendor.mk` are **generated** files that carry manual
fixes for Android 16:

- `android.hardware.wifi.hostapd.xml`, `android.hardware.wifi.supplicant.xml`
  and `gnss-default.xml` prebuilts were **removed** - these modules are built
  from source and duplicate definitions break the build.
- The odm vintf manifests (`manifest_dsds.xml` etc.) were **removed from**
  `PRODUCT_COPY_FILES`: Android 16 forbids VINTF metadata there. The DSDS
  manifest is declared via `ODM_MANIFEST_FILES` in the device tree instead.
- Do not comment entries inside continuation blocks with `#` - in GNU make
  this silently discards the rest of the list.

Re-running `extract-files.py` will regenerate these files and **resurrect the
removed entries** - reapply the fixes (or fix `proprietary-files.txt`) after
any re-extraction.

The [TWRP/OrangeFox trees](https://github.com/dark-z-666/twrp-device_infinix_Infinix-X676C)
fetch their decryption blobs (Trustonic mcRegistry TAs, gatekeeper/keymint
binaries) directly from this repo via raw URLs - keep those paths stable.

Maintained by **Night_Stalker** ([dark-z-666](https://github.com/dark-z-666))
