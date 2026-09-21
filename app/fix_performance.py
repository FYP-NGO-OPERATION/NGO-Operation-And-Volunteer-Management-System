import re
import os

files = [
    r"E:\Fyp\ngo_volunteer_app\app\lib\screens\home\components\home_dashboard_tab.dart",
    r"E:\Fyp\ngo_volunteer_app\app\lib\screens\home\home_screen.dart",
    r"E:\Fyp\ngo_volunteer_app\app\lib\screens\admin\admin_dashboard_screen.dart",
    r"E:\Fyp\ngo_volunteer_app\app\lib\widgets\admin\admin_layout.dart"
]

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Wrap AnimatedBuilder with RepaintBoundary
    content = re.sub(r'return AnimatedBuilder\(', r'return RepaintBoundary(\n      child: AnimatedBuilder(', content)
    content = re.sub(r'(\s*)child: Stack\([\s\S]*?\]\s*,\s*\)\s*,\s*\)\s*;\s*\}\s*,\s*\)\s*;', 
                     lambda m: m.group(0).replace(';\n      },\n    );', ';\n      },\n    ),\n    );'), 
                     content)

    # 2. Remove BackdropFilter, replace with static container
    backdrop_pattern = r'Positioned\.fill\(\s*child: BackdropFilter\(\s*filter: ImageFilter\.blur[\s\S]*?child: Container\([\s\S]*?color: isDark\s*\?\s*([\s\S]*?)\s*:\s*([\s\S]*?),\s*\)\s*,\s*\)\s*,\s*\)'
    replacement = r'''Positioned.fill(
                  child: Container(
                    color: isDark ? \1 : \2,
                  ),
                )'''
    content = re.sub(backdrop_pattern, replacement, content)

    # 3. Specifically in admin_layout and others that don't match exactly because of formatting variations
    content = re.sub(r'Positioned\.fill\(\s*child: BackdropFilter\([\s\S]*?sigmaX: 2, sigmaY: 2\),\s*child: Container\([\s\S]*?color: isDark\s*\?\s*Colors\.black\.withOpacity\(0\.15\)\s*:\s*Colors\.white\.withOpacity\(0\.08\),\s*\),\s*\),\s*\)',
                     r'''Positioned.fill(
                  child: Container(
                    color: isDark ? Colors.black.withOpacity(0.15) : Colors.white.withOpacity(0.08),
                  ),
                )''', content)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Updated {file}")
