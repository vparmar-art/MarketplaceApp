import 'product.dart';
import 'user.dart';

class OrderItem {
  final int id;
  final int? orderId;
  final Product product;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    this.orderId,
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': orderId,
      'product': product.toJson(),
      'quantity': quantity,
      'price': price,
    };
  }

  double get total => price * quantity;
}

class OrderDocument {
  final int id;
  final int orderId;
  final String document;
  final String documentType;
  final DateTime uploadedAt;

  OrderDocument({
    required this.id,
    required this.orderId,
    required this.document,
    required this.documentType,
    required this.uploadedAt,
  });
  
  String get name => document.split('/').last;

  factory OrderDocument.fromJson(Map<String, dynamic> json) {
    return OrderDocument(
      id: json['id'],
      orderId: json['order'],
      document: json['document'],
      documentType: json['document_type'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': orderId,
      'document': document,
      'document_type': documentType,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}

class Order {
  final int id;
  final String? orderNumber;
  final User buyer;
  final String status;
  final String? orderStatus;
  final String? shippingAddress;
  final String? shippingCity;
  final String? shippingState;
  final String? shippingCountry;
  final String? shippingZipCode;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;
  final String? paymentMethod;
  final String? paymentStatus;
  final double? totalAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;
  final List<OrderDocument>? documents;

  Order({
    required this.id,
    this.orderNumber,
    required this.buyer,
    required this.status,
    this.orderStatus,
    this.shippingAddress,
    this.shippingCity,
    this.shippingState,
    this.shippingCountry,
    this.shippingZipCode,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    this.paymentMethod,
    this.paymentStatus,
    this.totalAmount,
    this.createdAt,
    this.updatedAt,
    required this.items,
    this.documents = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['order_number'],
      buyer: User.fromJson(json['buyer']),
      status: json['status'],
      orderStatus: json['order_status'],
      shippingAddress: json['shipping_address'],
      shippingCity: json['shipping_city'],
      shippingState: json['shipping_state'],
      shippingCountry: json['shipping_country'],
      shippingZipCode: json['shipping_zip_code'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      zipCode: json['zip_code'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      totalAmount: json['total_amount']?.toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((doc) => OrderDocument.fromJson(doc))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'buyer': buyer.toJson(),
      'status': status,
      'order_status': orderStatus,
      'shipping_address': shippingAddress,
      'shipping_city': shippingCity,
      'shipping_state': shippingState,
      'shipping_country': shippingCountry,
      'shipping_zip_code': shippingZipCode,
      'city': city,
      'state': state,
      'country': country,
      'zip_code': zipCode,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'total_amount': totalAmount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'documents': documents?.map((doc) => doc.toJson()).toList(),
    };
  }

  double get total => items.fold(0, (sum, item) => sum + item.total);
  
  double get calculatedTotalAmount => total;
  
  String get formattedStatus => status;
  
  String get formattedPaymentMethod => paymentMethod ?? 'Not specified';

  String get formattedShippingAddress {
    final parts = [
      shippingAddress,
      shippingCity,
      shippingState,
      shippingCountry,
      shippingZipCode,
    ].where((part) => part != null && part.isNotEmpty).toList();
    
    return parts.join(', ');
  }

  Order copyWith({
    int? id,
    String? orderNumber,
    User? buyer,
    String? status,
    String? orderStatus,
    String? shippingAddress,
    String? shippingCity,
    String? shippingState,
    String? shippingCountry,
    String? shippingZipCode,
    String? city,
    String? state,
    String? country,
    String? zipCode,
    String? paymentMethod,
    String? paymentStatus,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
    List<OrderDocument>? documents,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      buyer: buyer ?? this.buyer,
      status: status ?? this.status,
      orderStatus: orderStatus ?? this.orderStatus,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      shippingCity: shippingCity ?? this.shippingCity,
      shippingState: shippingState ?? this.shippingState,
      shippingCountry: shippingCountry ?? this.shippingCountry,
      shippingZipCode: shippingZipCode ?? this.shippingZipCode,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      documents: documents ?? this.documents,
    );
  }
}