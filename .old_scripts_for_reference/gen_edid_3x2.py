import struct

def make_edid():
    header = b'\x00\xff\xff\xff\xff\xff\xff\x00'
    # Mfg: GIM, Code 1234, Serial 2, Week 1, Year 2025
    mfg = b'\x1c\xec\xd2\x04\x02\x00\x00\x00\x01\x23'
    version = b'\x01\x04'
    params = b'\x95\x28\x1e\x78\xeb\x9c\x20\xa0\x57\x4f\xa2\x28\x0f\x50\x54'
    established = b'\xbf\xef\x80'
    standard = b'\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01'

    # --- DETAILED TIMING 1: 1920x1280 @ 60Hz ---
    # Pixel Clock: 153.25 MHz -> 0x3BDD -> \xDD\x3B
    # Horizontal: 1920 active, 160 blanking
    # Vertical: 1280 active, 29 blanking
    # Bytes 12-14 carry the high nibbles for H/V Active and Blanking
    dt1 = b'\xdd\x3b\x80\xa0\x70\x00\x1e\x50\x30\x20\x35\x00\x00\x00\x00\x00\x00\x1a'

    # --- DETAILED TIMING 2: 1920x1080 @ 60Hz (Backup) ---
    dt2 = b'\x02\x3a\x80\x18\x71\x38\x2d\x40\x58\x2c\x45\x00\x00\x00\x00\x00\x00\x1e'

    d3 = b'\x00\x00\x00\xfc\x00\x4d\x4c\x2d\x53\x45\x52\x56\x45\x52\x0a\x20\x20\x20'
    d4 = b'\x00\x00\x00\xfd\x00\x17\x3d\x0f\x50\x11\x00\x0a\x20\x20\x20\x20\x20\x20'
    ext = b'\x00'

    body = header + mfg + version + params + established + standard + dt1 + dt2 + d3 + d4 + ext
    checksum = (256 - (sum(body) % 256)) % 256
    
    with open("edid-3x2.bin", "wb") as f:
        f.write(body + bytes([checksum]))
    print("Generated fixed 1920x1280 EDID.")

if __name__ == "__main__":
    make_edid()