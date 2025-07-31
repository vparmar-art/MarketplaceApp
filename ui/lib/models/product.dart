import 'user.dart';

class Category {
  final int id;
  final String name;
  final String? description;
  final String? image;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
    };
  }
}

// ProductImage class removed - using only the image field in Product model

class ProductSpecification {
  final int id;
  final int productId;
  final String name;
  final String value;

  ProductSpecification({
    required this.id,
    required this.productId,
    required this.name,
    required this.value,
  });

  factory ProductSpecification.fromJson(Map<String, dynamic> json) {
    return ProductSpecification(
      id: json['id'],
      productId: json['product'],
      name: json['name'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': productId,
      'name': name,
      'value': value,
    };
  }
}

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final int quantity;
  final Category category;
  final User? seller;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String image;
  final List<ProductSpecification> specifications;
  final double? averageRating;
  final int? reviewCount;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.quantity,
    required this.category,
    this.seller,
    required this.createdAt,
    required this.updatedAt,
    required this.image,
    required this.specifications,
    this.averageRating,
    this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      quantity: json['available_quantity'],
      category: Category.fromJson(json['category']),
      seller: json['seller'] != null ? User.fromJson(json['seller']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      image: json['image'] ?? '',
      specifications: (json['specifications'] as List<dynamic>? ?? [])
          .map((spec) => ProductSpecification.fromJson(spec))
          .toList(),
      averageRating: json['average_rating']?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'description': description,
      'price': price,
      'available_quantity': quantity,
      'category': category.toJson(),
      'seller': seller?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'image': image,
      'specifications': specifications.map((spec) => spec.toJson()).toList(),
      'average_rating': averageRating,
      'review_count': reviewCount,
    };
  }

  String get mainImageUrl {
    return image.isNotEmpty ? image : 'https://via.placeholder.com/150';
  }

  Product copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    int? quantity,
    Category? category,
    User? seller,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? image,
    List<ProductSpecification>? specifications,
    double? averageRating,
    int? reviewCount,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      seller: seller ?? this.seller,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      image: image ?? this.image,
      specifications: specifications ?? this.specifications,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}

class Review {
  final int id;
  final int productId;
  final User user;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.user,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      productId: json['product'],
      user: User.fromJson(json['user']),
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': productId,
      'user': user.toJson(),
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}