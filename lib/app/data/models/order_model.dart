import 'product_model.dart';
import 'address_model.dart';

class OrderItemModel {
  final Product product;
  final int quantity;
  final double price; // price at the time of purchase

  OrderItemModel({
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'price': price,
    };
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final List<OrderItemModel> items;
  final AddressModel shippingAddress;
  final String paymentMethod; // e.g. "UPI", "Credit Card", "COD"
  final String paymentDetails; // e.g. "xxxx-4122" or "UPI transaction ID"
  final DateTime orderDate;
  final String status; // "Pending", "Processing", "Dispatched", "Delivered", "Cancelled"
  final double subtotal;
  final double discount;
  final double deliveryCharges;
  final double totalAmount;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.paymentDetails,
    required this.orderDate,
    required this.status,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharges,
    required this.totalAmount,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      shippingAddress: AddressModel.fromJson(json['shippingAddress']),
      paymentMethod: json['paymentMethod'] ?? '',
      paymentDetails: json['paymentDetails'] ?? '',
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'Pending',
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      deliveryCharges: (json['deliveryCharges'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'shippingAddress': shippingAddress.toJson(),
      'paymentMethod': paymentMethod,
      'paymentDetails': paymentDetails,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
      'subtotal': subtotal,
      'discount': discount,
      'deliveryCharges': deliveryCharges,
      'totalAmount': totalAmount,
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    List<OrderItemModel>? items,
    AddressModel? shippingAddress,
    String? paymentMethod,
    String? paymentDetails,
    DateTime? orderDate,
    String? status,
    double? subtotal,
    double? discount,
    double? deliveryCharges,
    double? totalAmount,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      deliveryCharges: deliveryCharges ?? this.deliveryCharges,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
