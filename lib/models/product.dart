import 'dart:io';

enum ProductType { western, ethnic, all }

class Product {
  final String? id;
  final String name;
  final String category;
  final double newPrice;
  final double? oldPrice;
  final int quantity;
  final ProductType type;
  final String? imageUrl;
  final File? imageFile;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.newPrice,
    this.oldPrice,
    required this.quantity,
    required this.type,
    this.imageUrl,
    this.imageFile,
    this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? newPrice,
    double? oldPrice,
    int? quantity,
    ProductType? type,
    String? imageUrl,
    File? imageFile,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      newPrice: newPrice ?? this.newPrice,
      oldPrice: oldPrice ?? this.oldPrice,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      imageFile: imageFile ?? this.imageFile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'new_price': newPrice,
      'old_price': oldPrice,
      'quantity': quantity,
      'type': type.name,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
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

    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      newPrice: (json['new_price'] ?? 0).toDouble(),
      oldPrice: json['old_price']?.toDouble(),
      quantity: json['quantity'] ?? 0,
      type: ProductType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProductType.all,
      ),
      imageUrl: imageUrl,
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'])
          : null,
    );
  }

  bool get hasDiscount => oldPrice != null && oldPrice! > newPrice;
  
  double get discountPercentage => hasDiscount 
      ? ((oldPrice! - newPrice) / oldPrice!) * 100 
      : 0.0;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, category: $category, newPrice: $newPrice, type: $type)';
  }
}