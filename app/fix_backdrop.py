import os

file_card = r"E:\Fyp\ngo_volunteer_app\app\lib\widgets\campaign_card.dart"
file_info = r"E:\Fyp\ngo_volunteer_app\app\lib\screens\campaigns\components\campaign_info_tab.dart"
file_qr = r"E:\Fyp\ngo_volunteer_app\app\lib\screens\campaigns\qr_generate_screen.dart"

with open(file_card, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('''      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),''', '''      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),''')
content = content.replace('''                // Glass effect
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                ),''', '''                // Glass effect
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ),''')
with open(file_card, 'w', encoding='utf-8') as f:
    f.write(content)

with open(file_info, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('''        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),''', '''        child: Padding(
            padding: padding,
            child: child,
          ),''')
content = content.replace('''        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Reduced blur for performance
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(''', '''        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(''')
with open(file_info, 'w', encoding='utf-8') as f:
    f.write(content)

with open(file_qr, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('''                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          decoration: BoxDecoration(''', '''                      child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          decoration: BoxDecoration(''')
content = content.replace('''                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(''', '''                  child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(''')

with open(file_qr, 'w', encoding='utf-8') as f:
    f.write(content)

print("Done")
