import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prayer_time_model.dart';

class PrayerService {
  static List<PrayerTimeModel> calculatePrayerTimes({
    required double latitude,
    required double longitude,
    required int methodIndex,
    required int madhabIndex,
    DateTime? date,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final dateComponents = DateComponents.from(date ?? DateTime.now());

    final params = _getCalculationParams(methodIndex, madhabIndex);
    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    return [
      PrayerTimeModel(
        name: 'İmsak',
        arabicName: 'الفجر',
        time: prayerTimes.fajr,
        icon: Icons.nights_stay_outlined,
      ),
      PrayerTimeModel(
        name: 'Güneş',
        arabicName: 'الشروق',
        time: prayerTimes.sunrise,
        icon: Icons.wb_twilight,
        notificationEnabled: false,
      ),
      PrayerTimeModel(
        name: 'Öğle',
        arabicName: 'الظهر',
        time: prayerTimes.dhuhr,
        icon: Icons.wb_sunny_outlined,
      ),
      PrayerTimeModel(
        name: 'İkindi',
        arabicName: 'العصر',
        time: prayerTimes.asr,
        icon: Icons.wb_cloudy_outlined,
      ),
      PrayerTimeModel(
        name: 'Akşam',
        arabicName: 'المغرب',
        time: prayerTimes.maghrib,
        icon: Icons.wb_twilight_outlined,
      ),
      PrayerTimeModel(
        name: 'Yatsı',
        arabicName: 'العشاء',
        time: prayerTimes.isha,
        icon: Icons.dark_mode_outlined,
      ),
    ];
  }

  static CalculationParameters _getCalculationParams(
      int methodIndex, int madhabIndex) {
    CalculationParameters params;

    switch (methodIndex) {
      case 0: // Diyanet İşleri Başkanlığı
        params = CalculationMethod.turkey.getParameters();
        break;
      case 1: // Muslim World League
        params = CalculationMethod.muslimWorldLeague.getParameters();
        break;
      case 2: // ISNA
        params = CalculationMethod.northAmerica.getParameters();
        break;
      case 3: // Egypt
        params = CalculationMethod.egyptian.getParameters();
        break;
      case 4: // Makkah
        params = CalculationMethod.ummAlQura.getParameters();
        break;
      default:
        params = CalculationMethod.turkey.getParameters();
    }

    params.madhab =
        madhabIndex == 0 ? Madhab.hanafi : Madhab.shafi;

    return params;
  }

  static String? getCurrentPrayerName(List<PrayerTimeModel> prayers) {
    final now = DateTime.now();
    for (int i = prayers.length - 1; i >= 0; i--) {
      if (now.isAfter(prayers[i].time)) {
        return prayers[i].name;
      }
    }
    return prayers.last.name;
  }

  static PrayerTimeModel? getNextPrayer(List<PrayerTimeModel> prayers) {
    final now = DateTime.now();
    for (final prayer in prayers) {
      if (prayer.time.isAfter(now)) {
        return prayer;
      }
    }
    return null;
  }

  static Duration getTimeUntilNextPrayer(List<PrayerTimeModel> prayers) {
    final next = getNextPrayer(prayers);
    if (next == null) return Duration.zero;
    return next.time.difference(DateTime.now());
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String getHijriDate() {
    // Basit Hicri tarih hesaplaması
    final now = DateTime.now();
    // Gerçek uygulamada bir kütüphane kullanılır
    return _gregorianToHijri(now);
  }

  static String _gregorianToHijri(DateTime date) {
    // Basitleştirilmiş dönüşüm - gerçek uygulamada hijri package kullanın
    final months = [
      'Muharrem', 'Safer', 'Rebiülevvel', 'Rebiülahir',
      'Cemaziyelevvel', 'Cemaziyelahir', 'Recep', 'Şaban',
      'Ramazan', 'Şevval', 'Zilkade', 'Zilhicce'
    ];

    // Yaklaşık hesaplama
    final jd = _dateToJulian(date);
    final hijri = _julianToHijri(jd);

    final day = hijri[0];
    final month = hijri[1];
    final year = hijri[2];

    return '$day ${months[month - 1]} $year';
  }

  static int _dateToJulian(DateTime date) {
    int a = ((14 - date.month) / 12).floor();
    int y = date.year + 4800 - a;
    int m = date.month + 12 * a - 3;
    return date.day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;
  }

  static List<int> _julianToHijri(int jd) {
    int l = jd - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    int j = (((10985 - l) / 5316).floor()) * (((50 * l) / 17719).floor()) +
        ((l / 5670).floor()) * (((43 * l) / 15238).floor());
    l = l - (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) -
        ((j / 16).floor()) * (((15238 * j) / 43).floor()) +
        29;
    int month = ((24 * l) / 709).floor();
    int day = l - ((709 * month) / 24).floor();
    int year = 30 * n + j - 30;
    return [day, month, year];
  }
}
