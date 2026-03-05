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
modify_file("lib/core/utils/app_router.dart", "=> CustomTransitionPage(", "=> const CustomTransitionPage(")

# camera_filters.dart
modify_file("lib/core/utils/camera_filters.dart", "CameraFilter(\n    name: 'Vogue Noir',", "const CameraFilter(\n    name: 'Vogue Noir',")

# qr_scanner_screen.dart
old_qr = """          Positioned(
            bottom: 72,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Point camera at creator\\'s QR code',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),"""
new_qr = """          const Positioned(
            bottom: 72,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Point camera at creator\\'s QR code',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),"""
modify_file("lib/features/qr_scanner/qr_scanner_screen.dart", old_qr, new_qr)

# settings_screen.dart
modify_file("lib/features/settings/settings_screen.dart", "_SectionHeader('Appearance'),", "const _SectionHeader('Appearance'),")
modify_file("lib/features/settings/settings_screen.dart", "final Widget? trailing;\n", "")
modify_file("lib/features/settings/settings_screen.dart", "this.trailing,\n", "")

# video_info_overlay.dart
old_vid = """        Row(
          children: const [
            const Icon(Icons.music_note_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              'Original Sound',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
              ),
            ),
          ],
        ),"""
new_vid = """        const Row(
          children: [
            Icon(Icons.music_note_rounded, color: Colors.white, size: 14),
            SizedBox(width: 4),
            Text(
              'Original Sound',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
              ),
            ),
          ],
        ),"""
modify_file("lib/features/video_feed/presentation/widgets/video_info_overlay.dart", old_vid, new_vid)
