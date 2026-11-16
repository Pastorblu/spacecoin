import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  double? _heading;
  double _qiblaAngle = 0;
  double _latitude = 41.0082;
  double _longitude = 28.9784;
  bool _hasPermission = false;
  late AnimationController _pulseController;

  // Mekke koordinatları
  static const double _makkahLat = 21.4225;
  static const double _makkahLon = 39.8262;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initialize();
  }

  Future<void> _initialize() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _qiblaAngle = _calculateQiblaAngle(
            _latitude, _longitude, _makkahLat, _makkahLon);
      });
    } catch (e) {
      _qiblaAngle = _calculateQiblaAngle(
          _latitude, _longitude, _makkahLat, _makkahLon);
    }

    setState(() => _hasPermission = true);
  }

  double _calculateQiblaAngle(
      double lat1, double lon1, double lat2, double lon2) {
    final dLon = _toRad(lon2 - lon1);
    final lat1Rad = _toRad(lat1);
    final lat2Rad = _toRad(lat2);

    final y = math.sin(dLon) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

    return (_toDeg(math.atan2(y, x)) + 360) % 360;
  }

  double _toRad(double deg) => deg * math.pi / 180;
  double _toDeg(double rad) => rad * 180 / math.pi;

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kıble Yönü'),
        backgroundColor: AppTheme.darkBg,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.nightGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mekke mesafesi
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mosque, color: AppTheme.accentGold, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Kıble: ${_qiblaAngle.toStringAsFixed(1)}°',
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Pusula
              StreamBuilder<CompassEvent>(
                stream: FlutterCompass.events,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _buildCompassPlaceholder();
                  }

                  final heading = snapshot.data!.heading ?? 0;
                  final rotation =
                      (_qiblaAngle - heading) * math.pi / 180;

                  return _buildCompass(rotation);
                },
              ),

              const SizedBox(height: 40),

              // Açıklama
              Text(
                'Kabe\'ye dönerek namaz kılın',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mekke\'den uzaklık: ${_calculateDistance(_latitude, _longitude, _makkahLat, _makkahLon).toStringAsFixed(0)} km',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompass(double rotation) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = math.sin(_pulseController.value * math.pi * 2) * 0.03;
        return Transform.scale(
          scale: 1.0 + pulse,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Dış halka
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.accentGold.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              // İç halka
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cardDark,
                  border: Border.all(
                    color: AppTheme.accentGold.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGold.withOpacity(0.1),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              // Ok (Kıble yönünü gösterir)
              Transform.rotate(
                angle: rotation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Kabe ikonu
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentGold,
                      ),
                      child: const Icon(
                        Icons.mosque,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    // Ok gövdesi
                    Container(
                      width: 3,
                      height: 70,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppTheme.accentGold, Colors.transparent],
                        ),
                      ),
                    ),
                    const SizedBox(height: 70), // Alt boşluk
                  ],
                ),
              ),
              // Merkez nokta
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompassPlaceholder() {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.cardDark,
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.accentGold),
      ),
    );
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}
