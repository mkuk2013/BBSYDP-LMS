import re
import base64
import os

try:
    with open('index.html', 'r', encoding='utf-8') as f:
        content = f.read()

    match = re.search(r'src="(data:image/png;base64,[^"]+)"', content)
    if match:
        print("Found Base64 string.")
        data_uri = match.group(1)
        base64_data = data_uri.split(',')[1]
        try:
            image_data = base64.b64decode(base64_data)
            with open('debug_stamp.png', 'wb') as img_file:
                img_file.write(image_data)
            print(f"Successfully wrote debug_stamp.png. Size: {len(image_data)} bytes.")
            
            # Check PNG signature
            if image_data.startswith(b'\x89PNG\r\n\x1a\n'):
                 print("Valid PNG signature found.")
            else:
                 print("Invalid PNG signature.")

        except Exception as e:
            print(f"Invalid Base64 or Image: {e}")
    else:
        print("No PNG Base64 found in index.html")

except Exception as e:
    print(f"Error: {e}")
