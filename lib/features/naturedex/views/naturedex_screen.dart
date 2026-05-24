import 'package:flutter/material.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/app_drawer.dart';

class NaturedexScreen extends StatelessWidget {
  const NaturedexScreen({super.key});

  static const List<Map<String, String>> natures = [
    {'name': 'Hardy', 'increased': '—', 'decreased': '—'},
    {'name': 'Lonely', 'increased': 'Attack', 'decreased': 'Defense'},
    {'name': 'Brave', 'increased': 'Attack', 'decreased': 'Speed'},
    {'name': 'Adamant', 'increased': 'Attack', 'decreased': 'Sp. Atk'},
    {'name': 'Naughty', 'increased': 'Attack', 'decreased': 'Sp. Def'},
    {'name': 'Bold', 'increased': 'Defense', 'decreased': 'Attack'},
    {'name': 'Docile', 'increased': '—', 'decreased': '—'},
    {'name': 'Relaxed', 'increased': 'Defense', 'decreased': 'Speed'},
    {'name': 'Impish', 'increased': 'Defense', 'decreased': 'Sp. Atk'},
    {'name': 'Lax', 'increased': 'Defense', 'decreased': 'Sp. Def'},
    {'name': 'Timid', 'increased': 'Speed', 'decreased': 'Attack'},
    {'name': 'Hasty', 'increased': 'Speed', 'decreased': 'Defense'},
    {'name': 'Serious', 'increased': '—', 'decreased': '—'},
    {'name': 'Jolly', 'increased': 'Speed', 'decreased': 'Sp. Atk'},
    {'name': 'Naive', 'increased': 'Speed', 'decreased': 'Sp. Def'},
    {'name': 'Modest', 'increased': 'Sp. Atk', 'decreased': 'Attack'},
    {'name': 'Mild', 'increased': 'Sp. Atk', 'decreased': 'Defense'},
    {'name': 'Quiet', 'increased': 'Sp. Atk', 'decreased': 'Speed'},
    {'name': 'Bashful', 'increased': '—', 'decreased': '—'},
    {'name': 'Rash', 'increased': 'Sp. Atk', 'decreased': 'Sp. Def'},
    {'name': 'Calm', 'increased': 'Sp. Def', 'decreased': 'Attack'},
    {'name': 'Gentle', 'increased': 'Sp. Def', 'decreased': 'Defense'},
    {'name': 'Sassy', 'increased': 'Sp. Def', 'decreased': 'Speed'},
    {'name': 'Careful', 'increased': 'Sp. Def', 'decreased': 'Sp. Atk'},
    {'name': 'Quirky', 'increased': '—', 'decreased': '—'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('NatureDex', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const AppDrawer(currentRoute: 'natures'),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Explanatory Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.pokemonRed, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Natures affect stat growth. An increased stat grows 10% faster (x1.1), while a decreased stat grows 10% slower (x0.9). Neutral Natures have no effect.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // nature grid header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'NATURE',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500]),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'INCREASED (+10%)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500]),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'DECREASED (-10%)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Nature list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: natures.length,
                  separatorBuilder: (context, index) => Divider(
                    color: isDark ? const Color(0xFF161616) : const Color(0xFFE5E7EB),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final nature = natures[index];
                    final inc = nature['increased']!;
                    final dec = nature['decreased']!;

                    final bool isNeutral = inc == '—';

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              nature['name']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              inc,
                              style: TextStyle(
                                fontWeight: isNeutral ? FontWeight.normal : FontWeight.bold,
                                color: isNeutral
                                    ? Colors.grey
                                    : (isDark ? Colors.tealAccent : Colors.teal[700]),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              dec,
                              style: TextStyle(
                                fontWeight: isNeutral ? FontWeight.normal : FontWeight.bold,
                                color: isNeutral
                                    ? Colors.grey
                                    : (isDark ? Colors.redAccent : Colors.red[700]),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
