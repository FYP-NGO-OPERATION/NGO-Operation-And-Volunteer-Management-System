import os
import re

files = [
    r"E:\Fyp\ngo_volunteer_app\app\lib\screens\home\components\home_dashboard_tab.dart",
    r"E:\Fyp\ngo_volunteer_app\app\lib\screens\home\home_screen.dart",
    r"E:\Fyp\ngo_volunteer_app\app\lib\screens\admin\admin_dashboard_screen.dart",
    r"E:\Fyp\ngo_volunteer_app\app\lib\widgets\admin\admin_layout.dart"
]

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the block where `return RepaintBoundary` is used.
    # The error is that we didn't close RepaintBoundary.
    # So we replace `    );\n  }\n}` with `    );\n    );\n  }\n}` at the end of the file.
    # Let's just do a specific replace for the end of the file since these classes are at the end.
    if file.endswith('home_dashboard_tab.dart') or file.endswith('admin_dashboard_screen.dart') or file.endswith('home_screen.dart') or file.endswith('admin_layout.dart'):
        content = re.sub(r'      \},\n    \);\n  \}\n\}\s*$', r'      },\n    ),\n    );\n  }\n}\n', content)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Fixed brackets in {file}")
