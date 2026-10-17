import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'app_settings_model.g.dart';

@HiveType(typeId: 6)
class AppSettingsModel extends HiveObject with EquatableMixin {
  AppSettingsModel({
    this.taxPercentage = 8.0,
    this.currency = 'USD',
    this.currencySymbol = '\$',
    this.receiptPrefix = 'BD',
    this.darkMode = true,
    this.businessName = 'Black Diamond Promotions',
    this.businessAddress = '',
    this.phoneNumber = '',
    this.footerText = 'Thank you for your purchase!',
  });

  @HiveField(0)
  final double taxPercentage;

  @HiveField(1)
  final String currency;

  @HiveField(2)
  final String currencySymbol;

  @HiveField(3)
  final String receiptPrefix;

  @HiveField(4)
  final bool darkMode;

  @HiveField(5)
  final String businessName;

  @HiveField(6)
  final String businessAddress;

  @HiveField(7)
  final String phoneNumber;

  @HiveField(8)
  final String footerText;

  AppSettingsModel copyWith({
    double? taxPercentage,
    String? currency,
    String? currencySymbol,
    String? receiptPrefix,
    bool? darkMode,
    String? businessName,
    String? businessAddress,
    String? phoneNumber,
    String? footerText,
  }) {
    return AppSettingsModel(
      taxPercentage: taxPercentage ?? this.taxPercentage,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      receiptPrefix: receiptPrefix ?? this.receiptPrefix,
      darkMode: darkMode ?? this.darkMode,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      footerText: footerText ?? this.footerText,
    );
  }

  Map<String, dynamic> toJson() => {
    'taxPercentage': taxPercentage,
    'currency': currency,
    'currencySymbol': currencySymbol,
    'receiptPrefix': receiptPrefix,
    'darkMode': darkMode,
    'businessName': businessName,
    'businessAddress': businessAddress,
    'phoneNumber': phoneNumber,
    'footerText': footerText,
  };

  factory AppSettingsModel.fromJson(
    Map<String, dynamic> json,
  ) => AppSettingsModel(
    taxPercentage: (json['taxPercentage'] as num?)?.toDouble() ?? 8.0,
    currency: json['currency'] as String? ?? 'USD',
    currencySymbol: json['currencySymbol'] as String? ?? '\$',
    receiptPrefix: json['receiptPrefix'] as String? ?? 'BD',
    darkMode: json['darkMode'] as bool? ?? true,
    businessName: json['businessName'] as String? ?? 'Black Diamond Promotions',
    businessAddress: json['businessAddress'] as String? ?? '',
    phoneNumber: json['phoneNumber'] as String? ?? '',
    footerText: json['footerText'] as String? ?? 'Thank you for your purchase!',
  );

  @override
  List<Object?> get props => [
    taxPercentage,
    currency,
    currencySymbol,
    receiptPrefix,
    darkMode,
    businessName,
    businessAddress,
    phoneNumber,
    footerText,
  ];
}
