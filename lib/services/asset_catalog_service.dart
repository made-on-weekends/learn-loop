enum AssetComplexity { beginner, developing, proficient }

class ColoringAsset {
  final String id;
  final String title;
  final String slug;
  final String category;
  final String subcategory;
  final List<String> tags;
  final int minAge;
  final int maxAge;
  final AssetComplexity complexity;
  final bool enabled;

  const ColoringAsset({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
    required this.subcategory,
    required this.tags,
    this.minAge = 3,
    this.maxAge = 8,
    this.complexity = AssetComplexity.beginner,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'category': category,
      'subcategory': subcategory,
      'tags': tags,
      'minAge': minAge,
      'maxAge': maxAge,
      'complexity': complexity.name,
      'enabled': enabled,
    };
  }

  factory ColoringAsset.fromJson(Map<String, dynamic> json) {
    return ColoringAsset(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      tags: (json['tags'] as List).cast<String>(),
      minAge: json['minAge'] as int? ?? 3,
      maxAge: json['maxAge'] as int? ?? 8,
      complexity: AssetComplexity.values.firstWhere(
        (e) => e.name == json['complexity'],
        orElse: () => AssetComplexity.beginner,
      ),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

class AssetCatalogService {
  static const List<ColoringAsset> _builtinAssets = [
    // Animals
    ColoringAsset(
      id: 'animal_apple_bear',
      title: 'Cute Bear',
      slug: 'cute-bear',
      category: 'Animal',
      subcategory: 'Wild',
      tags: ['bear', 'animal', 'wild', 'teddy', 'cute'],
      minAge: 3,
      maxAge: 7,
      complexity: AssetComplexity.beginner,
    ),
    ColoringAsset(
      id: 'animal_farm_cow',
      title: 'Farm Cow',
      slug: 'farm-cow',
      category: 'Animal',
      subcategory: 'Farm',
      tags: ['cow', 'farm', 'animal', 'milk'],
      minAge: 3,
      maxAge: 7,
      complexity: AssetComplexity.beginner,
    ),
    ColoringAsset(
      id: 'animal_farm_duck',
      title: 'Little Duck',
      slug: 'little-duck',
      category: 'Animal',
      subcategory: 'Farm',
      tags: ['duck', 'bird', 'pond', 'farm'],
      minAge: 2,
      maxAge: 6,
      complexity: AssetComplexity.beginner,
    ),
    ColoringAsset(
      id: 'animal_sea_dolphin',
      title: 'Playful Dolphin',
      slug: 'playful-dolphin',
      category: 'Animal',
      subcategory: 'Sea',
      tags: ['dolphin', 'sea', 'ocean', 'fish', 'water'],
      minAge: 4,
      maxAge: 8,
      complexity: AssetComplexity.developing,
    ),

    // Vehicles
    ColoringAsset(
      id: 'vehicle_land_car',
      title: 'City Car',
      slug: 'city-car',
      category: 'Vehicle',
      subcategory: 'Land',
      tags: ['car', 'vehicle', 'wheels', 'transport'],
      minAge: 3,
      maxAge: 7,
      complexity: AssetComplexity.beginner,
    ),
    ColoringAsset(
      id: 'vehicle_air_rocket',
      title: 'Space Rocket',
      slug: 'space-rocket',
      category: 'Vehicle',
      subcategory: 'Space',
      tags: ['rocket', 'space', 'vehicle', 'stars', 'moon'],
      minAge: 4,
      maxAge: 8,
      complexity: AssetComplexity.developing,
    ),

    // Nature & Food
    ColoringAsset(
      id: 'food_fruit_apple',
      title: 'Juicy Apple',
      slug: 'juicy-apple',
      category: 'Food',
      subcategory: 'Fruit',
      tags: ['apple', 'fruit', 'food', 'healthy', 'tree'],
      minAge: 2,
      maxAge: 6,
      complexity: AssetComplexity.beginner,
    ),
    ColoringAsset(
      id: 'nature_tree',
      title: 'Big Green Tree',
      slug: 'big-tree',
      category: 'Nature',
      subcategory: 'Plants',
      tags: ['tree', 'nature', 'leaves', 'forest'],
      minAge: 2,
      maxAge: 6,
      complexity: AssetComplexity.beginner,
    ),

    // Space & Geometry
    ColoringAsset(
      id: 'space_star',
      title: 'Shining Star',
      slug: 'shining-star',
      category: 'Space',
      subcategory: 'Sky',
      tags: ['star', 'space', 'sky', 'night', 'shape'],
      minAge: 2,
      maxAge: 6,
      complexity: AssetComplexity.beginner,
    ),
  ];

  static List<ColoringAsset> getAll() {
    return List.unmodifiable(_builtinAssets.where((a) => a.enabled));
  }

  static List<ColoringAsset> getByCategory(String category) {
    final catLower = category.toLowerCase();
    return List.unmodifiable(
      _builtinAssets.where(
        (a) => a.enabled && a.category.toLowerCase() == catLower,
      ),
    );
  }

  static List<String> getCategories() {
    return _builtinAssets.map((a) => a.category).toSet().toList()..sort();
  }

  static List<ColoringAsset> search(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return getAll();
    return List.unmodifiable(
      _builtinAssets.where((a) {
        if (!a.enabled) return false;
        final titleMatch = a.title.toLowerCase().contains(cleanQuery);
        final catMatch = a.category.toLowerCase().contains(cleanQuery);
        final tagMatch = a.tags.any(
          (t) => t.toLowerCase().contains(cleanQuery),
        );
        return titleMatch || catMatch || tagMatch;
      }),
    );
  }

  static ColoringAsset? getById(String id) {
    try {
      return _builtinAssets.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
