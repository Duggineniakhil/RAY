import os
import re

def replace_in_file(filepath, replacements):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = content
    for old, new in replacements:
        new_content = new_content.replace(old, new)

    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

# 1. app_theme.dart duplicates
app_theme_replacements = [
    ("surface: const Color(0xFF1E1E1E),\n      surface: Colors.black,", "surface: const Color(0xFF1E1E1E),"),
    ("surface: Colors.black,\n      surface: const Color(0xFF1E1E1E),", "surface: const Color(0xFF1E1E1E),"),
    ("onSurface: Colors.white,\n      onSurface: Colors.white,", "onSurface: Colors.white,"),
    ("surface: Colors.white,\n      surface: Color(0xFFF5F5F5),", "surface: Colors.white,"),
    ("onSurface: Colors.black,\n      onSurface: Colors.black,", "onSurface: Colors.black,")
]
replace_in_file('lib/core/theme/app_theme.dart', app_theme_replacements)
# if still duplicates, regex out the second 'surface:' inside colorScheme
# Let's write a safer regex for app_theme
def fix_app_theme():
    path = 'lib/core/theme/app_theme.dart'
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    # simply remove lines with `surface: Colors.black,` and `onSurface: Colors.white,` IF they appear near `surface: const Color`
    # Actually, let's just use regex to remove any duplicate `surface:` or `onSurface:` in a block.
    # The python way:
    lines = content.split('\n')
    cleaned = []
    in_colorscheme = False
    seen_surface = False
    seen_on_surface = False
    for line in lines:
        if 'ColorScheme.' in line:
            in_colorscheme = True
            seen_surface = False
            seen_on_surface = False
        if in_colorscheme and ('});' in line or '), ' in line or ')' in line):
            if 'surface:' not in line and 'onSurface:' not in line:
                in_colorscheme = False
        
        if in_colorscheme:
            if 'surface:' in line and not 'onSurface' in line:
                if seen_surface: continue
                seen_surface = True
            elif 'onSurface:' in line:
                if seen_on_surface: continue
                seen_on_surface = True
        cleaned.append(line)
    with open(path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(cleaned))
fix_app_theme()

# 2. unused imports
def remove_unused_import(filepath, import_str):
    if not os.path.exists(filepath): return
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    with open(filepath, 'w', encoding='utf-8') as f:
        for line in lines:
            if import_str in line:
                continue
            f.write(line)

remove_unused_import('lib/core/utils/camera_filters.dart', "import 'package:flutter/material.dart';")
remove_unused_import('lib/features/auth/presentation/providers/auth_provider.dart', "import 'package:firebase_auth/firebase_auth.dart';")
remove_unused_import('lib/features/auth/presentation/screens/signup_screen.dart', "import 'package:reelify/core/theme/app_theme.dart';")
remove_unused_import('lib/features/qr_scanner/qr_scanner_screen.dart', "import 'package:reelify/core/theme/app_theme.dart';")
remove_unused_import('lib/features/settings/settings_screen.dart', "import 'package:reelify/core/theme/app_theme.dart';")
remove_unused_import('lib/features/video_feed/presentation/widgets/action_buttons.dart', "import 'package:reelify/core/theme/app_theme.dart';")
remove_unused_import('lib/features/video_feed/presentation/widgets/video_card.dart', "import 'package:reelify/core/theme/app_theme.dart';")
remove_unused_import('lib/services/notification_service.dart', "import 'dart:convert';")
remove_unused_import('test/widget_test.dart', "import 'package:flutter/material.dart';")
remove_unused_import('test/widget_test.dart', "import 'package:reelify/main.dart';")

# 3. const constructors
def add_const(filepath, old_str, new_str):
    if not os.path.exists(filepath): return
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace(old_str, new_str)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

add_const('lib/core/utils/app_router.dart', "builder: (context, state) => LoginScreen(),", "builder: (context, state) => const LoginScreen(),")
add_const('lib/core/utils/app_router.dart', "builder: (context, state) => SignupScreen(),", "builder: (context, state) => const SignupScreen(),")
add_const('lib/core/utils/app_router.dart', "builder: (context, state) => ExploreScreen(),", "builder: (context, state) => const ExploreScreen(),")

add_const('lib/core/utils/camera_filters.dart', "matrix: [\n      1", "matrix: const [\n      1")

add_const('lib/features/qr_scanner/qr_scanner_screen.dart', "border: Border.all(color: Colors.white24)", "border: Border.all(color: Colors.white24),")

# 4. unused elements
# unused _vintageMatrix in camera_filters.dart
def remove_vintage_matrix():
    path = 'lib/core/utils/camera_filters.dart'
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = re.sub(r'const List<double> _vintageMatrix = \[.*?\];', '', content, flags=re.DOTALL)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
remove_vintage_matrix()

# unused _showComingSoonDialog, optional trailing parameter in settings_screen
def fix_settings():
    path = 'lib/features/settings/settings_screen.dart'
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = re.sub(r'void _showComingSoonDialog.*?\}\n', '', content, flags=re.DOTALL)
    content = content.replace("Widget _buildListTile(BuildContext context, String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {", "Widget _buildListTile(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {")
    content = content.replace("trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white54),", "trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white54),")
    content = content.replace("builder: (context) => SettingsScreen(),", "builder: (context) => const SettingsScreen(),")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_settings()

# unused _currentIndex in video_controller_manager.dart
def fix_controller():
    path = 'lib/features/video_feed/presentation/providers/video_controller_manager.dart'
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("int _currentIndex = 0;", "")
    content = content.replace("_currentIndex = index;", "")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_controller()

# use_build_context_synchronously in explore_screen.dart
def fix_explore():
    path = 'lib/features/explore/presentation/screens/explore_screen.dart'
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("if (mounted) {", "if (!context.mounted) return;\n      if (mounted) {")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
fix_explore()
