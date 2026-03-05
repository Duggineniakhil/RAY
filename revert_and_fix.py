import os
import re

def fix_camera_filters():
    path = "lib/core/utils/camera_filters.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    # Remove all "matrix: const [" and replace with "matrix: ["
    content = content.replace("matrix: const [", "matrix: [")
    # Add const to the specific line 86 (which is actually the const constructor `ColorFilter.matrix`)
    # Wait, the warning was "Use 'const' with the constructor to improve performance - lib\core\utils\camera_filters.dart:86:3"
    # This means `ColorFilter.matrix(` needs `const`. Let's just add `const` to all `ColorFilter.matrix(`
    content = content.replace("ColorFilter.matrix([", "const ColorFilter.matrix([")
    content = content.replace("ColorFilter.matrix(\n", "const ColorFilter.matrix(\n")
    # Clean up any double const
    content = content.replace("const const ColorFilter", "const ColorFilter")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_camera_filters()

def fix_qr():
    path = "lib/features/qr_scanner/qr_scanner_screen.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    # Revert all "decoration: const BoxDecoration(" to "decoration: BoxDecoration("
    content = content.replace("decoration: const BoxDecoration(", "decoration: BoxDecoration(")
    # The actual warnings were on lines 122, 126, 127
    # Let's just remove the consts from BorderRadius.all(Radius.circular(12)) to BorderRadius.circular(12)
    content = content.replace("borderRadius: BorderRadius.all(Radius.circular(12)),", "borderRadius: BorderRadius.circular(12),")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_qr()

def fix_settings():
    path = "lib/features/settings/settings_screen.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    # Just remove trailing parameter from definition totally
    content = re.sub(r'Widget\s+_buildListTile\(BuildContext\s+context,\s+String\s+title,\s+IconData\s+icon,\s*\{.*?\VoidCallback\?\s+onTap\}\)\s*\{', r'Widget _buildListTile(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {', content)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_settings()

def fix_manager():
    path = "lib/features/video_feed/presentation/providers/video_controller_manager.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    # completely remove any line with _currentIndex
    lines = content.split('\n')
    cleaned = [l for l in lines if '_currentIndex' not in l]
    with open(path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(cleaned))
fix_manager()

def fix_router():
    path = "lib/core/utils/app_router.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    # Find GoRoute builders and add const to LoginScreen, SignupScreen, ExploreScreen
    content = re.sub(r'builder:\s*\(context,\s*state\)\s*=>\s*LoginScreen\(\),', 'builder: (context, state) => const LoginScreen(),', content)
    content = re.sub(r'builder:\s*\(context,\s*state\)\s*=>\s*SignupScreen\(\),', 'builder: (context, state) => const SignupScreen(),', content)
    content = re.sub(r'builder:\s*\(context,\s*state\)\s*=>\s*ExploreScreen\(\),', 'builder: (context, state) => const ExploreScreen(),', content)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_router()

def fix_video_info():
    path = "lib/features/video_feed/presentation/widgets/video_info_overlay.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("Icon(Icons.music_note_rounded, color: Colors.white, size: 14)", "const Icon(Icons.music_note_rounded, color: Colors.white, size: 14)")
    content = content.replace("SizedBox(width: 4)", "const SizedBox(width: 4)")
    content = content.replace("Text(\n              'Original Sound',\n              style: TextStyle(", "Text(\n              'Original Sound',\n              style: const TextStyle(")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_video_info()
