import os
import re

files_to_patch = [
    'app/lib/screens/admin/admin_banner_management_screen.dart',
    'app/lib/screens/admin/admin_finance_screen.dart',
    'app/lib/screens/admin/admin_manage_store_screen.dart',
    'app/lib/screens/admin/manage_tracking_events_screen.dart',
    'app/lib/screens/chat/offline_mesh_chat_screen.dart',
    'app/lib/screens/gallery/photo_gallery_screen.dart',
    'app/lib/screens/campaigns/campaign_basic_form.dart',
    'app/lib/screens/campaigns/campaign_logistics_form.dart',
    'app/lib/screens/campaigns/campaign_tasks_tab.dart',
    'app/lib/screens/chatbot/chatbot_screen.dart',
    'app/lib/screens/disasters/disaster_map_screen.dart',
    'app/lib/screens/donations/donation_tracker_screen.dart',
    'app/lib/screens/marketplace/needs_marketplace_screen.dart',
    'app/lib/screens/ai_assistant_screen.dart',
    'app/lib/screens/ngo/create_ngo_screen.dart',
    'app/lib/screens/virtual_sessions/create_session_screen.dart',
    'app/lib/screens/virtual_sessions/session_list_screen.dart',
    'app/lib/services/live_tracking_service.dart',
    'app/lib/widgets/common/custom_text_field.dart'
]

for filepath in files_to_patch:
    if not os.path.exists(filepath):
        # find the file using os.walk in app/lib
        found = False
        for root, dirs, files in os.walk('app/lib'):
            name = os.path.basename(filepath)
            if name in files:
                filepath = os.path.join(root, name)
                found = True
                break
        if not found:
            print(f"Skipping {filepath}, not found")
            continue

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "void dispose()" in content:
        print(f"{filepath} already has dispose(), skipping")
        continue

    # Find controllers and subscriptions
    matches = re.findall(r'(?:final\s+|late\s+)?(?:TextEditingController|AnimationController|StreamSubscription<.*?>|TabController|ScrollController)\??\s+(_[a-zA-Z0-9_]+)\s*=', content)
    
    # Try to find class-level vars
    class_vars = []
    lines = content.split('\n')
    for line in lines:
        match = re.search(r'(?:final\s+|late\s+)?(?:TextEditingController|AnimationController|StreamSubscription(?:<.*?>)?|TabController|ScrollController)\??\s+(_[a-zA-Z0-9_]+)\s*(?:=|;)', line)
        if match:
            class_vars.append(match.group(1))

    # deduplicate
    class_vars = list(set(class_vars))
    
    if not class_vars:
        print(f"No class-level controllers found in {filepath}, skipping")
        continue

    # Find where to insert dispose() - usually before @override Widget build(BuildContext context)
    build_idx = content.find("Widget build(BuildContext context)")
    if build_idx == -1:
        # Check if it's a service/provider
        if "extends ChangeNotifier" in content or "class " in content:
            # Just add at the end before the last closing brace
            last_brace_idx = content.rfind("}")
            if last_brace_idx != -1:
                dispose_code = "\n  @override\n  void dispose() {\n"
                for v in class_vars:
                    if "Subscription" in content: # heuristic
                        dispose_code += f"    {v}?.cancel();\n"
                    else:
                        dispose_code += f"    {v}.dispose();\n"
                dispose_code += "    super.dispose();\n  }\n"
                content = content[:last_brace_idx] + dispose_code + content[last_brace_idx:]
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Patched {filepath}")
        continue
    
    # insert before build method
    # Find the nearest @override before build_idx
    override_idx = content.rfind("@override", 0, build_idx)
    insert_pos = override_idx if override_idx != -1 else build_idx
    
    dispose_code = "\n  @override\n  void dispose() {\n"
    for v in class_vars:
        # Determine if it's a subscription or controller
        if "Subscription" in line or "Sub" in v: # heuristic
             pass # let's be more precise
             
        # we can just use the variable name
        is_sub = False
        for l in lines:
            if v in l and "StreamSubscription" in l:
                is_sub = True
                break
        
        if is_sub:
            dispose_code += f"    {v}?.cancel();\n"
        else:
            dispose_code += f"    {v}.dispose();\n"
    dispose_code += "    super.dispose();\n  }\n\n  "
    
    content = content[:insert_pos] + dispose_code + content[insert_pos:]
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Patched {filepath}")
