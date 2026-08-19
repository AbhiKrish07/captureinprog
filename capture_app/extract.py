import os, json

log_file = r'C:\Users\pranavlal\.gemini\antigravity-ide\brain\e1f372cc-9349-48f9-aaf6-a1295db564fe\.system_generated\logs\transcript.jsonl'
html = ''
with open(log_file, encoding='utf-8') as f:
    lines = f.readlines()
    for line in reversed(lines):
        data = json.loads(line)
        if data.get('type') == 'USER_INPUT' and '<!DOCTYPE html>' in data.get('content', ''):
            html = data['content']
            break

start = html.find('<!DOCTYPE html>')
end = html.rfind('</html>') + 7

os.makedirs('assets', exist_ok=True)
with open('assets/editor.html', 'w', encoding='utf-8') as f:
    f.write(html[start:end])

print(f"Saved {end-start} bytes to assets/editor.html")
