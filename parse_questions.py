import re
import json

def parse_questions(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split by double newlines or based on question numbering
    # Pattern: Number. Question Text
    # A) Option
    # ...
    # Correct Answer: X
    
    questions = []
    
    # Regex to find each question block
    # Looks for "Number. " at start of line
    pattern = re.compile(r'^\d+\.\s+(.*?)(?=\n\d+\.\s+|$)', re.DOTALL | re.MULTILINE)
    
    # Since the regex might be tricky with the whole file, let's process line by line or split by "Correct Answer"
    
    blocks = re.split(r'Correct Answer:\s*([A-D])', content)
    
    # blocks will be [q1_text_and_options, ans1, q2_text_and_options, ans2, ...]
    # The last block might be empty or just whitespace if file ends with newline
    
    if len(blocks) < 2:
        print("Failed to split blocks correctly.")
        return

    final_questions = []
    
    # Iterate in pairs
    for i in range(0, len(blocks)-1, 2):
        block_text = blocks[i].strip()
        answer_char = blocks[i+1].strip()
        
        # Extract question text and options from block_text
        # block_text ends with options D, C, B, A lines
        
        lines = [l.strip() for l in block_text.split('\n') if l.strip()]
        
        if not lines:
            continue
            
        # First line (or lines) is question text, usually starting with "Number. "
        # Last 4 lines are options? Not always guaranteed if there are empty lines.
        
        # Let's identify lines starting with A), B), C), D)
        opt_lines = {}
        q_lines = []
        
        current_opt = None
        
        for line in lines:
            if line.startswith('A)') or line.startswith('A.'):
                current_opt = 'A'
                opt_lines['A'] = line[2:].strip()
            elif line.startswith('B)') or line.startswith('B.'):
                current_opt = 'B'
                opt_lines['B'] = line[2:].strip()
            elif line.startswith('C)') or line.startswith('C.'):
                current_opt = 'C'
                opt_lines['C'] = line[2:].strip()
            elif line.startswith('D)') or line.startswith('D.'):
                current_opt = 'D'
                opt_lines['D'] = line[2:].strip()
            else:
                if current_opt:
                     # Continuation of option? Or part of question if no option found yet?
                     # Usually options are single line.
                     pass
                else:
                    q_lines.append(line)
        
        # Reassemble question text
        # Remove the leading number (e.g., "1. ")
        full_q_text = " ".join(q_lines)
        full_q_text = re.sub(r'^\d+\.\s*', '', full_q_text)
        
        if not full_q_text or len(opt_lines) < 4:
            print(f"Skipping incomplete block: {full_q_text[:50]}...")
            continue
            
        # Map answer char to index
        ans_idx = {'A': 0, 'B': 1, 'C': 2, 'D': 3}.get(answer_char, 0)
        
        q_obj = {
            "q": full_q_text,
            "o": [opt_lines['A'], opt_lines['B'], opt_lines['C'], opt_lines['D']],
            "a": ans_idx
        }
        final_questions.append(q_obj)

    print(f"Parsed {len(final_questions)} questions.")
    
    # Write to JSON file
    with open('parsed_questions.json', 'w', encoding='utf-8') as f:
        json.dump(final_questions, f, indent=2, ensure_ascii=False)

if __name__ == "__main__":
    parse_questions('new_questions.txt')
