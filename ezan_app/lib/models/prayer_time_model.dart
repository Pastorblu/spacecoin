import 'package:flutter/material.dart';

class PrayerTimeModel {
  final String name;
  final String arabicName;
  final DateTime time;
  final IconData icon;
  bool notificationEnabled;

  PrayerTimeModel({
    required this.name,
    required this.arabicName,
    required this.time,
    required this.icon,
    this.notificationEnabled = true,
  });
}

class PrayerSettings {
  final String city;
  final double latitude;
  final double longitude;
  final int calculationMethod; // 0=Diyanet, 1=MWL, 2=ISNA
  final int madhab; // 0=Hanafi, 1=Shafi
  final bool ezanEnabled;
  final String ezanType; // 'classic', 'makkah', 'madinah'

  const PrayerSettings({
    this.city = '',
    this.latitude = 41.0082,
    this.longitude = 28.9784,
    this.calculationMethod = 0,
    this.madhab = 0,
    this.ezanEnabled = true,
    this.ezanType = 'classic',
  });

  PrayerSettings copyWith({
    String? city,
    double? latitude,
    double? longitude,
    int? calculationMethod,
    int? madhab,
    bool? ezanEnabled,
    String? ezanType,
  }) {
    return PrayerSettings(
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      ezanEnabled: ezanEnabled ?? this.ezanEnabled,
      ezanType: ezanType ?? this.ezanType,
    );
  }
}
