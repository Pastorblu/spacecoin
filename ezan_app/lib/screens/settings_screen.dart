import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _calculationMethod = 0;
  int _madhab = 0;
  bool _ezanEnabled = true;
  String _ezanType = 'classic';
  bool _darkMode = true;
  bool _notificationsEnabled = true;
  int _reminderMinutes = 10;

  final List<String> _methodNames = [
    'Diyanet İşleri Başkanlığı',
    'Müslüman Dünya Birliği',
    'ISNA (Kuzey Amerika)',
    'Mısır',
    'Ümmü\'l-Kura (Mekke)',
  ];

  final List<String> _ezanTypes = [
    'Klasik',
    'Mekke',
    'Medine',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _calculationMethod = prefs.getInt('calculationMethod') ?? 0;
      _madhab = prefs.getInt('madhab') ?? 0;
      _ezanEnabled = prefs.getBool('ezanEnabled') ?? true;
      _ezanType = prefs.getString('ezanType') ?? 'classic';
      _darkMode = prefs.getBool('darkMode') ?? true;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _reminderMinutes = prefs.getInt('reminderMinutes') ?? 10;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calculationMethod', _calculationMethod);
    await prefs.setInt('madhab', _madhab);
    await prefs.setBool('ezanEnabled', _ezanEnabled);
    await prefs.setString('ezanType', _ezanType);
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setInt('reminderMinutes', _reminderMinutes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        actions: [
          TextButton(
            onPressed: () async {
              await _saveSettings();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ayarlar kaydedildi'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              }
            },
            child: const Text(
              'Kaydet',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Namaz Vakti Hesaplama
          _buildSection(
            title: 'Namaz Vakti Hesaplama',
            icon: Icons.calculate_outlined,
            children: [
              _buildDropdown(
                label: 'Hesaplama Metodu',
                value: _calculationMethod,
                items: _methodNames.asMap().entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _calculationMethod = v!),
              ),
              const Divider(color: Colors.white12),
              _buildChoiceChips(
                label: 'Mezhep',
                choices: const ['Hanefi', 'Şafi'],
                selected: _madhab,
                onSelected: (v) => setState(() => _madhab = v),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Ezan Ayarları
          _buildSection(
            title: 'Ezan Ayarları',
            icon: Icons.volume_up_outlined,
            children: [
              _buildSwitch(
                label: 'Ezan Sesini Etkinleştir',
                subtitle: 'Namaz vakitlerinde ezan çalsın',
                value: _ezanEnabled,
                onChanged: (v) => setState(() => _ezanEnabled = v),
              ),
              if (_ezanEnabled) ...[
                const Divider(color: Colors.white12),
                _buildDropdown(
                  label: 'Ezan Tipi',
                  value: ['classic', 'makkah', 'madinah'].indexOf(_ezanType),
                  items: _ezanTypes.asMap().entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _ezanType =
                        ['classic', 'makkah', 'madinah'][v!];
                  }),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Bildirim Ayarları
          _buildSection(
            title: 'Bildirim Ayarları',
            icon: Icons.notifications_outlined,
            children: [
              _buildSwitch(
                label: 'Bildirimleri Etkinleştir',
                subtitle: 'Namaz vakitlerinde bildirim gönder',
                value: _notificationsEnabled,
                onChanged: (v) =>
                    setState(() => _notificationsEnabled = v),
              ),
              if (_notificationsEnabled) ...[
                const Divider(color: Colors.white12),
                _buildSlider(
                  label: 'Önceden Hatırlatma',
                  value: _reminderMinutes.toDouble(),
                  min: 0,
                  max: 30,
                  divisions: 6,
                  display: '$_reminderMinutes dakika önce',
                  onChanged: (v) =>
                      setState(() => _reminderMinutes = v.round()),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Görünüm
          _buildSection(
            title: 'Görünüm',
            icon: Icons.palette_outlined,
            children: [
              _buildSwitch(
                label: 'Karanlık Mod',
                subtitle: 'Koyu tema kullan',
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Hakkında
          _buildSection(
            title: 'Hakkında',
            icon: Icons.info_outline,
            children: [
              _buildInfoRow('Versiyon', '1.0.0'),
              const Divider(color: Colors.white12),
              _buildInfoRow('Geliştirici', 'Ezan App'),
              const Divider(color: Colors.white12),
              _buildInfoRow('Kaynak', 'adhan-dart kütüphanesi'),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.accentGold, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(label,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.accentGold,
    );
  }

  Widget _buildDropdown({
    required String label,
    required int value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: value,
            items: items,
            onChanged: onChanged,
            dropdownColor: AppTheme.cardDark,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChips({
    required String label,
    required List<String> choices,
    required int selected,
    required ValueChanged<int> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 15)),
          const Spacer(),
          Wrap(
            spacing: 8,
            children: choices.asMap().entries.map((e) {
              final isSelected = e.key == selected;
              return ChoiceChip(
                label: Text(e.value),
                selected: isSelected,
                onSelected: (_) => onSelected(e.key),
                selectedColor: AppTheme.primaryGreen,
                backgroundColor: Colors.white.withOpacity(0.07),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 13,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String display,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 15)),
              Text(display,
                  style: const TextStyle(
                      color: AppTheme.accentGold, fontSize: 13)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: AppTheme.accentGold,
            inactiveColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 15)),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
