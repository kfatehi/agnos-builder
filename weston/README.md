# weston upstream build

This was an attempt to get upstream weston working per this issue https://github.com/commaai/agnos-builder/issues/16

Feel free to reuse any of this if it happens to be useful. I am giving up on the bounty as it's exceeded my resources, time and abilities to pursue it.

## Usage

Build the system per the readme in the root directory first. This will ensure you have the prerequisite files and docker images that we'll use to build weston.

Run `./build.sh` to compile weston in a docker and extract it out to disk.

Run `./install.sh` to copy (over SSH) to your tici for testing. It won't actually install it.

And probably using "weston-prefix" instead of "/usr" as the prefix will have other problems and should be fixed, but this was just a quick test to see how difficult it would be and what problems we'd run into after the build and install process succeeds.

## Testing

For testing purposes I ended up doing the following (after build and install) on the tici itself over SSH:

```
sudo mount -o rw,remount /
```

I copied the weston files into /weston-prefix (just to keep the paths consistent).

I also used `ldconfig` to allow it to find the shared libs (libweston)

I created this file based on the systemd service for weston:

```
#!/bin/bash
XDG_RUNTIME_DIR=/var/tmp/weston
echo 0 > /sys/class/backlight/panel0-backlight/brightness
sleep 0.1
echo 1023 > /sys/class/backlight/panel0-backlight/brightness
/usr/comma/modetest -M msm_drm -s 26@111:1080x2160-60
/usr/comma/modetest -M msm_drm -s 26@111:1080x2160-60
sleep 1
mkdir -p $XDG_RUNTIME_DIR
chown -R comma: $XDG_RUNTIME_DIR
mkdir -p /data/misc/display
echo 0 > /data/misc/display/sdm_dbg_cfg.txt
LD_LIBRARY_PATH=/weston-prefix/lib/aarch64-linux-gnu
/weston-prefix/bin/weston --idle-time=0 --tty=1 --config=/usr/comma/weston.ini #-B drm-backend.so
```

I would run this normally to see what errors I would get, and they are the same I posted below.

The errors below are from the actual service file (extracted using journalctl after a reboot) after copying /weston-prefix into /usr just to see what happens prior to writing this note indicating that I am giving up on this and reflashing back to stock.

## Conclusion

See the log below. Based on my understanding of the error below, it appears that weston is looking for `/usr/lib/dri/msm_drm_dri.so` which does not exist on the tici or in the build. I'll post the output files that would be created after you run `build.sh` right after the weston startup logs below:

```
Nov 21 17:07:46 tici systemd[1]: weston.service: Main process exited, code=dumped, status=11/SEGV
Nov 21 17:07:46 tici systemd[1]: weston.service: Failed with result 'core-dump'.
Nov 21 17:07:47 tici systemd[1]: weston.service: Scheduled restart job, restart counter is at 41.
Nov 21 17:07:47 tici systemd[1]: Stopped Weston.
Nov 21 17:07:47 tici systemd[1]: Started Weston.
Nov 21 17:07:51 tici bash[49445]: setting mode 1080x2160-60Hz@XR24 on connectors 26, crtc 111
Nov 21 17:07:52 tici bash[49454]: setting mode 1080x2160-60Hz@XR24 on connectors 26, crtc 111
Nov 21 17:07:53 tici bash[49399]: Date: 2021-11-21 PST
Nov 21 17:07:53 tici bash[49399]: [17:07:53.738] weston 9.0.90
Nov 21 17:07:53 tici bash[49399]:                https://wayland.freedesktop.org
Nov 21 17:07:53 tici bash[49399]:                Bug reports to: https://gitlab.freedesktop.org/wayland/weston/issues/
Nov 21 17:07:53 tici bash[49399]:                Build: 9.0.0-435-g29d81c0d
Nov 21 17:07:53 tici bash[49399]: [17:07:53.739] Command line: /usr/bin/weston --idle-time=0 --tty=1 --config=/usr/comma/weston.ini
Nov 21 17:07:53 tici bash[49399]: [17:07:53.739] OS: Linux, 4.9.103+, #1 SMP PREEMPT Fri Nov 19 20:03:05 PST 2021, aarch64
Nov 21 17:07:53 tici bash[49399]: [17:07:53.739] Flight recorder: enabled
Nov 21 17:07:53 tici bash[49399]: [17:07:53.739] warning: XDG_RUNTIME_DIR "/var/tmp/weston" is not configured
Nov 21 17:07:53 tici bash[49399]: correctly.  Unix access mode must be 0700 (current mode is 0700),
Nov 21 17:07:53 tici bash[49399]: and must be owned by the user UID 0 (current owner is UID 1000).
Nov 21 17:07:53 tici bash[49399]: Refer to your distribution on how to get it, or
Nov 21 17:07:53 tici bash[49399]: http://www.freedesktop.org/wiki/Specifications/basedir-spec
Nov 21 17:07:53 tici bash[49399]: on how to implement it.
Nov 21 17:07:53 tici bash[49399]: [17:07:53.739] Using config file '/usr/comma/weston.ini'
Nov 21 17:07:53 tici bash[49399]: [17:07:53.739] Output repaint window is 7 ms maximum.
Nov 21 17:07:53 tici bash[49399]: [17:07:53.739] Loading module '/weston-prefix/lib/aarch64-linux-gnu/libweston-10/drm-backend.so'
Nov 21 17:07:53 tici bash[49399]: [17:07:53.742] initializing drm backend
Nov 21 17:07:53 tici bash[49399]: [17:07:53.742] Trying logind launcher...
Nov 21 17:07:53 tici bash[49399]: [17:07:53.742] logind: cannot find systemd session for uid: 0 -61
Nov 21 17:07:53 tici bash[49399]: [17:07:53.742] logind: cannot setup systemd-logind helper error: (No data available), using legacy fallback
Nov 21 17:07:53 tici bash[49399]: [17:07:53.742] Trying weston_launch launcher...
Nov 21 17:07:53 tici bash[49399]: [17:07:53.742] could not get launcher fd from env
Nov 21 17:07:53 tici bash[49399]: [17:07:53.742] Trying direct launcher...
Nov 21 17:07:53 tici bash[49399]: [17:07:53.742] /dev/tty1 is already in graphics mode, is another display server running?
Nov 21 17:07:53 tici bash[49399]: [17:07:53.746] using /dev/dri/card0
Nov 21 17:07:53 tici bash[49399]: [17:07:53.747] DRM: does not support atomic modesetting
Nov 21 17:07:53 tici bash[49399]: [17:07:53.747] DRM: supports GBM modifiers
Nov 21 17:07:53 tici bash[49399]: [17:07:53.747] DRM: does not support picture aspect ratio
Nov 21 17:07:53 tici bash[49399]: [17:07:53.747] Loading module '/weston-prefix/lib/aarch64-linux-gnu/libweston-10/gl-renderer.so'
Nov 21 17:07:53 tici bash[49399]: MESA-LOADER: failed to open msm_drm: /usr/lib/dri/msm_drm_dri.so: cannot open shared object file: No such file or directory (search paths /usr/lib/aarch64-linux-gnu/dri:\$${ORIGIN}/dri:/usr/lib/dri)
Nov 21 17:07:53 tici bash[49399]: failed to load driver: msm_drm
Nov 21 17:07:53 tici bash[49399]: [17:07:53.806] EGL client extensions: EGL_EXT_client_extensions
Nov 21 17:07:53 tici bash[49399]:                EGL_KHR_client_get_all_proc_addresses EGL_EXT_platform_base
Nov 21 17:07:53 tici bash[49399]:                EGL_KHR_platform_android EGL_KHR_platform_wayland
Nov 21 17:07:53 tici bash[49399]:                EGL_KHR_platform_gbm
```

## Files generated

If you run build.sh the following files are generated:

```
weston-builder-fs/weston-prefix/libexec/weston-desktop-shell
weston-builder-fs/weston-prefix/libexec/weston-keyboard
weston-builder-fs/weston-prefix/libexec/weston-ivi-shell-user-interface
weston-builder-fs/weston-prefix/libexec/weston-simple-im
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/libweston-desktop-10.so.0.0.0
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/pkgconfig/libweston-desktop-10.pc
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/pkgconfig/weston.pc
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/pkgconfig/libweston-10.pc
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/weston/screen-share.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/weston/cms-colord.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/weston/hmi-controller.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/weston/kiosk-shell.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/weston/fullscreen-shell.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/weston/cms-static.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/weston/libexec_weston.so.0.0.0
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/weston/desktop-shell.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/weston/ivi-shell.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/weston/systemd-notify.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/libweston-10/headless-backend.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/libweston-10/drm-backend.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/libweston-10/color-lcms.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/libweston-10/xwayland.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/libweston-10/fbdev-backend.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/libweston-10/wayland-backend.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/libweston-10/rdp-backend.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/libweston-10/gl-renderer.so
weston-builder-fs/weston-prefix/lib/aarch64-linux-gnu/libweston-10.so.0.0.0
weston-builder-fs/weston-prefix/share/wayland-sessions/weston.desktop
weston-builder-fs/weston-prefix/share/pkgconfig/libweston-10-protocols.pc
weston-builder-fs/weston-prefix/share/weston/home.png
weston-builder-fs/weston-prefix/share/weston/icon_window.png
weston-builder-fs/weston-prefix/share/weston/icon_flower.png
weston-builder-fs/weston-prefix/share/weston/icon_ivi_flower.png
weston-builder-fs/weston-prefix/share/weston/panel.png
weston-builder-fs/weston-prefix/share/weston/sign_minimize.png
weston-builder-fs/weston-prefix/share/weston/terminal.png
weston-builder-fs/weston-prefix/share/weston/icon_ivi_simple-egl.png
weston-builder-fs/weston-prefix/share/weston/icon_ivi_clickdot.png
weston-builder-fs/weston-prefix/share/weston/background.png
weston-builder-fs/weston-prefix/share/weston/icon_editor.png
weston-builder-fs/weston-prefix/share/weston/icon_ivi_simple-shm.png
weston-builder-fs/weston-prefix/share/weston/pattern.png
weston-builder-fs/weston-prefix/share/weston/wayland.png
weston-builder-fs/weston-prefix/share/weston/sign_close.png
weston-builder-fs/weston-prefix/share/weston/wayland.svg
weston-builder-fs/weston-prefix/share/weston/tiling.png
weston-builder-fs/weston-prefix/share/weston/fullscreen.png
weston-builder-fs/weston-prefix/share/weston/sign_maximize.png
weston-builder-fs/weston-prefix/share/weston/icon_ivi_smoke.png
weston-builder-fs/weston-prefix/share/weston/border.png
weston-builder-fs/weston-prefix/share/weston/random.png
weston-builder-fs/weston-prefix/share/weston/icon_terminal.png
weston-builder-fs/weston-prefix/share/weston/sidebyside.png
weston-builder-fs/weston-prefix/share/libweston-10/protocols/weston-direct-display.xml
weston-builder-fs/weston-prefix/share/libweston-10/protocols/weston-debug.xml
weston-builder-fs/weston-prefix/share/man/man5/weston.ini.5
weston-builder-fs/weston-prefix/share/man/man1/weston.1
weston-builder-fs/weston-prefix/share/man/man1/weston-debug.1
weston-builder-fs/weston-prefix/share/man/man7/weston-bindings.7
weston-builder-fs/weston-prefix/share/man/man7/weston-rdp.7
weston-builder-fs/weston-prefix/share/man/man7/weston-drm.7
weston-builder-fs/weston-prefix/include/weston/weston.h
weston-builder-fs/weston-prefix/include/weston/ivi-layout-export.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/version.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/windowed-output-api.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/weston-log.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/backend-fbdev.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/remoting-plugin.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/pipewire-plugin.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/xwayland-api.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/backend-rdp.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/config-parser.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/zalloc.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/backend-headless.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/backend-wayland.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/libweston.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/plugin-registry.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/backend-drm.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston/matrix.h
weston-builder-fs/weston-prefix/include/libweston-10/libweston-desktop/libweston-desktop.h
weston-builder-fs/weston-prefix/bin/weston-stacking
weston-builder-fs/weston-prefix/bin/weston-resizor
weston-builder-fs/weston-prefix/bin/weston-simple-damage
weston-builder-fs/weston-prefix/bin/weston-debug
weston-builder-fs/weston-prefix/bin/weston-content_protection
weston-builder-fs/weston-prefix/bin/weston-smoke
weston-builder-fs/weston-prefix/bin/weston-presentation-shm
weston-builder-fs/weston-prefix/bin/weston-transformed
weston-builder-fs/weston-prefix/bin/weston-subsurfaces
weston-builder-fs/weston-prefix/bin/weston-launch
weston-builder-fs/weston-prefix/bin/weston-touch-calibrator
weston-builder-fs/weston-prefix/bin/weston-info
weston-builder-fs/weston-prefix/bin/weston-simple-egl
weston-builder-fs/weston-prefix/bin/weston-eventdemo
weston-builder-fs/weston-prefix/bin/weston-flower
weston-builder-fs/weston-prefix/bin/wcap-decode
weston-builder-fs/weston-prefix/bin/weston-editor
weston-builder-fs/weston-prefix/bin/weston-simple-shm
weston-builder-fs/weston-prefix/bin/weston-simple-touch
weston-builder-fs/weston-prefix/bin/weston-clickdot
weston-builder-fs/weston-prefix/bin/weston-calibrator
weston-builder-fs/weston-prefix/bin/weston-screenshooter
weston-builder-fs/weston-prefix/bin/weston-confine
weston-builder-fs/weston-prefix/bin/weston
weston-builder-fs/weston-prefix/bin/weston-simple-dmabuf-egl
weston-builder-fs/weston-prefix/bin/weston-simple-dmabuf-v4l
weston-builder-fs/weston-prefix/bin/weston-image
weston-builder-fs/weston-prefix/bin/weston-scaler
weston-builder-fs/weston-prefix/bin/weston-fullscreen
weston-builder-fs/weston-prefix/bin/weston-multi-resource
weston-builder-fs/weston-prefix/bin/weston-terminal
weston-builder-fs/weston-prefix/bin/weston-dnd
weston-builder-fs/weston-prefix/bin/weston-cliptest
```