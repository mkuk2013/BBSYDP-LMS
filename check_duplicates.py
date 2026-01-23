
import re

file_path = r'c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\index.html'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Extract the allQ array content roughly
# We look for 'const allQ = [' and '];'
start_marker = 'const allQ = ['
end_marker = '];'

start_idx = content.find(start_marker)
if start_idx == -1:
    print("allQ not found")
    exit(1)

end_idx = content.find(end_marker, start_idx)
array_content = content[start_idx:end_idx+2]

# Regex to find questions
# { q: "Question text", ... }
# We'll match q: "..."
matches = re.findall(r'q:\s*"([^"]+)"', array_content)

print(f"Total questions found: {len(matches)}")

seen = set()
duplicates = []

for i, q in enumerate(matches):
    if q in seen:
        duplicates.append((i, q))
    seen.add(q)

if duplicates:
    print("Duplicates found:")
    for idx, q in duplicates:
        print(f"Index {idx}: {q}")
else:
    print("No duplicate questions found.")

if len(matches) < 100:
    print(f"WARNING: Only {len(matches)} questions available. Need 100.")
