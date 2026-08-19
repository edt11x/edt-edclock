#!/bin/bash
# build-deb.sh - Build an amd64 .deb for Ubuntu and Debian.
#
# The package declares the runtime libraries apt must install (fontconfig,
# Wayland/X11, OpenGL). Install with:
#   sudo apt install ./dist/edt-edclock-slint_<ver>_amd64.deb
#
# A binary built on Fedora (glibc 2.39+) runs on Ubuntu 24.04+ and Debian 13+.
# Older releases should build from source: ./setup.sh && ./install.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=packaging/linux-deps.sh
. "$PROJECT_DIR/packaging/linux-deps.sh"

APP_NAME="edt-edclock-slint"
VERSION="$(sed -n 's/^version = "\(.*\)"/\1/p' "$PROJECT_DIR/Cargo.toml" | head -n1)"
case "${1:-}" in
    -h|--help)
        cat <<EOF
edt-edclock-slint build-deb ${VERSION}
Build an amd64 .deb for Ubuntu and Debian (runtime Depends included).

Usage: $0 [OPTIONS]

Options:
  -h, --help     Show this help and exit
  -V, --version  Show version and exit

Install: sudo apt install ./dist/${APP_NAME}_<ver>_amd64.deb
EOF
        exit 0
        ;;
    -V|--version)
        echo "edt-edclock-slint ${VERSION}"
        exit 0
        ;;
esac
ARCH="amd64"
MAINTAINER="Edward Thompson <edt11x@gmail.com>"
HOMEPAGE="https://github.com/edt11x/edt-edclock"

DIST_DIR="$PROJECT_DIR/dist"
STAGE="$PROJECT_DIR/target/deb-root"
PKG_DIR="$STAGE/${APP_NAME}_${VERSION}_${ARCH}"
DEBIAN_DIR="$PKG_DIR/DEBIAN"
DATA_ROOT="$PKG_DIR"

if [ "$(uname -m)" != "x86_64" ]; then
    echo "This script currently packages amd64 (x86_64) only." >&2
    exit 1
fi

BINARY_SRC="$PROJECT_DIR/target/release/$APP_NAME"
if [ ! -x "$BINARY_SRC" ]; then
    echo "==> Release binary missing; compiling..."
    FAMILY="$(detect_os_family)"
    if [ "$FAMILY" = debian ] || [ "$FAMILY" = fedora ]; then
        ensure_system_packages all
    fi
    ensure_rust
    if [ -x "$HOME/.cargo/bin/cargo" ]; then
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
    (cd "$PROJECT_DIR" && cargo build --release)
fi

rm -rf "$STAGE"
mkdir -p "$DEBIAN_DIR" \
    "$DATA_ROOT/usr/bin" \
    "$DATA_ROOT/usr/share/applications" \
    "$DATA_ROOT/usr/share/doc/$APP_NAME"

echo "==> Staging files..."
install -m 0755 "$BINARY_SRC" "$DATA_ROOT/usr/bin/$APP_NAME"
if have_cmd strip; then
    strip --strip-unneeded "$DATA_ROOT/usr/bin/$APP_NAME" || true
fi
install -m 0644 "$PROJECT_DIR/packaging/edt-edclock-slint.desktop" \
    "$DATA_ROOT/usr/share/applications/${APP_NAME}.desktop"

cat > "$DATA_ROOT/usr/share/doc/$APP_NAME/copyright" <<EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: edt-edclock-slint
Source: $HOMEPAGE

Files: *
Copyright: 2026 Edward Thompson <edt11x@gmail.com>
License: see-source
 The application sources live in the edt-edclock repository.
 Slint is licensed separately (GPL-3.0-only OR Slint royalty-free / commercial).
EOF

{
    echo "edt-edclock-slint ($VERSION) unstable; urgency=low"
    echo
    echo "  * Native Slint/Rust clock and calendar package."
    echo
    echo " -- $MAINTAINER  $(date -Ru)"
} > "$DATA_ROOT/usr/share/doc/$APP_NAME/changelog"
gzip -n -9 "$DATA_ROOT/usr/share/doc/$APP_NAME/changelog"

# Depends: libc SONAME plus libraries the binary dlopens at runtime.
glibc_min="2.35"
if have_cmd objdump; then
    detected="$(objdump -T "$DATA_ROOT/usr/bin/$APP_NAME" 2>/dev/null \
        | grep -o 'GLIBC_[0-9.]*' | sed 's/GLIBC_//' | sort -uV | tail -n1 || true)"
    if [ -n "${detected:-}" ]; then
        glibc_min="$detected"
    fi
fi

RUNTIME_DEPS="$(debian_runtime_packages | paste -sd, - | sed 's/,/, /g')"
DEPENDS="libc6 (>= $glibc_min), $RUNTIME_DEPS"

INSTALLED_SIZE="$(du -sk "$DATA_ROOT/usr" | awk '{print $1}')"

cat > "$DEBIAN_DIR/control" <<EOF
Package: $APP_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: $MAINTAINER
Homepage: $HOMEPAGE
Installed-Size: $INSTALLED_SIZE
Depends: $DEPENDS
Recommends: fonts-dejavu-core | fonts-liberation
Description: Ultra-compact digital clock and calendar
 Native Linux clock and calendar application built with Rust and Slint.
 Shows a digital clock, an interactive month calendar, and home-disk usage.
EOF

cat > "$DEBIAN_DIR/postinst" <<'EOF'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications 2>/dev/null || true
fi
exit 0
EOF
chmod 0755 "$DEBIAN_DIR/postinst"

# md5sums of installed files (paths relative to /)
(
    cd "$DATA_ROOT"
    find usr -type f -print0 | sort -z | xargs -0 md5sum
) > "$DEBIAN_DIR/md5sums"

echo "==> Building .deb..."
mkdir -p "$DIST_DIR"
DEB_PATH="$DIST_DIR/${APP_NAME}_${VERSION}_${ARCH}.deb"

# Prefer dpkg-deb; fall back to ar+tar so this works on Fedora too.
if have_cmd dpkg-deb; then
    dpkg-deb --root-owner-group --build "$PKG_DIR" "$DEB_PATH"
else
    echo "dpkg-deb not found; assembling the archive with ar/tar..."
    WORK="$STAGE/ar-work"
    rm -rf "$WORK"
    mkdir -p "$WORK"
    printf '2.0\n' > "$WORK/debian-binary"

    # control.tar.gz (files at archive root)
    tar --owner=0 --group=0 --numeric-owner -C "$DEBIAN_DIR" -czf "$WORK/control.tar.gz" .
    # data.tar.gz (usr/...)
    tar --owner=0 --group=0 --numeric-owner -C "$DATA_ROOT" -czf "$WORK/data.tar.gz" usr

    rm -f "$DEB_PATH"
    # Member order is part of the .deb spec: debian-binary, control, data.
    (
        cd "$WORK"
        ar r "$DEB_PATH" debian-binary control.tar.gz data.tar.gz
    )
fi

echo
echo "Built $DEB_PATH"
ls -lh "$DEB_PATH"
echo
echo "Install on Ubuntu or Debian with:"
echo "  sudo apt install ./dist/${APP_NAME}_${VERSION}_${ARCH}.deb"
echo "apt will pull in the runtime libraries listed in Depends (glibc >= $glibc_min)."
if version_ge "$glibc_min" "2.39"; then
    echo
    echo "Note: this binary needs glibc $glibc_min, which means Ubuntu 24.04+"
    echo "and Debian 13 (trixie)+. On older releases, build on that machine:"
    echo "  ./setup.sh && ./install.sh"
fi
