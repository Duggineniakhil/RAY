
class CameraFilter {
  final String name;
  final String category;
  final String description;
  final String suggestedUse;
  final List<double>? matrix;

  const CameraFilter({
    required this.name,
    required this.category,
    required this.description,
    required this.suggestedUse,
    this.matrix,
  });
}

const List<double> _grayscaleMatrix = [
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0,      0,      0,      1, 0,
];

const List<double> _sepiaMatrix = [
  0.393, 0.769, 0.189, 0, 0,
  0.349, 0.686, 0.168, 0, 0,
  0.272, 0.534, 0.131, 0, 0,
  0,     0,     0,     1, 0,
];

const List<double> _warmMatrix = [
  1.1, 0,   0,   0, 0,
  0,   1.0, 0,   0, 0,
  0,   0,   0.9, 0, 0,
  0,   0,   0,   1, 0,
];

const List<double> _coolMatrix = [
  0.9, 0,   0,   0, 0,
  0,   1.0, 0,   0, 0,
  0,   0,   1.2, 0, 0,
  0,   0,   0,   1, 0,
];



const List<double> _beautyMatrix = [
  1.1, 0.0, 0.0, 0, 15,
  0.0, 1.1, 0.0, 0, 15,
  0.0, 0.0, 1.1, 0, 15,
  0,   0,   0,   1, 0,
];

// Combine two matrices helper
List<double> combineMatrices(List<double> m1, List<double> m2) {
  // Simple approximation for combining color matrices for variety
  return List.generate(20, (i) => (m1[i] + m2[i]) / 2);
}

final List<CameraFilter> appFilters = [
  // NORMAL
  const CameraFilter(
    name: 'Normal',
    category: 'Basic',
    description: 'No filter applied',
    suggestedUse: 'Everyday',
    matrix: null,
  ),

  // FACE / AR SIMULATED
  const CameraFilter(
    name: 'Dog with Tongue',
    category: 'Face/AR',
    description: 'Playful warm tones for animal overlay',
    suggestedUse: 'Selfie fun',
    matrix: _warmMatrix,
  ),
  CameraFilter(
    name: 'Flower Crown',
    category: 'Face/AR',
    description: 'Bright and aesthetic glow',
    suggestedUse: 'Beauty selfie',
    matrix: combineMatrices(_beautyMatrix, _warmMatrix),
  ),
  const CameraFilter(
    name: 'Vogue Noir',
    category: 'Face/AR',
    description: 'High contrast B&W magazine style',
    suggestedUse: 'Fashion portrait',
    matrix: _grayscaleMatrix,
  ),
  const CameraFilter(
    name: 'Face Swap',
    category: 'Face/AR',
    description: 'Clear lighting for face swapping',
    suggestedUse: 'Selfie with friends',
    matrix: _beautyMatrix,
  ),
  const CameraFilter(
    name: 'Crying Face',
    category: 'Face/AR',
    description: 'Dramatic blue-tinted sadness',
    suggestedUse: 'Comedic selfie',
    matrix: _coolMatrix,
  ),
  const CameraFilter(
    name: 'Fairy Dust',
    category: 'Face/AR',
    description: 'Fantasy beauty enhancement',
    suggestedUse: 'Fantasy selfie',
    matrix: [1.2, 0, 0.2, 0, 10, 0, 1.0, 0.1, 0, 10, 0, 0, 1.3, 0, 15, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Cat Whisker',
    category: 'Face/AR',
    description: 'Soft lighting for animal overlay',
    suggestedUse: 'Cute selfie',
    matrix: _beautyMatrix,
  ),

  // CLASSIC PHOTO AESTHETICS
  const CameraFilter(
    name: 'Lumiere',
    category: 'Classic',
    description: 'Bright exposure',
    suggestedUse: 'Darkly lit areas',
    matrix: [1.3, 0, 0, 0, 20, 0, 1.3, 0, 0, 20, 0, 0, 1.3, 0, 20, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Sepia Dusk',
    category: 'Classic',
    description: 'Warm vintage tone',
    suggestedUse: 'Sunset photos',
    matrix: _sepiaMatrix,
  ),
  const CameraFilter(
    name: 'Noir',
    category: 'Classic',
    description: 'High contrast black & white',
    suggestedUse: 'Street photography',
    matrix: [0.3, 0.6, 0.1, 0, -20, 0.3, 0.6, 0.1, 0, -20, 0.3, 0.6, 0.1, 0, -20, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Onyx',
    category: 'Classic',
    description: 'Moody B&W',
    suggestedUse: 'Dark aesthetic',
    matrix: [0.2, 0.5, 0.1, 0, -40, 0.2, 0.5, 0.1, 0, -40, 0.2, 0.5, 0.1, 0, -40, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Faded',
    category: 'Classic',
    description: 'Matte tone',
    suggestedUse: 'Urban landscape',
    matrix: [0.8, 0, 0, 0, 30, 0, 0.8, 0, 0, 30, 0, 0, 0.8, 0, 30, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Vivid',
    category: 'Classic',
    description: 'Saturated colors',
    suggestedUse: 'Nature & food',
    matrix: [1.4, 0, 0, 0, 0, 0, 1.4, 0, 0, 0, 0, 0, 1.4, 0, 0, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Pastel',
    category: 'Classic',
    description: 'Soft pastel tones',
    suggestedUse: 'Portraits',
    matrix: [0.9, 0.1, 0, 0, 20, 0, 0.9, 0.1, 0, 20, 0, 0, 1.0, 0, 20, 0, 0, 0, 1, 0],
  ),

  // GEOGRAPHICAL / TRAVEL
  const CameraFilter(
    name: 'Santorini',
    category: 'Travel',
    description: 'Bright blues and white tones',
    suggestedUse: 'Beach/Sea landscape',
    matrix: [0.9, 0, 0, 0, 10, 0, 0.9, 0, 0, 10, 0, 0.1, 1.3, 0, 20, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Sahara',
    category: 'Travel',
    description: 'Golden sand tones',
    suggestedUse: 'Desert/Daylight',
    matrix: [1.2, 0.2, 0, 0, 10, 0, 1.0, 0, 0, 5, 0, 0, 0.8, 0, -10, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Tokyo',
    category: 'Travel',
    description: 'Neon cool tones',
    suggestedUse: 'Night cityscapes',
    matrix: [0.8, 0, 0.2, 0, 0, 0, 0.9, 0.1, 0, 0, 0.2, 0, 1.3, 0, 10, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Reykjavik',
    category: 'Travel',
    description: 'Cold muted palette',
    suggestedUse: 'Winter/Mountain',
    matrix: [0.8, 0, 0, 0, -10, 0, 0.85, 0, 0, -5, 0, 0, 1.1, 0, 10, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Venice',
    category: 'Travel',
    description: 'Romantic soft tones',
    suggestedUse: 'Architecture',
    matrix: [1.1, 0.1, 0, 0, 10, 0, 1.0, 0, 0, 5, 0, 0, 0.9, 0, 0, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Sedona',
    category: 'Travel',
    description: 'Rust earth tones',
    suggestedUse: 'Canyons/Nature',
    matrix: [1.2, 0.3, 0, 0, 15, 0, 0.9, 0, 0, 0, 0, 0, 0.7, 0, 0, 0, 0, 0, 1, 0],
  ),

  // MOOD BASED
  const CameraFilter(
    name: 'Euphoria',
    category: 'Mood',
    description: 'Dreamy glow',
    suggestedUse: 'Party/Fun',
    matrix: [1.2, 0, 0.2, 0, 10, 0, 1.0, 0, 0, 10, 0.2, 0, 1.2, 0, 20, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Solitude',
    category: 'Mood',
    description: 'Cold desaturated tones',
    suggestedUse: 'Melancholy portrait',
    matrix: [0.7, 0, 0, 0, -10, 0, 0.7, 0, 0, -10, 0, 0, 0.8, 0, 0, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Afterglow',
    category: 'Mood',
    description: 'Sunset warmth',
    suggestedUse: 'Golden hour',
    matrix: [1.3, 0, 0, 0, 10, 0, 1.1, 0, 0, 5, 0, 0, 0.8, 0, 0, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Haze',
    category: 'Mood',
    description: 'Misty softness',
    suggestedUse: 'Early morning',
    matrix: [0.9, 0, 0, 0, 40, 0, 0.9, 0, 0, 40, 0, 0, 0.9, 0, 50, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Obsidian',
    category: 'Mood',
    description: 'Dark shadows',
    suggestedUse: 'Moody aesthetic',
    matrix: [0.6, 0, 0, 0, -20, 0, 0.6, 0, 0, -20, 0, 0, 0.6, 0, -20, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Vibrance',
    category: 'Mood',
    description: 'Pop colors',
    suggestedUse: 'Artistic shot',
    matrix: [1.5, 0, 0, 0, 0, 0, 1.5, 0, 0, 0, 0, 0, 1.5, 0, 0, 0, 0, 0, 1, 0],
  ),

  // FILM & RETRO
  const CameraFilter(
    name: 'Kodak 94',
    category: 'Film',
    description: 'Yellow film tint',
    suggestedUse: 'Vintage feel',
    matrix: [1.1, 0.1, 0, 0, 15, 0, 1.1, 0, 0, 15, 0, 0, 0.8, 0, 0, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Polaroid',
    category: 'Film',
    description: 'Faded instant camera look',
    suggestedUse: 'Memories',
    matrix: [1.0, 0, 0, 0, 20, 0, 0.9, 0.1, 0, 10, 0, 0, 0.8, 0, 10, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Super 8',
    category: 'Film',
    description: 'Warm film jitter',
    suggestedUse: 'Retro video',
    matrix: [1.2, 0.2, 0, 0, -10, 0, 1.0, 0, 0, -10, 0, 0, 0.8, 0, -10, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'VHS',
    category: 'Film',
    description: 'Glitch effect tone',
    suggestedUse: '90s vibe',
    matrix: [1.1, 0, 0.2, 0, 0, 0.2, 1.1, 0, 0, 0, 0, 0, 1.1, 0, 0, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Daguerre',
    category: 'Film',
    description: 'Antique grain B&W',
    suggestedUse: 'Historical feel',
    matrix: [0.4, 0.4, 0.2, 0, 10, 0.3, 0.5, 0.2, 0, 10, 0.2, 0.4, 0.4, 0, 10, 0, 0, 0, 1, 0],
  ),

  // SPECIAL EFFECTS (Simulated with intense matrices)
  const CameraFilter(
    name: 'Cyberpunk',
    category: 'Special',
    description: 'Neon pink and blue',
    suggestedUse: 'Nightlife',
    matrix: [1.5, 0, 0.5, 0, 0, 0, 0.8, 0, 0, 0, 0.5, 0, 1.5, 0, 0, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Holo',
    category: 'Special',
    description: 'Holographic shiny tint',
    suggestedUse: 'Items/Products',
    matrix: [0.8, 0.5, 0.5, 0, 20, 0.5, 0.8, 0.5, 0, 20, 0.5, 0.5, 0.8, 0, 20, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Inferno',
    category: 'Special',
    description: 'Intense red tones',
    suggestedUse: 'Creative portraits',
    matrix: [1.8, 0, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Arctic',
    category: 'Special',
    description: 'Intense cold wrap',
    suggestedUse: 'Creative portraits',
    matrix: [0.5, 0, 0, 0, 0, 0, 0.8, 0, 0, 0, 0, 0, 1.8, 0, 20, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Emerald',
    category: 'Special',
    description: 'Deep green vibe',
    suggestedUse: 'Forest/Nature',
    matrix: [0.5, 0, 0, 0, 0, 0, 1.5, 0, 0, 10, 0, 0, 0.5, 0, 0, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Solarize',
    category: 'Special',
    description: 'Inverted harsh colors',
    suggestedUse: 'Abstract',
    matrix: [-1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Golden Hour',
    category: 'Special',
    description: 'Intense gold saturation',
    suggestedUse: 'Selfies',
    matrix: [1.2, 0.2, 0, 0, 20, 0, 1.1, 0, 0, 15, 0, 0, 0.5, 0, -10, 0, 0, 0, 1, 0],
  ),
  const CameraFilter(
    name: 'Matrix',
    category: 'Special',
    description: 'Green digital tint',
    suggestedUse: 'Tech aesthetic',
    matrix: [0, 0.8, 0, 0, 0, 0, 1.2, 0, 0, 0, 0, 0.8, 0, 0, 0, 0, 0, 0, 1, 0],
  ),
];
