import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    
    # 1. withOpacity -> withValues(alpha: ...)
    content = re.sub(r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)', content)
    
    # 2. app_theme updates
    if "app_theme.dart" in filepath:
        content = re.sub(r'background:\s*', r'surface: ', content)
        content = re.sub(r'onBackground:\s*', r'onSurface: ', content)

    # 3. settings_screen activeColor -> activeThumbColor
    if "settings_screen.dart" in filepath:
        content = re.sub(r'activeColor:', r'activeThumbColor:', content)
        
    # 4. upload_screen value -> initialValue
    # In DropdownButtonFormField, 'value' is actually NOT deprecated for the current selected value. 
    # Wait, the warning says "Use initialValue instead. This feature was deprecated after v3.33.0-1.0.pre" 
    # Actually wait, DropdownButtonFormField value is deprecated recently. Let's fix it:
    if "upload_screen.dart" in filepath:
        content = re.sub(r'value:\s*_selectedCategory,', r'initialValue: _selectedCategory,', content)

    # 5. print -> debugPrint
    if "storage_service.dart" in filepath:
        content = re.sub(r'\bprint\(', r'debugPrint(', content)
        if 'debugPrint' in content and 'import \'package:flutter/foundation.dart\';' not in content:
            content = "import 'package:flutter/foundation.dart';\n" + content
            
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
