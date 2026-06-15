class ProtectedNumber {
  final String displayName;
  final String number;

  ProtectedNumber({required this.displayName, required this.number});

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'number': number,
      };

  factory ProtectedNumber.fromJson(Map<String, dynamic> json) =>
      ProtectedNumber(
        displayName: json['displayName'] as String,
        number: json['number'] as String,
      );

  /// Normalizes a number for comparison: strips spaces, dashes, parentheses.
  static String normalize(String input) {
    return input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }
}
