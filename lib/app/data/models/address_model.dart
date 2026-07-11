class AddressModel {
  final String id;
  final String name;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String addressType; // e.g. "Home", "Work", "Other"
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.addressType,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? 'India',
      addressType: json['addressType'] ?? 'Home',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'addressType': addressType,
      'isDefault': isDefault,
    };
  }

  AddressModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? addressType,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      addressType: addressType ?? this.addressType,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get fullAddress => 
      "$addressLine1, ${addressLine2.isNotEmpty ? '$addressLine2, ' : ''}$city, $state - $postalCode";

  Map<String, dynamic> toWcAddress() {
    final parts = name.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts[0] : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    // Normalize State to WooCommerce 2-letter codes for India
    String normalizedState = state.trim();
    final stateMap = {
      'andhra pradesh': 'AP',
      'arunachal pradesh': 'AR',
      'assam': 'AS',
      'bihar': 'BR',
      'chhattisgarh': 'CT',
      'goa': 'GA',
      'gujarat': 'GJ',
      'haryana': 'HR',
      'himachal pradesh': 'HP',
      'jammu and kashmir': 'JK',
      'jharkhand': 'JH',
      'karnataka': 'KA',
      'kerala': 'KL',
      'madhya pradesh': 'MP',
      'maharashtra': 'MH',
      'manipur': 'MN',
      'meghalaya': 'ML',
      'mizoram': 'MZ',
      'nagaland': 'NL',
      'odisha': 'OD',
      'orissa': 'OD',
      'punjab': 'PB',
      'rajasthan': 'RJ',
      'sikkim': 'SK',
      'tamil nadu': 'TN',
      'telangana': 'TS',
      'tripura': 'TR',
      'uttar pradesh': 'UP',
      'uttarakhand': 'UK',
      'west bengal': 'WB',
      'delhi': 'DL',
      'andaman and nicobar': 'AN',
      'chandigarh': 'CH',
      'dadra and nagar haveli': 'DN',
      'daman and diu': 'DD',
      'lakshadweep': 'LD',
      'puducherry': 'PY',
      'pondicherry': 'PY',
      'ladakh': 'LA',
    };

    final key = normalizedState.toLowerCase();
    if (stateMap.containsKey(key)) {
      normalizedState = stateMap[key]!;
    } else {
      // Clean it up to uppercase
      final cleanState = normalizedState.toUpperCase();
      final validStates = [
        'AN', 'AP', 'AR', 'AS', 'BR', 'CH', 'CT', 'DD', 'DH', 'DL', 'DN', 'GA',
        'GJ', 'HP', 'HR', 'JH', 'JK', 'KA', 'KL', 'LA', 'LD', 'MH', 'ML', 'MN',
        'MP', 'MZ', 'NL', 'OD', 'PB', 'PY', 'RJ', 'SK', 'TS', 'TN', 'TR', 'UP',
        'UK', 'WB'
      ];
      if (validStates.contains(cleanState)) {
        normalizedState = cleanState;
      }
    }

    return {
      'first_name': firstName,
      'last_name': lastName,
      'company': '',
      'address_1': addressLine1,
      'address_2': addressLine2,
      'city': city,
      'state': normalizedState,
      'postcode': postalCode,
      'country': country == 'India' ? 'IN' : country,
      'phone': phone,
    };
  }
}
