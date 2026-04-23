import sys
import re
import os

def resolve_ours(path):
    if not os.path.exists(path):
        print(f"File not found: {path}")
        return
        
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Regex to match git conflict markers focusing on HEAD
    # <<<<<<< HEAD\n(content)\n=======\n(other content)\n>>>>>>> [commit_hash]
    pattern = re.compile(r'<<<<<<< HEAD\n(.*?)=======\n.*?(?:>>>>>>> [a-f0-9]+|>>>>>>>[ \t]*\n?)', re.DOTALL)
    
    resolved_content = pattern.sub(r'\1', content)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(resolved_content)
        
    print(f"Resolved: {path}")

resolve_ours('c:/Users/leand/Desktop/PI_RPG-0.1/lib/main.dart')
resolve_ours('c:/Users/leand/Desktop/PI_RPG-0.1/lib/game/pirpg_game.dart')
