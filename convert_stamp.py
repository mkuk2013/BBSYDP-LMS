import base64
import os
import glob

# Find any image resembling 'stamp' or 'verified'
files = glob.glob("stamp.*") + glob.glob("verified.*")
file_path = files[0] if files else None

if file_path:
    with open(file_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
        ext = file_path.split('.')[-1]
        if ext == 'jpg': ext = 'jpeg'
        if ext == 'svg': ext = 'svg+xml'
        print(f"data:image/{ext};base64,{encoded_string}")
else:
    print("File not found")
