// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsModelAdapter extends TypeAdapter<AppSettingsModel> {
  @override
  final int typeId = 6;

  @override
  AppSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettingsModel(
      taxPercentage: fields[0] as double,
      currency: fields[1] as String,
      currencySymbol: fields[2] as String,
      receiptPrefix: fields[3] as String,
      darkMode: fields[4] as bool,
      businessName: fields[5] as String,
      businessAddress: fields[6] as String,
      phoneNumber: fields[7] as String,
      footerText: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.taxPercentage)
      ..writeByte(1)
      ..write(obj.currency)
      ..writeByte(2)
      ..write(obj.currencySymbol)
      ..writeByte(3)
      ..write(obj.receiptPrefix)
      ..writeByte(4)
      ..write(obj.darkMode)
      ..writeByte(5)
      ..write(obj.businessName)
      ..writeByte(6)
      ..write(obj.businessAddress)
      ..writeByte(7)
      ..write(obj.phoneNumber)
      ..writeByte(8)
      ..write(obj.footerText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
