import os

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
modify_file("lib/core/utils/app_router.dart", "=> LoginScreen(),", "=> const LoginScreen(),")
modify_file("lib/core/utils/app_router.dart", "=> SignupScreen(),", "=> const SignupScreen(),")
modify_file("lib/core/utils/app_router.dart", "=> ExploreScreen(),", "=> const ExploreScreen(),")

# camera_filters.dart
modify_file("lib/core/utils/camera_filters.dart", "ColorFilter.matrix([", "const ColorFilter.matrix([")
modify_file("lib/core/utils/camera_filters.dart", "ColorFilter.matrix(\n", "const ColorFilter.matrix(\n")
modify_file("lib/core/utils/camera_filters.dart", "const const ColorFilter", "const ColorFilter")

# qr_scanner_screen.dart
modify_file("lib/features/qr_scanner/qr_scanner_screen.dart", "decoration: BoxDecoration(\n                    color: Colors.black54,", "decoration: const BoxDecoration(\n                    color: Colors.black54,")
modify_file("lib/features/qr_scanner/qr_scanner_screen.dart", "decoration: BoxDecoration(\n                  color: Colors.white24,", "decoration: const BoxDecoration(\n                  color: Colors.white24,")
modify_file("lib/features/qr_scanner/qr_scanner_screen.dart", "borderRadius: BorderRadius.circular(12),", "borderRadius: const BorderRadius.all(Radius.circular(12)),")

# settings_screen.dart
modify_file("lib/features/settings/settings_screen.dart", "builder: (context) => SettingsScreen(),", "builder: (context) => const SettingsScreen(),")
modify_file("lib/features/settings/settings_screen.dart", "Widget _buildListTile(BuildContext context, String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {", "Widget _buildListTile(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {")
modify_file("lib/features/settings/settings_screen.dart", "trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white54),", "trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white54),")

# video_controller_manager.dart
# I will just write a specific replacement for the index
def fix_manager():
    path = "lib/features/video_feed/presentation/providers/video_controller_manager.dart"
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    lines = content.split('\n')
    cleaned = [l for l in lines if '_currentIndex' not in l]
    with open(path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(cleaned))
fix_manager()

# video_info_overlay.dart
modify_file("lib/features/video_feed/presentation/widgets/video_info_overlay.dart", "Icon(Icons.music_note_rounded, color: Colors.white, size: 14)", "const Icon(Icons.music_note_rounded, color: Colors.white, size: 14)")
modify_file("lib/features/video_feed/presentation/widgets/video_info_overlay.dart", "SizedBox(width: 4)", "const SizedBox(width: 4)")
