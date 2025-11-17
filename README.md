# FrogKillCMOS

**Low-level CMOS/RTC Educational Tool**

![logo](logo.png)

FrogKillCMOS is a minimal, research-focused utility designed to demonstrate raw CMOS/RTC access on Linux systems.
It serves as an educational example of how legacy firmware regions can be accessed through I/O ports on x86_64 hardware.

This tool is intended **only for educational, research, and experimentation purposes** on machines you own.

---

## Disclaimer

This software interacts with low-level hardware I/O ports.
Improper use may cause system instability or require manual BIOS/UEFI recovery.

By compiling or running this tool, **you accept all risks and take full responsibility for any consequences**.

The author provides **no warranty** and **assumes no liability** for any misuse, damage, malfunction, or data loss.

---

## Download

Latest release (ZIP):
**[https://github.com/victormeloasm/FrogKillCMOS/releases/download/1.0v/FrogKillCMOS.zip](https://github.com/victormeloasm/FrogKillCMOS/releases/download/1.0v/FrogKillCMOS.zip)**

---

## Building From Source (Linux + FASM)

You can compile the assembly source using **FASM**:

```bash
sudo apt install fasm
fasm FrogKillCMOS.asm
```

This will produce an ELF64 binary in the same folder.
Running it requires **root** permissions due to the need for raw I/O port access.

---

## Purpose

FrogKillCMOS was created for:

* studying legacy CMOS/RTC access
* exploring low-level hardware interactions in Linux
* understanding historical BIOS behavior
* educational demonstrations in firmware and systems programming

It is **not** intended as a repair tool or for malicious use.

---

## License — MIT

```
MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND…

