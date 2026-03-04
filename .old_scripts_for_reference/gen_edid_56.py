import struct

def make_edid():
    # --- HEADER ---
    header = b'\x00\xff\xff\xff\xff\xff\xff\x00'
    mfg = b'\x1c\xec\xd2\x04\x01\x00\x00\x00\x01\x22'
    version = b'\x01\x04'
    params = b'\x95\x28\x1e\x78\xeb\x9c\x20\xa0\x57\x4f\xa2\x28\x0f\x50\x54'
    established = b'\xbf\xef\x80'
    # Standard Timings (Placeholders)
    standard = b'\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01'

    # --- DETAILED TIMING 1: 1920x1440 @ ~56Hz (173MHz Clock) ---
    # This fits under the 165-175MHz bandwidth limit of the dongle
    dt1 = b'\x94\x43\x80\xa0\x70\xa0\x2e\x50\x30\x20\x35\x00\x00\x00\x00\x00\x00\x1a'

    # --- DETAILED TIMING 2: 1920x1200 @ 60Hz (Backup) ---
    dt2 = b'\x28\x3c\x80\xa0\x70\xb0\x23\x40\x30\x20\x36\x00\x00\x00\x00\x00\x00\x1a'

    d3 = b'\x00\x00\x00\xfc\x00\x4f\x4d\x41\x52\x43\x48\x59\x0a\x20\x20\x20\x20\x20'
    d4 = b'\x00\x00\x00\xfd\x00\x17\x3d\x0f\x50\x11\x00\x0a\x20\x20\x20\x20\x20\x20'
    ext = b'\x00'

    body = header + mfg + version + params + established + standard + dt1 + dt2 + d3 + d4 + ext
    checksum = (256 - (sum(body) % 256)) % 256
    
    with open("edid.bin", "wb") as f:
        f.write(body + bytes([checksum]))
    print("Generated edid.bin (56Hz / 173MHz).")

if __name__ == "__main__":
    make_edid()