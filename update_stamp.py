import os
import glob
import base64
import re

# Extensions to look for
extensions = ['png', 'jpg', 'jpeg', 'webp']
files = []
for ext in extensions:
    files.extend(glob.glob(f"stamp.{ext}"))
    files.extend(glob.glob(f"verified.{ext}"))

if not files:
    print("No image file found (stamp.png, verified.png, etc.).")
    print("Please save the image in this folder first.")
    exit(1)

image_path = files[0]
print(f"Found image: {image_path}")

try:
    with open(image_path, "rb") as img_file:
        encoded_string = base64.b64encode(img_file.read()).decode('utf-8')
        
    ext = image_path.split('.')[-1].lower()
    if ext == 'jpg': ext = 'jpeg'
    if ext == 'svg': ext = 'svg+xml'
    
    base64_src = f"data:image/{ext};base64,{encoded_string}"
    
    with open('index.html', 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Replace the existing base64 image src
    # Pattern: src="data:image/..." inside the seal section
    # We look for the specific existing tag or just the data URI
    
    new_content = re.sub(r'src="data:image/[^;]+;base64,[^"]+"', f'src="{base64_src}"', content, count=1)
    
    if content == new_content:
        print("Could not find the image tag to replace, or it's already updated.")
    else:
        with open('index.html', 'w', encoding='utf-8') as f:
            f.write(new_content)
        print("Success! index.html has been updated with the new stamp.")
        
except Exception as e:
    print(f"Error: {e}")
