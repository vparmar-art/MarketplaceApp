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

class ProductImage {
  final int id;
  final int productId;
  final String image;
  final bool isMain;

  ProductImage({
    required this.id,
    required this.productId,
    required this.image,
    required this.isMain,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      productId: json['product'],
      image: json['image'],
      isMain: json['is_main'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': productId,
      'image': image,
      'is_main': isMain,
    };
  }
}

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
  final User seller;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProductImage> images;
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
    required this.seller,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
    required this.specifications,
    this.averageRating,
    this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      category: Category.fromJson(json['category']),
      seller: User.fromJson(json['seller']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      images: (json['images'] as List<dynamic>)
          .map((image) => ProductImage.fromJson(image))
          .toList(),
      specifications: (json['specifications'] as List<dynamic>)
          .map((spec) => ProductSpecification.fromJson(spec))
          .toList(),
      averageRating: json['average_rating']?.toDouble(),
      reviewCount: json['review_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'quantity': quantity,
      'category': category.toJson(),
      'seller': seller.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'images': images.map((image) => image.toJson()).toList(),
      'specifications': specifications.map((spec) => spec.toJson()).toList(),
      'average_rating': averageRating,
      'review_count': reviewCount,
    };
  }

  String get mainImageUrl {
    final mainImage = images.firstWhere(
      (image) => image.isMain,
      orElse: () => images.isNotEmpty ? images.first : ProductImage(
        id: 0,
        productId: id,
        image: '',
        isMain: true,
      ),
    );
    return mainImage.image;
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
    List<ProductImage>? images,
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
      images: images ?? this.images,
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