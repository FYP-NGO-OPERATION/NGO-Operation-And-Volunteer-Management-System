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

    # Replace class declaration
    content = re.sub(r'class (_Animated\w+State) extends State<(_Animated\w+)> with SingleTickerProviderStateMixin \{',
                     r'class \1 extends State<\2> {', content)
    
    # Remove animation controller declarations and init/dispose
    content = re.sub(r'\s*late AnimationController _controller;\n\s*@override\s*void initState\(\) \{[\s\S]*?super\.initState\(\);\s*_controller = AnimationController\([\s\S]*?\.\.repeat\(\);\s*\}\s*@override\s*void dispose\(\) \{\s*_controller\.dispose\(\);\s*super\.dispose\(\);\s*\}',
                     '', content)

    # Replace AnimatedBuilder with just the builder content
    content = re.sub(r'return AnimatedBuilder\(\s*animation: _controller,\s*builder: \(context, child\) \{',
                     r'return Builder(builder: (context) {', content)
                     
    content = re.sub(r'final angle = _controller\.value \* 2 \* math\.pi;',
                     r'final angle = math.pi / 4;', content)
                     
    # Remove BackdropFilter which is the most expensive part
    content = re.sub(r'// Frosted glass overlay[\s\S]*?Positioned\.fill\([\s\S]*?child: BackdropFilter\([\s\S]*?filter: ImageFilter\.blur[\s\S]*?child: Container\([\s\S]*?color:[\s\S]*?,\s*\),\s*\),\s*\),',
                     '', content)
    
    # Remove math.sin(angle * 2) or math.cos(angle * 3) dependence on animation to simplify
    content = re.sub(r'math\.sin\(angle \* 2\)', '0.5', content)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Updated {file}")
