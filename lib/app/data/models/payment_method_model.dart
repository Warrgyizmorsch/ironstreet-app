enum PaymentType { upi, card, netBanking, cod }

class PaymentMethodModel {
  final String id;
  final String name;
  final PaymentType type;
  final String details; // e.g. "xxxx xxxx xxxx 4122" or "user@upi"
  final String icon;    // icon or logo name / icon asset path
  final bool isSelected;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.type,
    required this.details,
    required this.icon,
    this.isSelected = false,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: PaymentType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] ?? 'upi'),
        orElse: () => PaymentType.upi,
      ),
      details: json['details'] ?? '',
      icon: json['icon'] ?? '',
      isSelected: json['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'details': details,
      'icon': icon,
      'isSelected': isSelected,
    };
  }

  PaymentMethodModel copyWith({
    String? id,
    String? name,
    PaymentType? type,
    String? details,
    String? icon,
    bool? isSelected,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      details: details ?? this.details,
      icon: icon ?? this.icon,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
