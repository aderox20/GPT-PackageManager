# Spec File
````bash
mkdir -p GPT-Package
cat > GPT-Package/SPEC.md <<'EOF'
# GPT Package File (GPTP) Specification

## Status

GPTP v2

## File extension

`.gptp`

## Purpose

GPTP (GPT Package File) is a reversible binary container format used by GPT Package Manager.

A GPTP file contains the original file data and enough metadata to reconstruct the original file byte-for-byte.

## Format

```text
GPTP file
├── Fixed header (69 bytes)
├── Original filename (variable)
└── Original file data (variable)
````

### Fixed header

|     Size | Field                    |
| -------: | ------------------------ |
|  4 bytes | Magic: `GPTP`            |
|   1 byte | Format version           |
|   1 byte | Flags                    |
|  4 bytes | Header size              |
|  4 bytes | Filename length          |
|  8 bytes | Original file size       |
| 32 bytes | SHA-256 of original file |
| 15 bytes | Reserved                 |

The fixed header is exactly **69 bytes**.

### Magic

The first four bytes must be:

```text
GPTP
```

### Version

GPTP v2 uses:

```text
0x01
```

### Flags

Currently:

```text
0x00
```

Reserved for future format features.

### Header size

The complete header size is:

```text
69 + filename length
```

### Original filename

UTF-8 encoded filename.

### Original file data

The payload contains the exact original file bytes.

No extraction, recompression, or archive conversion is performed by the GPTP format itself.

Therefore:

```text
original file
    ↓
GPTP
    ↓
exact original bytes
```

### Integrity

The SHA-256 field contains the hash of the original file data.

When decoding, the implementation must verify:

1. Payload size matches the recorded original size.
2. SHA-256 of the payload matches the stored hash.

If either check fails, decoding must fail.

## Conversion

Create:

```text
gpt -cf <file> [output.gptp]
```

Decode:

```text
gpt -uf <file.gptp> [output]
```

The original filename stored in the GPTP header is used when no output filename is explicitly supplied.

## Supported source files

GPTP can contain arbitrary files.

GPT Package Manager specifically supports archive files such as:

* `.tar`
* `.tar.gz`
* `.tar.xz`
* `.tar.zst`

The archive format is preserved exactly because GPTP stores the original bytes.

## Reversibility

A valid GPTP file must be reversible:

```text
file
  ↓ -cf
file.gptp
  ↓ -uf
file
```

The reconstructed file must be byte-for-byte identical to the original.
EOF

````

Then check:

```bash
git status --short
````

This gives you:

```text
GPT-PackageManager/
├── GPT-Package/
│   ├── build_gptp.sh
│   └── SPEC.md
├── gpt
└── packages/
    └── README.md
```
