# 🕌 Ezan - Namaz Vakitleri Uygulaması

Türkiye için Diyanet metoduyla namaz vakitlerini hesaplayan, ezan çalan ve kıble yönünü gösteren Flutter uygulaması.

---

## 📱 Özellikler

- **Namaz Vakitleri** — İmsak, Güneş, Öğle, İkindi, Akşam, Yatsı
- **Geri Sayım** — Bir sonraki vakite canlı geri sayım
- **Hicri Tarih** — Otomatik Hicri takvim
- **Ezan Sesi** — Klasik, Mekke ve Medine ezanları
- **Bildirimler** — Vakitlerde otomatik bildirim + 10 dk öncesi hatırlatıcı
- **Kıble Yönü** — Pusula ile Kabe yönü ve mesafesi
- **Konum** — GPS ile otomatik şehir tespiti
- **Ayarlar** — Hesaplama metodu, mezhep seçimi, bildirim kontrolü

---

## 🚀 Kurulum

### Gereksinimler
- Flutter 3.16+
- Dart 3.0+
- Android SDK 21+ (Android 5.0)

### 1. Bağımlılıkları Yükle
```bash
cd ezan_app
flutter pub get
```

### 2. Ses Dosyalarını Ekle
`assets/audio/` klasörüne şu MP3 dosyalarını koy:
- `ezan_classic.mp3`
- `ezan_makkah.mp3`
- `ezan_madinah.mp3`
- `reminder.mp3` (kısa hatırlatma sesi)

**Not:** Ezan sesleri telif hakkı nedeniyle dahil edilmemiştir.
Ücretsiz kaynaklar: [IslamicFinder](https://www.islamicfinder.org) veya
[MP3 Quran](https://mp3quran.net/api/v3/radios)

### 3. Android İzinleri
`android/app/src/main/AndroidManifest.xml` dosyası hazırdır.

### 4. Çalıştır
```bash
flutter run
```

---

## 🏪 Google Play Yayınlama

### APK / AAB Oluştur
```bash
# Release APK
flutter build apk --release

# Google Play için AAB (önerilen)
flutter build appbundle --release
```

### İmzalama
```bash
# Keystore oluştur
keytool -genkey -v -keystore ~/ezan-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias ezan

# key.properties dosyasını android/ klasörüne ekle:
# storePassword=<şifreniz>
# keyPassword=<şifreniz>
# keyAlias=ezan
# storeFile=<yol>/ezan-key.jks
```

### build.gradle'ı Güncelle
`android/app/build.gradle` dosyasına signing config ekle.

---

## 📂 Proje Yapısı

```
lib/
├── main.dart                 — Giriş noktası
├── app.dart                  — MaterialApp + Navigation
├── models/
│   └── prayer_time_model.dart
├── services/
│   ├── prayer_service.dart   — Vakit hesaplama (adhan)
│   ├── location_service.dart — GPS konum
│   ├── notification_service.dart — Bildirimler
│   └── audio_service.dart    — Ezan sesi
├── screens/
│   ├── home_screen.dart      — Ana ekran
│   ├── qibla_screen.dart     — Kıble pusulası
│   └── settings_screen.dart  — Ayarlar
├── widgets/
│   ├── prayer_card.dart      — Namaz vakti kartı
│   └── countdown_widget.dart — Geri sayım
└── theme/
    └── app_theme.dart        — Renkler, stiller, gradyanlar
```

---

## ⚙️ Hesaplama Metotları

| Metot | Fajr | Isha |
|-------|------|------|
| Diyanet (TR) | 18° | 17° |
| MWL | 18° | 17° |
| ISNA | 15° | 15° |
| Mısır | 19.5° | 17.5° |
| Ümmü'l-Kura | 18.5° | 90 dk |

---

## 📦 Kullanılan Paketler

| Paket | Amaç |
|-------|------|
| `adhan` | Namaz vakti hesaplama |
| `geolocator` | GPS konum |
| `geocoding` | Şehir ismi |
| `flutter_local_notifications` | Bildirimler |
| `audioplayers` | Ezan sesi |
| `flutter_compass` | Kıble pusulası |
| `google_fonts` | Lato yazı tipi |
| `shared_preferences` | Ayar kaydetme |
| `timezone` | Zaman dilimi |
