import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/prayer_time_model.dart';
import '../services/prayer_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/audio_service.dart';
import '../widgets/prayer_card.dart';
import '../widgets/countdown_widget.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PrayerTimeModel> _prayers = [];
  String _cityName = 'Konum Yükleniyor...';
  String _hijriDate = '';
  bool _loading = true;
  bool _isPlayingEzan = false;
  double _latitude = 41.0082;
  double _longitude = 28.9784;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null).then((_) {
      _loadPrayerTimes();
    });
  }

  Future<void> _loadPrayerTimes() async {
    setState(() => _loading = true);

    // Konumu al
    final location = await LocationService.getCurrentLocation();
    if (location != null) {
      _latitude = location['latitude'];
      _longitude = location['longitude'];
      _cityName = location['city'];
    } else {
      _cityName = 'İstanbul (Varsayılan)';
    }

    // Namaz vakitlerini hesapla
    final prayers = PrayerService.calculatePrayerTimes(
      latitude: _latitude,
      longitude: _longitude,
      methodIndex: 0, // Diyanet
      madhabIndex: 0, // Hanefi
    );

    // Hicri tarihi al
    final hijri = PrayerService.getHijriDate();

    setState(() {
      _prayers = prayers;
      _hijriDate = hijri;
      _loading = false;
    });

    // Bildirimleri planla
    await NotificationService.schedulePrayerNotifications(prayers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading ? _buildLoading() : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.accentGold),
          SizedBox(height: 16),
          Text(
            'Namaz vakitleri hesaplanıyor...',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final now = DateTime.now();
    final dateStr = DateFormat('d MMMM y, EEEE', 'tr_TR').format(now);
    final currentPrayerName =
        PrayerService.getCurrentPrayerName(_prayers);
    final nextPrayer = PrayerService.getNextPrayer(_prayers);

    return RefreshIndicator(
      onRefresh: _loadPrayerTimes,
      color: AppTheme.accentGold,
      backgroundColor: AppTheme.cardDark,
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppTheme.darkBg,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.darkBg, Color(0xFF132236)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppTheme.accentGold,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _cityName,
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            // Ezan çal butonu
                            GestureDetector(
                              onTap: _toggleEzan,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isPlayingEzan
                                      ? AppTheme.accentGold
                                      : AppTheme.cardDark,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.accentGold,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isPlayingEzan
                                          ? Icons.stop
                                          : Icons.volume_up_outlined,
                                      color: _isPlayingEzan
                                          ? Colors.black
                                          : AppTheme.accentGold,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isPlayingEzan ? 'Durdur' : 'Ezan',
                                      style: TextStyle(
                                        color: _isPlayingEzan
                                            ? Colors.black
                                            : AppTheme.accentGold,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          _hijriDate,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // İçerik
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Geri sayım
                CountdownWidget(prayers: _prayers),

                const SizedBox(height: 8),

                // Şimdiki vakit bilgisi
                if (currentPrayerName != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.accentGold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Şu an: $currentPrayerName vakti',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Namaz vakitleri
                ...(_prayers.map((prayer) {
                  final isNext = nextPrayer?.name == prayer.name;
                  final isCurrent = currentPrayerName == prayer.name;

                  return PrayerCard(
                    prayer: prayer,
                    isNext: isNext,
                    isCurrent: isCurrent && !isNext,
                    onToggleNotification: () {
                      setState(() {
                        prayer.notificationEnabled =
                            !prayer.notificationEnabled;
                      });
                      NotificationService.schedulePrayerNotifications(
                          _prayers);
                    },
                  );
                })),

                const SizedBox(height: 20),

                // Bilgi notu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppTheme.textSecondary, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Vakitler Diyanet İşleri Başkanlığı metoduna göre hesaplanmaktadır.',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleEzan() async {
    if (_isPlayingEzan) {
      await AudioService.stop();
    } else {
      await AudioService.playEzan('classic');
    }
    setState(() {
      _isPlayingEzan = !_isPlayingEzan;
    });
  }
}
