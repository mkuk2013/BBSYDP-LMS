
import re
import json
import os

def parse_questions(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Normalize newlines
    content = content.replace('\r\n', '\n')
    
    questions = []
    
    # Split by double newlines or look for patterns
    # A robust way is to iterate line by line
    
    lines = content.split('\n')
    
    current_q = None
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        # Check for Question Start "1. ..."
        q_match = re.match(r'^\d+\.\s+(.+)', line)
        if q_match:
            if current_q:
                questions.append(current_q)
            
            current_q = {
                'q': q_match.group(1).strip(),
                'options': [],
                'correct': 0
            }
            continue
            
        # Check for Options "A) ..."
        opt_match = re.match(r'^([A-D])\)\s+(.+)', line)
        if opt_match and current_q:
            current_q['options'].append(opt_match.group(2).strip())
            continue
            
        # Check for Correct Answer "Correct Answer: A"
        ans_match = re.match(r'^Correct Answer:\s+([A-D])', line, re.IGNORECASE)
        if ans_match and current_q:
            char = ans_match.group(1).upper()
            current_q['correct'] = ord(char) - ord('A')
            continue
            
    if current_q:
        questions.append(current_q)
        
    return questions

def update_index_html(questions):
    html_path = r'c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\index.html'
    
    with open(html_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Find the allQ array
    start_marker = 'const allQ = ['
    end_marker = '];'
    
    start_idx = content.find(start_marker)
    if start_idx == -1:
        print("Could not find allQ array in index.html")
        return
        
    # Find the matching closing bracket for the array
    # Since there might be nested brackets, we should be careful, 
    # but the previous code structure is simple.
    # We can just search for the next `];` after start_idx
    # However, to be safe, let's look for `function shuffle` which comes after.
    
    next_func_idx = content.find('function shuffle', start_idx)
    if next_func_idx == -1:
        print("Could not find function shuffle")
        # Try finding the closing `];` before `return shuffle`
        pass
        
    # Let's try to find the `];` that closes `allQ`
    # It should be before `function shuffle`
    end_idx = content.rfind('];', start_idx, next_func_idx)
    
    if end_idx == -1:
        print("Could not find end of allQ array")
        return
        
    # Construct new array string
    new_array_str = "const allQ = [\n"
    for i, q in enumerate(questions):
        # Escape quotes in strings
        q_text = q['q'].replace('"', '\\"')
        opts = [o.replace('"', '\\"') for o in q['options']]
        
        # Format: { q: "...", options: ["...", ...], correct: N },
        opts_str = ', '.join([f'"{o}"' for o in opts])
        new_array_str += f'                {{ q: "{q_text}", options: [{opts_str}], correct: {q["correct"]} }}'
        
        if i < len(questions) - 1:
            new_array_str += ",\n"
        else:
            new_array_str += "\n"
            
    # The end_idx points to `];`, so we want to replace up to end_idx (exclusive of `];` maybe?)
    # No, `end_idx` is where `];` starts.
    # So we replace from `start_idx` to `end_idx`
    
    new_content = content[:start_idx] + new_array_str + content[end_idx:]
    
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
        
    print(f"Successfully updated index.html with {len(questions)} questions.")

if __name__ == "__main__":
    qs = parse_questions(r'c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\new_questions.txt')
    print(f"Parsed {len(qs)} questions.")
    
    # Validate
    for i, q in enumerate(qs):
        if len(q['options']) != 4:
            print(f"Warning: Question {i+1} has {len(q['options'])} options.")
            
    update_index_html(qs)
