import 'package:flutter/material.dart';
import '../models/prayer_time_model.dart';
import '../services/prayer_service.dart';
import '../theme/app_theme.dart';

class PrayerCard extends StatelessWidget {
  final PrayerTimeModel prayer;
  final bool isNext;
  final bool isCurrent;
  final VoidCallback? onToggleNotification;

  const PrayerCard({
    super.key,
    required this.prayer,
    this.isNext = false,
    this.isCurrent = false,
    this.onToggleNotification,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isNext
            ? const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isNext ? null : Theme.of(context).cardTheme.color,
        border: isCurrent
            ? Border.all(color: AppTheme.accentGold, width: 1.5)
            : null,
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onToggleNotification,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // İkon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isNext
                        ? Colors.white.withOpacity(0.2)
                        : AppTheme.primaryGreen.withOpacity(0.15),
                  ),
                  child: Icon(
                    prayer.icon,
                    color: isNext ? Colors.white : AppTheme.textSecondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),

                // Namaz adı
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayer.name,
                        style: TextStyle(
                          color: isNext ? Colors.white : AppTheme.textPrimary,
                          fontSize: 17,
                          fontWeight: isNext
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      Text(
                        prayer.arabicName,
                        style: TextStyle(
                          color: isNext
                              ? Colors.white70
                              : AppTheme.textSecondary,
                          fontSize: 13,
                          fontFamily: 'Scheherazade',
                        ),
                      ),
                    ],
                  ),
                ),

                // Etiket
                if (isNext)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'SIRADAKI',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                const SizedBox(width: 12),

                // Saat
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      PrayerService.formatTime(prayer.time),
                      style: TextStyle(
                        color: isNext ? Colors.white : AppTheme.accentGold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (prayer.notificationEnabled != null)
                      Icon(
                        prayer.notificationEnabled
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_off_outlined,
                        size: 14,
                        color: isNext ? Colors.white60 : AppTheme.textSecondary,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
