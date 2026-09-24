#!/usr/bin/env bash

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ "$1" = "cf" ]; then
    input="$2"
    output="$3"
    origin="$4"

    if [ -z "$input" ] || [ ! -f "$input" ]; then
        echo "Usage: gpt cf <file> [output.gptp] [--gptpm]"
        exit 1
    fi

    if [ -z "$output" ]; then
        output="${input%.*}.gptp"
    fi

    flags=0
    if [ "$origin" = "--gptpm" ]; then
        flags=0x69
    fi

    python3 - "$input" "$output" "$flags" <<'PYTHON'
import hashlib
import pathlib
import struct
import sys

src = pathlib.Path(sys.argv[1])
dst = pathlib.Path(sys.argv[2])
flags = int(sys.argv[3], 0)

data = src.read_bytes()
name = src.name.encode("utf-8")

# GPTP v2
# Header:
#   magic
#   version
#   flags
#   header size
#   filename size
#   original size
#   SHA-256
#   reserved
# Filename
# Payload

header = struct.pack(
    ">4sBBIIQ32s15s",
    bytes.fromhex("FF 20 20 69"),
    2,
    flags,
    69 + len(name),
    len(name),
    len(data),
    hashlib.sha256(data).digest(),
    b"\x00" * 15,
)

with dst.open("wb") as f:
    f.write(header)
    f.write(name)
    f.write(data)

print(f"[+] Created: {dst}")
PYTHON

    exit $?
fi

if [ "$1" = "uf" ]; then
    input="$2"
    output="$3"

    if [ -z "$input" ] || [ ! -f "$input" ]; then
        echo "Usage: gpt uf <file.gptp> [output]"
        exit 1
    fi

    python3 - "$input" "$output" <<'PYTHON'
import hashlib
import pathlib
import struct
import sys

src = pathlib.Path(sys.argv[1])

with src.open("rb") as f:
    fixed = f.read(69)

    if len(fixed) != 69:
        print("[!] Invalid GPTP file: truncated header.")
        sys.exit(1)

    magic, version, flags, header_size, name_len, original_size, expected_hash, reserved = struct.unpack(
        ">4sBBIIQ32s15s",
        fixed
    )

    if magic != bytes.fromhex("FF 20 20 69"):
        print("[!] Not a GPTP file.")
        sys.exit(1)

    if version != 2:
        print(f"[!] Unsupported GPTP version: {version}")
        sys.exit(1)

    if header_size != 69 + name_len:
        print("[!] Invalid GPTP header size.")
        sys.exit(1)

    name_bytes = f.read(name_len)

    try:
        name = name_bytes.decode("utf-8")
    except UnicodeDecodeError:
        print("[!] Invalid GPTP filename encoding.")
        sys.exit(1)

    data = f.read()

if len(data) != original_size:
    print("[!] GPTP payload size mismatch.")
    sys.exit(1)

if hashlib.sha256(data).digest() != expected_hash:
    print("[!] GPTP integrity check failed.")
    sys.exit(1)

output = (
    pathlib.Path(sys.argv[2])
    if len(sys.argv) > 2 and sys.argv[2]
    else pathlib.Path(name)
)

output.write_bytes(data)

print(f"[+] Restored: {output}")
PYTHON

    exit $?
fi

echo "Usage:"
echo "  build_gptp.sh cf <file> [output.gptp] [--gptpm]"
echo "  build_gptp.sh uf <file.gptp> [output]"
exit 1
