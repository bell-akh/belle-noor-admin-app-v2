import 'dart:io';

class ProductCategory {
  final String? id;
  final String name;
  final String? imageUrl;
  final File? imageFile;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? description;

  ProductCategory({
    this.id,
    required this.name,
    this.imageUrl,
    this.imageFile,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.description,
  });

  ProductCategory copyWith({
    String? id,
    String? name,
    String? imageUrl,
    File? imageFile,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? description,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      imageFile: imageFile ?? this.imageFile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'is_active': isActive,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    // Handle image variants from backend
    String? imageUrl;
    if (json['image'] != null && json['image'] is List) {
      final variants = json['image'] as List;
      if (variants.isNotEmpty) {
        // Try to find medium resolution first
        final medium = variants.firstWhere(
          (variant) => variant['resolution'] == 'md',
          orElse: () => variants.first,
        );
        imageUrl = medium['url'];
      }
    } else {
      imageUrl = json['image_url'];
    }

    return ProductCategory(
      id: json['id'],
      name: json['name'] ?? '',
      imageUrl: imageUrl,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      description: json['description'] ?? json['desc'],
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'])
          : null,
    );
  }

  @override
  String toString() {
    return 'ProductCategory(id: $id, name: $name, isActive: $isActive)';
  }
}