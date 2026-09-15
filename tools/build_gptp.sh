#!/usr/bin/env bash

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKG_DIR="$ROOT/packages"
BUILD_DIR="$ROOT/build"

if [ -z "$1" ]; then
    echo "Usage: build_gptp.sh <package>"
    exit 1
fi

pkg="$1"
pkg_path="$PKG_DIR/$pkg"

if [ ! -d "$pkg_path" ]; then
    echo "[-] Package '$pkg' not found in $PKG_DIR"
    exit 1
fi

version="1.0"
if [ -f "$pkg_path/.PKGINFO" ]; then
    ver=$(grep '^pkgver' "$pkg_path/.PKGINFO" | sed 's/pkgver = //' | head -1)
    if [ -n "$ver" ]; then
        version="$ver"
    fi
fi

mkdir -p "$BUILD_DIR"

archive="$BUILD_DIR/${pkg}-${version}.gptp"

echo "[*] Building .gptp package"
echo "[*] Package: $pkg"
echo "[*] Version: $version"
echo "[*] Source:  $pkg_path"
echo "[*] Output:  $archive"
echo ""

tar -czf "$archive" -C "$PKG_DIR" "$pkg"

echo "[+] Successfully created: $archive"
