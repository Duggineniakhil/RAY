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

# app_router.dart
modify_file("lib/core/utils/app_router.dart", "import 'package:riverpod/riverpod.dart';", "")
modify_file("lib/core/utils/app_router.dart", "=> LoginScreen(),", "=> const LoginScreen(),")
modify_file("lib/core/utils/app_router.dart", "=> SignupScreen(),", "=> const SignupScreen(),")
modify_file("lib/core/utils/app_router.dart", "=> ExploreScreen(),", "=> const ExploreScreen(),")

# camera_filters.dart
modify_file("lib/core/utils/camera_filters.dart", "matrix: [\n      1", "matrix: const [\n      1")

# qr_scanner_screen.dart
modify_file("lib/features/qr_scanner/qr_scanner_screen.dart", "border: Border.all(color: Colors.white24),", "border: Border.all(color: Colors.white24),") # oops it was line 122/126, let's use regex
def fix_qr():
    path = "lib/features/qr_scanner/qr_scanner_screen.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("decoration: BoxDecoration(\n                    color: Colors.black54,", "decoration: const BoxDecoration(\n                    color: Colors.black54,")
    content = content.replace("decoration: BoxDecoration(\n                  color: Colors.white24,", "decoration: const BoxDecoration(\n                  color: Colors.white24,")
    content = content.replace("borderRadius: BorderRadius.circular(12),\n                ),", "borderRadius: BorderRadius.all(Radius.circular(12)),\n                ),")
    # let's just make it simpler
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_qr()

# settings_screen.dart
def fix_settings():
    path = "lib/features/settings/settings_screen.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("builder: (context) => SettingsScreen(),", "builder: (context) => const SettingsScreen(),")
    content = content.replace("Widget _buildListTile(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {", "Widget _buildListTile(BuildContext context, String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {")
    content = content.replace("trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white54),", "trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white54),")
    # wait the warning is Unused parameter 'trailing'. My last script broke it. Let's fix properly:
    content = content.replace("{Widget? trailing, VoidCallback? onTap}", "{VoidCallback? onTap}")
    content = content.replace("trailing: trailing ?? const", "trailing: const")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_settings()

# video_controller_manager.dart
def fix_manager():
    path = "lib/features/video_feed/presentation/providers/video_controller_manager.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = re.sub(r'int\s+_currentIndex\s*=\s*0;\n*', '', content)
    content = re.sub(r'_currentIndex\s*=\s*index;\n*', '', content)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_manager()

# video_info_overlay.dart
def fix_overlay():
    path = "lib/features/video_feed/presentation/widgets/video_info_overlay.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("Row(\n          children: [", "Row(\n          children: const [")
    content = content.replace("Icon(Icons.music_note_rounded, color: Colors.white, size: 16),", "Icon(Icons.music_note_rounded, color: Colors.white, size: 16)")
    content = content.replace("SizedBox(width: 8),", "SizedBox(width: 8)")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_overlay()

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
