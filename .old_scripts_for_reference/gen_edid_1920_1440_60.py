import struct

def make_edid():
    # CVT 1920x1440R Modeline: 184.75 1920 1968 2000 2080 1440 1443 1447 1481
    pixel_clock = 18475 # 184.75 MHz in 10kHz units
    h_act = 1920
    h_blk = 160  # 2080 - 1920
    v_act = 1440
    v_blk = 41   # 1481 - 1440
    h_sync_off = 48 # 1968 - 1920
    h_sync_pw = 32  # 2000 - 1968
    v_sync_off = 3  # 1443 - 1440
    v_sync_pw = 4   # 1447 - 1443

    # Header & ID
    edid = bytearray([0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00])
    edid.extend([0x1C, 0x4C, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x1F, 0x01, 0x03])
    
    # Specs: Digital, 60x34cm, Gamma 2.2, No DPMS
    edid.extend([0x80, 0x3C, 0x22, 0x78, 0xEA, 0xEE, 0x91, 0xA3, 0x54, 0x4C, 0x99, 0x26, 0x0F, 0x50, 0x54, 0x00, 0x00, 0x00])
    
    # Standard Timings Padding
    edid.extend([0x01, 0x01] * 8)

    # --- THE DTD BLOCK (18 bytes) ---
    dtd = bytearray()
    dtd.extend(struct.pack("<H", pixel_clock)) # Bytes 0-1
    dtd.append(h_act & 0xFF)                   # Byte 2
    dtd.append(h_blk & 0xFF)                   # Byte 3
    dtd.append(((h_act >> 8) << 4) | (h_blk >> 8)) # Byte 4
    dtd.append(v_act & 0xFF)                   # Byte 5
    dtd.append(v_blk & 0xFF)                   # Byte 6
    dtd.append(((v_act >> 8) << 4) | (v_blk >> 8)) # Byte 7
    dtd.append(h_sync_off & 0xFF)              # Byte 8
    dtd.append(h_sync_pw & 0xFF)               # Byte 9
    dtd.append(((v_sync_off & 0x0F) << 4) | (v_sync_pw & 0x0F)) # Byte 10
    
    # Byte 11: MSBs for syncs
    # Bits 7-6: H sync offset MSBs (bits 9-8)
    # Bits 5-4: H sync pulse width MSBs (bits 9-8)
    # Bits 3-2: V sync offset MSBs (bits 5-4)
    # Bits 1-0: V sync pulse width MSBs (bits 5-4)
    msb_sync = ((h_sync_off >> 8) << 6) | ((h_sync_pw >> 8) << 4) | \
               ((v_sync_off >> 4) << 2) | (v_sync_pw >> 4)
    dtd.append(msb_sync)

    dtd.extend([0x00, 0x00, 0x00]) # H/V Image size (ignored)
    dtd.extend([0x00, 0x00])       # Border
    dtd.append(0x1E)               # Flags: Digital, Separate Sync, H+, V-
    
    edid.extend(dtd)

    # Descriptors
    edid.extend([0x00, 0x00, 0x00, 0xFC, 0x00, 0x4F, 0x4D, 0x41, 0x52, 0x43, 0x48, 0x59, 0x0A, 0x20, 0x20, 0x20, 0x20, 0x20])
    edid.extend([0x00, 0x00, 0x00, 0xFD, 0x00, 0x38, 0x4B, 0x1E, 0x5A, 0x1E, 0x00, 0x0A, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20])
    edid.extend([0x00, 0x00, 0x00, 0x10, 0x00, 0x0A, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20])
    edid.append(0x00)
    edid.append((256 - (sum(edid) % 256)) % 256)

    with open("edid-1920-1440-60.bin", "wb") as f:
        f.write(edid)
    print("Generated: edid-1920-1440-60.bin")

make_edid()