import struct
import os

def get_image_info(file_path):
    with open(file_path, 'rb') as f:
        data = f.read(25)
        # PNG signature
        if data[:8] != b'\x89PNG\r\n\x1a\n':
            return "Not a PNG"
        # IHDR chunk
        w, h = struct.unpack('>LL', data[16:24])
        return w, h

file_path = 'assets/bbsydp_logo.png'
if os.path.exists(file_path):
    dims = get_image_info(file_path)
    print(f"Dimensions: {dims}")
else:
    print("File not found")
