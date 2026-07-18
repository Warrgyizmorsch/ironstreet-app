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

  /// Maps from WooCommerce REST API response line_items
  factory OrderItemModel.fromWcJson(Map<String, dynamic> json) {
    final imageObj = json['image'] ?? {};
    final String imageUrl = imageObj['src'] ?? '';
    final double priceVal = (json['price'] ?? 0.0).toDouble();

    final product = Product(
      id: (json['product_id'] ?? 0).toString(),
      name: json['name'] ?? '',
      brand: '',
      price: priceVal,
      oldPrice: priceVal,
      discount: 0.0,
      rating: 5.0,
      reviewsCount: 1,
      image: imageUrl,
      images: [imageUrl],
      description: '',
      deliveryText: '',
      dimensions: '',
      material: 'Solid Wood', // Default fallback material
      category: '',
    );

    return OrderItemModel(
      product: product,
      quantity: json['quantity'] ?? 1,
      price: priceVal,
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
  final double totalTax;

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
    required this.totalTax,
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
      totalTax: (json['totalTax'] ?? 0.0).toDouble(),
    );
  }

  /// Maps from WooCommerce REST API /wc/v3/orders/ response object
  factory OrderModel.fromWcJson(Map<String, dynamic> json) {
    final String idVal = (json['id'] ?? '').toString();
    final String orderNum = json['number'] ?? idVal;
    
    // Parse order items
    final List<OrderItemModel> fetchedItems = (json['line_items'] as List?)
            ?.map((item) => OrderItemModel.fromWcJson(item))
            .toList() ??
        [];

    // Parse shipping address
    final shippingJson = json['shipping'] ?? {};
    final billingJson = json['billing'] ?? {};
    
    final firstName = shippingJson['first_name'] ?? '';
    final lastName = shippingJson['last_name'] ?? '';
    final phone = shippingJson['phone']?.toString().isNotEmpty == true 
        ? shippingJson['phone'].toString()
        : (billingJson['phone']?.toString() ?? '');

    final shippingAddress = AddressModel(
      id: 'wc_shipping',
      name: '$firstName $lastName'.trim(),
      phone: phone,
      addressLine1: shippingJson['address_1'] ?? '',
      addressLine2: shippingJson['address_2'] ?? '',
      city: shippingJson['city'] ?? '',
      state: shippingJson['state'] ?? '',
      postalCode: shippingJson['postcode'] ?? '',
      country: shippingJson['country'] ?? 'IN',
      addressType: 'Shipping',
      isDefault: true,
    );

    final double total = double.tryParse(json['total']?.toString() ?? '0.0') ?? 0.0;
    final double shippingCharges = double.tryParse(json['shipping_total']?.toString() ?? '0.0') ?? 0.0;
    final double discount = double.tryParse(json['discount_total']?.toString() ?? '0.0') ?? 0.0;
    final double totalTax = double.tryParse(json['total_tax']?.toString() ?? '0.0') ?? 0.0;
    final double subtotal = total - shippingCharges - totalTax + discount;

    final String paymentMethodTitle = json['payment_method_title'] ?? '';
    final String paymentMethodCode = json['payment_method'] ?? '';
    final String transactionId = json['transaction_id'] ?? '';

    // Order date parsing
    DateTime orderDateVal = DateTime.now();
    try {
      if (json['date_created'] != null) {
        orderDateVal = DateTime.parse(json['date_created']);
      }
    } catch (_) {}

    return OrderModel(
      id: idVal,
      orderNumber: orderNum,
      items: fetchedItems,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethodTitle.isNotEmpty ? paymentMethodTitle : 'Payment Gateway',
      paymentDetails: transactionId.isNotEmpty 
          ? transactionId 
          : (paymentMethodCode.isNotEmpty ? paymentMethodCode : 'Direct'),
      orderDate: orderDateVal,
      status: json['status'] ?? 'pending',
      subtotal: subtotal,
      discount: discount,
      deliveryCharges: shippingCharges,
      totalAmount: total,
      totalTax: totalTax,
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
      'totalTax': totalTax,
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
    double? totalTax,
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
      totalTax: totalTax ?? this.totalTax,
    );
  }
}
