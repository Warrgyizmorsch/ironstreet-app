import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final priceFormatter = NumberFormat.currency(
  locale: 'hi_IN',
  symbol: '₹',
  decimalDigits: 0,
);

void createLog(dynamic message) {
  if (!kDebugMode) return; // Only show in debug mode

  String output;
  if (message is Map || message is List) {
    // Pretty-print JSON
    output = const JsonEncoder.withIndent('  ').convert(message);
  } else {
    // Convert anything else to a string
    output = message.toString();
  }

  // --- Define a title and line prefix ---
  const String logTitle = "[MF App Log]";
  const String linePrefix = "│ "; // Box-drawing character

  // --- Define borders (you can change the length) ---
  final String topBorder = "┌${"─" * 80}";
  final String bottomBorder = "└${"─" * 80}";

  // --- Print the formatted log ---
  if (kDebugMode) {
    // Start with a newline for space
    print("\n$topBorder");
    print("$linePrefix $logTitle"); // Print the title
    print(linePrefix); // Print a blank line inside the box

    // Print each line of the actual message
    output.split('\n').forEach((line) {
      if (kDebugMode) {
        print("$linePrefix $line");
      }
    });

    print("$bottomBorder\n"); // End with a newline
  }
}

class UHelperFunction {
  static String getGreetingMsg() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // 5am -  12pm
      return 'Good Morning';
    } else if (hour >= 12 && hour < 16) {
      // 12pm - 4pm
      return 'Good Afternoon';
    }
    if (hour >= 16 && hour < 19) {
      // 4pm - 7pm
      return 'Good Evening';
    } else {
      return 'Good night';
    }
  }
}
String formatCurrency(double amount) {
  final absAmount = amount.abs();

  if (absAmount >= 10000000) {
    // Crore
    return "₹${(amount / 10000000).toStringAsFixed(2)}Cr";
  } else if (absAmount >= 100000) {
    // Lakh
    return "₹${(amount / 100000).toStringAsFixed(2)}L";
  } else if (absAmount >= 1000) {
    // Thousand
    return "₹${(amount / 1000).toStringAsFixed(1)}K";
  } else {
    return "₹${amount.toStringAsFixed(0)}";
  }
}
///////////////// -------------- Extract Fund Manager ----------- //////////////////
List<String> parseFundManagers(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return [];
  }

  String text = raw;

  // 1. Remove text inside parentheses (e.g., "(dedicated for...)")
  text = text.replaceAll(RegExp(r'\(.*?\)', dotAll: true), '');

  // 2. Replace "FM" labels (FM 1, FM-2, FM) with a comma to separate them
  //    This handles cases like "Name FM 1" -> "Name ,"
  text = text.replaceAll(RegExp(r'FM\s*[-]?\s*\d*', caseSensitive: false), ',');

  // 3. Normalize other separators (&, " and ", newline) to comma
  text = text.replaceAll(RegExp(r'[&\n]| and ', caseSensitive: false), ',');

  // 4. Split by comma and clean up each item
  List<String> managers = [];

  for (String part in text.split(',')) {
    // Remove leading hyphens, dots, or whitespace
    String clean = part.replaceAll(RegExp(r'^[\s\-\.]+'), '').trim();

    // 5. FILTER: Ignore empty strings and "Not Applicable" placeholders
    if (clean.isNotEmpty &&
        !clean.toLowerCase().contains('not applicable') &&
        clean.toLowerCase() != 'na') {
      managers.add(clean);
    }
  }

  return managers;
}



class PanCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Force Uppercase
    String newText = newValue.text.toUpperCase();

    // 2. Prevent length > 10
    if (newText.length > 10) return oldValue;

    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < newText.length; i++) {
      String char = newText[i];

      // 3. Apply PAN Validation Logic based on index
      if (i < 5) {
        // Indices 0-4: Must be Letters [A-Z]
        if (RegExp(r'[A-Z]').hasMatch(char)) buffer.write(char);
      } else if (i >= 5 && i < 9) {
        // Indices 5-8: Must be Numbers [0-9]
        if (RegExp(r'[0-9]').hasMatch(char)) buffer.write(char);
      } else if (i == 9) {
        // Index 9: Must be Letter [A-Z]
        if (RegExp(r'[A-Z]').hasMatch(char)) buffer.write(char);
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Aadhaar: Exactly 12 digits, often grouped in 4s (0000 0000 0000)
class AadhaarFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 12) return oldValue;

    // Optional: Add spaces every 4 digits for better readability
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if ((i + 1) % 4 == 0 && (i + 1) != 12 && i != digits.length - 1) {
        buffer.write(' ');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Passport: 1 Letter followed by 7 Digits (Indian Standard)
class PassportFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.toUpperCase();
    if (text.length > 8) return oldValue;

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 0) {
        if (RegExp(r'[A-Z]').hasMatch(text[i])) buffer.write(text[i]);
      } else {
        if (RegExp(r'[0-9]').hasMatch(text[i])) buffer.write(text[i]);
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class DrivingLicenseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.toUpperCase();
    String cleanText = text.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (cleanText.length > 15) return oldValue;

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < cleanText.length; i++) {
      if (i < 2) {
        // First two must be letters (State Code)
        if (RegExp(r'[A-Z]').hasMatch(cleanText[i])) buffer.write(cleanText[i]);
      } else {
        // Remaining 13 must be digits
        if (RegExp(r'[0-9]').hasMatch(cleanText[i])) buffer.write(cleanText[i]);
      }

      // Auto-insert hyphen for UX
      if (i == 1 && cleanText.length > 2) buffer.write('-');
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class IfscTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Instantly convert input to uppercase
    String newText = newValue.text.toUpperCase();

    // 2. Allow backspace/deletion without restrictions
    if (newText.length < oldValue.text.length) {
      return newValue.copyWith(text: newText);
    }

    // 3. Enforce maximum length of 11 characters
    if (newText.length > 11) return oldValue;

    // 4. Enforce the strict IFSC Pattern character by character
    for (int i = 0; i < newText.length; i++) {
      String char = newText[i];
      
      if (i < 4) {
        // First 4 characters MUST be letters
        if (!RegExp(r'[A-Z]').hasMatch(char)) return oldValue;
      } else if (i == 4) {
        // 5th character MUST be '0' (Zero)
        if (char != '0') return oldValue;
      } else {
        // Last 6 characters can be alphanumeric
        if (!RegExp(r'[A-Z0-9]').hasMatch(char)) return oldValue;
      }
    }

    // If it passes all checks, return the correctly capitalized text
    return newValue.copyWith(text: newText);
  }
}

List<String> getCleanedTopHoldings({
  required List<String>? names,
  required List<dynamic>? values,
  int limit = 5,
}) {
  if (names == null || values == null || names.isEmpty || values.isEmpty) {
    return [];
  }

  int count = names.length < values.length ? names.length : values.length;
  List<MapEntry<String, double>> holdings = [];

  for (int i = 0; i < count; i++) {
    // 1. Get raw name
    String name = names[i];

    // --- AGGRESSIVE CLEANING START ---

    // A. Remove Percentages (e.g., "7.44%" or "8.65 %")
    name = name.replaceAll(RegExp(r'\d+(\.\d+)?\s*%'), '');

    // B. Remove Dates (Text Format like "03 Nov 2034" or "30 Jan 2027")
    //    Matches: 1-2 digits, space/dash, 3+ letters, space/dash, 4 digits
    name = name.replaceAll(
      RegExp(r'\b\d{1,2}[\s-][a-zA-Z]{3,}[\s-]\d{4}\b', caseSensitive: false),
      '',
    );

    // C. Remove Dates (Numeric Format like "25/11/2027")
    name = name.replaceAll(RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}'), '');

    // D. Remove EVERYTHING inside parentheses (handles "()", "(India)", "(Formerly..)")
    name = name.replaceAll(RegExp(r'\(.*?\)'), '');

    // E. Remove Face Value Junk (starts with EQ, FV, RS, etc.)
    name = name.replaceAll(
      RegExp(
        r'\s+(EQ|NEW|FV|RS\.?|RE\.?|Rs\.?|Re\.?)\b.*$',
        caseSensitive: false,
      ),
      '',
    );

    // F. Remove Standalone Years at the end (e.g., "Government of India 2033" -> removes 2033)
    //    Matches 19xx or 20xx at the end of the string
    name = name.replaceAll(RegExp(r'\b(19|20)\d{2}\s*$'), '');

    // G. Remove Punctuation & Extra Spaces
    name = name.replaceAll(RegExp(r'[-–]'), ' '); // Replace hyphens with space
    name = name.replaceAll(RegExp(r'\s+'), ' '); // Collapse multiple spaces
    name = name.trim(); // Final Trim

    // --- AGGRESSIVE CLEANING END ---

    // 2. Process Value
    double val = 0.0;
    if (values[i] is num) {
      val = (values[i] as num).toDouble();
    } else if (values[i] is String) {
      val = double.tryParse(values[i]) ?? 0.0;
    }

    if (name.isNotEmpty) {
      holdings.add(MapEntry(name, val));
    }
  }

  // 3. Sort & Return
  holdings.sort((a, b) => b.value.compareTo(a.value));
  return holdings.take(limit).map((e) => e.key).toList();
}

///// Parse String to Int
double parseIntSafe(String? value, {double defaultValue = 0}) {
  if (value == null || value.trim().isEmpty) {
    return defaultValue;
  }

  final cleanValue = value.replaceAll(',', '').trim();

  return double.tryParse(cleanValue) ?? defaultValue;
}

String getRemainingDays(String? closeDateStr) {
  if (closeDateStr == null || closeDateStr.isEmpty) return "N/A";

  try {
    // Parse the date (Format: YYYY-MM-DD)
    final DateTime closeDate = DateTime.parse(closeDateStr);
    final DateTime now = DateTime.now();

    // Normalize dates to midnight to compare full days accurately
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime expiry = DateTime(
      closeDate.year,
      closeDate.month,
      closeDate.day,
    );

    final int difference = expiry.difference(today).inDays;

    if (difference < 0) {
      return "CLOSED";
    } else if (difference == 0) {
      return "ENDS TODAY";
    } else if (difference == 1) {
      return "ENDS TOMORROW";
    } else {
      return "ENDS IN $difference DAYS";
    }
  } catch (e) {
    createLog("Error parsing NFO date: $e");
    return "N/A";
  }
}

class DocumentFormatterFactory {
  static List<TextInputFormatter> getFormatters(String type) {
    switch (type) {
      case "Pan":
        return [PanCardFormatter()];
      case "Aadhaar":
        return [AadhaarFormatter()];
      case "Passport":
        return [PassportFormatter()];
      case "Driving License":
        return [DrivingLicenseFormatter()];
      default:
        return [LengthLimitingTextInputFormatter(20)];
    }
  }

  static TextInputType getKeyboardType(String type) {
    if (type == "Aadhaar") return TextInputType.number;
    return TextInputType.text;
  }

  static String getHint(String type) {
    switch (type) {
      case "Pan":
        return "ABCDE1234F";
      case "Aadhaar":
        return "0000 0000 0000";
      case "Passport":
        return "A1234567";
      case "Driving License":
        return "DL-1320230000000";
      default:
        return "Enter document number";
    }
  }

  static String? validate(String type, String? value) {
    if (value == null || value.isEmpty) return "Document number is required";

    final cleanValue = value.replaceAll(' ', '').replaceAll('-', '');

    switch (type) {
      case "Pan":
        return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(cleanValue)
            ? null
            : "Invalid PAN format";
      case "Aadhaar":
        return cleanValue.length == 12 ? null : "Aadhaar must be 12 digits";
      case "Passport":
        return RegExp(r'^[A-Z]{1}[0-9]{7}$').hasMatch(cleanValue)
            ? null
            : "Invalid Passport format";
      case "Driving License":
        return cleanValue.length == 15 ? null : "DL must be 15 characters";
      default:
        return null;
    }
  }
}

int getYearlyIncomeAsInt(String text) {
    final value = text.trim();

    // Translate the dropdown string into a raw integer for your database
    switch (value) {
      case "Below 1 Lakh":
        return 90000; // Using 90,000 as seen in your success log
      case "1 Lacs - 5 Lacs":
        return 500000;
      case "5 Lacs - 10 Lacs":
        return 1000000;
      case "10 Lacs - 25 Lacs":
        return 2500000;
      case "25 Lacs - 1 Cr.":
        return 10000000;
      case "Above 1 Cr.":
        return 50000000;
      default:
        return 0;
    }
  }

  // Reverses the SQL date back to UI format
  String formatToUIDate(String? sqlDate) {
    if (sqlDate == null || sqlDate.isEmpty) return '';
    try {
      List<String> parts = sqlDate.split('-');
      if (parts.length == 3) {
        String year = parts[0];
        String month = parts[1];
        String day = parts[2];
        return '$day/$month/$year'; // Returns DD/MM/YYYY
      }
    } catch (e) {
      return sqlDate; // Fallback
    }
    return sqlDate;
  }

String formatToSqlDate(String dateStr) {
  // Converts DD/MM/YYYY to YYYY-MM-DD
  if (dateStr.contains('/')) {
    var parts = dateStr.split('/');
    if (parts.length == 3) {
      return "${parts[2]}-${parts[1]}-${parts[0]}";
    }
  }
  return dateStr;
}

// lib/core/utils/profile_utils.dart

class ProfileUtils {
  // ==========================================
  // 📋 CENTRALIZED LISTS
  // ==========================================
  static const List<String> wealthSources = [
    "Salary", "Business Income", "Gift", "Ancestral Property", 
    "Rental Income", "Prize money", "Royalty", "Other"
  ];

  static const List<String> incomeSlabList = [
    "Below 1 Lakh", "1 Lacs - 5 Lacs", "5 Lacs - 10 Lacs", 
    "10 Lacs - 25 Lacs", "25 Lacs - 1 Cr.", "Above 1 Cr."
  ];

  static const List<String> occupationList = [
    "Business", "Service", "Retired Professional", "Professional", "Other"
  ];

  static const List<String> maritalStatusList = [
    "UNMARRIED", "MARRIED", "DIVORCED", "WIDOWED", "OTHERS"
  ];

  // ==========================================
  // 🔄 UI TO BACKEND (String -> ID)
  // ==========================================
  static int? getWealthSourceId(String? name) {
    if (name == null || name.isEmpty) return null;
    int index = wealthSources.indexOf(name);
    return index != -1 ? index + 1 : null;
  }

  static int? getIncomeSlabId(String? name) {
    if (name == null || name.isEmpty) return null;
    int index = incomeSlabList.indexOf(name);
    return index != -1 ? index + 1 : null;
  }

  static int? getOccupationId(String? name) {
    if (name == null || name.isEmpty) return null;
    int index = occupationList.indexOf(name);
    return index != -1 ? index + 1 : null;
  }

  // ==========================================
  // 🔄 BACKEND TO UI (ID -> String)
  // ==========================================
  static String getWealthSourceName(int? id) {
    if (id == null || id <= 0 || id > wealthSources.length) return '';
    return wealthSources[id - 1]; 
  }

  static String getIncomeSlabName(int? id) {
    if (id == null || id <= 0 || id > incomeSlabList.length) return '';
    return incomeSlabList[id - 1];
  }

  static String getOccupationName(int? id) {
    if (id == null || id <= 0 || id > occupationList.length) return '';
    return occupationList[id - 1];
  }

  // ==========================================
  // 📅 DATE FORMATTERS
  // ==========================================
  static String formatToSqlDate(String dob) {
    if (dob.isEmpty) return '';
    try {
      List<String> parts = dob.split('/');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}'; 
      }
    } catch (e) {
      return dob; 
    }
    return dob;
  }

  static String formatToUIDate(String? sqlDate) {
    if (sqlDate == null || sqlDate.isEmpty) return '';
    try {
      List<String> parts = sqlDate.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}'; 
      }
    } catch (e) {
      return sqlDate; 
    }
    return sqlDate;
  }
}
