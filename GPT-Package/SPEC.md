# GPT Package File (GPTP) Specification

## Status

GPTP v2

## File extension

`.gptp`

## Purpose

GPTP (GPT Package File) is a reversible binary container format used by GPT Package Manager.

A GPTP file contains the original file data and enough metadata to reconstruct the original file byte-for-byte.

GPTP is a container format. It does not compress, archive, or otherwise transform the payload.

## Format

```text
GPTP file
├── Fixed header (69 bytes)
├── Original filename (variable)
└── Original file data (variable)
```

## Fixed header

| Offset |     Size | Field                    |
| -----: | -------: | ------------------------ |
|      0 |  4 bytes | Magic: `FF 20 20 69`     |
|      4 |   1 byte | Format version           |
|      5 |   1 byte | Flags                    |
|      6 |  4 bytes | Header size              |
|     10 |  4 bytes | Filename length          |
|     14 |  8 bytes | Original file size       |
|     22 | 32 bytes | SHA-256 of original file |
|     54 | 15 bytes | Reserved                 |

The fixed header is exactly **69 bytes**.

The binary header uses big-endian byte order and corresponds to:

```text
>4sBBIIQ32s15s
```

## Magic

The first four bytes must be:

```text
FF 20 20 69
```

## Version

GPTP v2 uses:

```text
0x02
```

## Flags

The flags byte identifies the origin of the GPTP file.

### GPTPM-created GPTP

```text
0x69
```

This indicates that the GPTP file was created by GPT Package Manager.

### Generic/external GPTP

```text
0x00
```

This indicates that the GPTP file was created externally or through the generic `gpt cf` command.

The `0x69` value is a GPTPM format marker. It is **not a cryptographic signature or proof of authenticity**.

Other flag values are reserved for future use.

## Header size

The complete header size is:

```text
69 + filename length
```

For example, an 8-byte filename produces:

```text
69 + 8 = 77 bytes
```

## Filename length

The filename length is the number of bytes in the UTF-8 encoded original filename.

It is not the number of characters.

## Original filename

The original filename is stored immediately after the fixed 69-byte header.

It is encoded as UTF-8.

The filename does not include directory paths.

## Original file size

The original file size records the exact number of bytes in the payload.

The decoder must verify that the payload contains exactly this number of bytes.

## SHA-256

The SHA-256 field contains the SHA-256 digest of the original file data.

During decoding, the implementation must calculate the SHA-256 digest of the payload and compare it with the stored digest.

Decoding must fail if the hashes do not match.

## Reserved

The final 15 bytes of the fixed header are reserved for future GPTP format features.

For GPTP v2 they must be zero-filled:

```text
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
```

## Original file data

The payload contains the exact original file bytes.

GPTP does not:

* extract the file
* recompress the file
* archive the file
* modify the file
* convert the file

Therefore:

```text
original file
      │
      ▼
     GPTP
      │
      ▼
exact original bytes
```

## Supported source files

GPTP can contain arbitrary files.

GPT Package Manager commonly uses GPTP to contain package archives such as:

* `.tar`
* `.tar.gz`
* `.tar.xz`
* `.tar.zst`

The archive format is preserved exactly because GPTP stores the original bytes.

## Reversibility

A valid GPTP file must be reversible:

```text
file
  │
  │ cf
  ▼
file.gptp
  │
  │ uf
  ▼
file
```

The reconstructed file must be byte-for-byte identical to the original.

## Conversion

Create a GPTP file:

```bash
gpt cf <file> [output.gptp]
```

Create a GPTPM-marked GPTP file:

```bash
gpt cf <file> [output.gptp] --gptpm
```

Decode a GPTP file:

```bash
gpt uf <file.gptp> [output]
```

When no output filename is supplied, the original filename stored in the GPTP header is used.

## GPTP metadata

GPTPM package archives may contain a `.GPTP` metadata file describing the packaged software.

### GPTPM-created package

```text
format=GPTP
gversion=2
gcreator=gptpm
dev=<upstream developer/project>
pkgname=<name>
pkgver=<version>
arch=<arch>
type=package
```

### Generic/external package

```text
format=!GPTP
gversion=2
gcreator=<creator>
dev=<developer>
pkgname=<name>
pkgver=<version>
arch=<arch>
type=<package|executable|library|kernel|firmware>
```

### Metadata fields

| Field      | Description                                                                       |
| ---------- | --------------------------------------------------------------------------------- |
| `format`   | Declares whether the package metadata identifies as GPTP or generic/external GPTP |
| `gversion` | GPTP metadata version                                                             |
| `gcreator` | Program or creator that generated the GPTP                                        |
| `dev`      | Developer or upstream project                                                     |
| `pkgname`  | Package name                                                                      |
| `pkgver`   | Package version                                                                   |
| `arch`     | Target architecture                                                               |
| `type`     | Package type                                                                      |

Valid `type` values are:

```text
package
executable
library
kernel
firmware
```

## Integrity requirements

A GPTP decoder must reject a file when:

1. The fixed header is truncated.
2. The magic does not equal `FF 20 20 69`.
3. The format version is unsupported.
4. The header size does not equal `69 + filename length`.
5. The filename is not valid UTF-8.
6. The payload size does not equal the recorded original size.
7. The SHA-256 digest does not match the stored payload hash.

## Binary layout example

For a file named `example.tar`:

```text
Offset
0x00  FF 20 20 69
0x04  02
0x05  flags
0x06  header size
0x0A  filename length
0x0E  original file size
0x16  SHA-256
0x36  reserved
0x45  "example.tar"
       payload...
```

The payload begins at:

```text
69 + filename length
```

## Design principle

GPTP is intentionally simple:

```text
GPTP =
    fixed header
  + filename
  + exact original bytes
```

This makes GPTP reversible, easy to inspect, and independent of the format of the file it contains.
