import json

with open('parsed_questions.json', 'r', encoding='utf-8') as f:
    questions = json.load(f)

js_array = "const allQ = [\n"
for q in questions:
    options_str = json.dumps(q['o'], ensure_ascii=False)
    # Ensure options strings are properly escaped if needed, but json.dumps handles quotes.
    js_array += f"                {{ q: {json.dumps(q['q'], ensure_ascii=False)}, options: {options_str}, correct: {q['a']} }},\n"
js_array += "            ];"

print(js_array)
