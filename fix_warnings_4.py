import os
import re

def modify_file(path, old, new):
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    updated = content.replace(old, new)
    if updated != content:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(updated)
        print(f"Updated {path}")

# app_router.dart (my previous script couldn't match LoginScreen() because I matched "=> LoginScreen()," but the code might have spaces or newlines)
def fix_router():
    path = "lib/core/utils/app_router.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = re.sub(r'builder:\s*\(context,\s*state\)\s*=>\s*LoginScreen\(\),', r'builder: (context, state) => const LoginScreen(),', content)
    content = re.sub(r'builder:\s*\(context,\s*state\)\s*=>\s*SignupScreen\(\),', r'builder: (context, state) => const SignupScreen(),', content)
    content = re.sub(r'builder:\s*\(context,\s*state\)\s*=>\s*ExploreScreen\(\),', r'builder: (context, state) => const ExploreScreen(),', content)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_router()

# camera_filters.dart
modify_file("lib/core/utils/camera_filters.dart", "matrix: [\n      1", "matrix: const [\n      1")
modify_file("lib/core/utils/camera_filters.dart", "matrix: [", "matrix: const [") # Just in case

# qr_scanner_screen.dart (lines 122, 126, 127)
def fix_qr():
    path = "lib/features/qr_scanner/qr_scanner_screen.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("decoration: BoxDecoration(", "decoration: const BoxDecoration(")
    content = content.replace("borderRadius: BorderRadius.circular(12),", "borderRadius: BorderRadius.all(Radius.circular(12)),")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_qr()

# settings_screen.dart
def fix_settings():
    path = "lib/features/settings/settings_screen.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = re.sub(r'builder:\s*\(context\)\s*=>\s*SettingsScreen\(\),', r'builder: (context) => const SettingsScreen(),', content)
    # the unused parameter string
    content = content.replace("{Widget? trailing, VoidCallback? onTap}", "{VoidCallback? onTap}")
    content = content.replace("trailing: trailing ??", "trailing:")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_settings()

# video_controller_manager.dart
def fix_manager():
    path = "lib/features/video_feed/presentation/providers/video_controller_manager.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = re.sub(r'int\s+_currentIndex\s*=\s*0;\n', '', content)
    content = re.sub(r'var\s*_currentIndex\s*=\s*0;\n', '', content)
    content = re.sub(r'_currentIndex\s*=\s*index;\n', '', content)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_manager()

# main.dart
def fix_main():
    path = "lib/main.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("localizationsDelegates: [", "localizationsDelegates: const [")
    content = content.replace("supportedLocales: [", "supportedLocales: const [")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_main()
