import 'package:flutter/material.dart';
import 'package:libredex/core/widgets/app_drawer.dart';

class TypeChartScreen extends StatefulWidget {
  const TypeChartScreen({super.key});

  @override
  State<TypeChartScreen> createState() => _TypeChartScreenState();
}

class _TypeChartScreenState extends State<TypeChartScreen> {
  String _primaryType = 'fire';
  String _secondaryType = 'none';

  final List<String> _allTypes = [
    'normal', 'fire', 'water', 'electric', 'grass', 'ice',
    'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug',
    'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy'
  ];

  static const Map<String, Color> _typeColors = {
    'normal': Color(0xFFA8A77A),
    'fire': Color(0xFFEE8130),
    'water': Color(0xFF6390F0),
    'electric': Color(0xFFF7D02C),
    'grass': Color(0xFF7AC74C),
    'ice': Color(0xFF96D9D6),
    'fighting': Color(0xFFC22E28),
    'poison': Color(0xFFA33EA1),
    'ground': Color(0xFFE2BF65),
    'flying': Color(0xFFA98FEE),
    'psychic': Color(0xFFF95587),
    'bug': Color(0xFFA6B91A),
    'rock': Color(0xFFB6A136),
    'ghost': Color(0xFF735797),
    'dragon': Color(0xFF6F35FC),
    'dark': Color(0xFF705746),
    'steel': Color(0xFFB7B7CE),
    'fairy': Color(0xFFD685AD),
    'none': Colors.grey,
  };

  // Type Chart Effectiveness Maps (Defending multipliers)
  static const Map<String, Map<String, List<String>>> _effectiveness = {
    'normal': {
      'offense_2x': [],
      'offense_0.5x': ['rock', 'steel'],
      'offense_0x': ['ghost'],
      'defense_2x': ['fighting'],
      'defense_0.5x': [],
      'defense_0x': ['ghost'],
    },
    'fire': {
      'offense_2x': ['grass', 'ice', 'bug', 'steel'],
      'offense_0.5x': ['fire', 'water', 'rock', 'dragon'],
      'offense_0x': [],
      'defense_2x': ['water', 'ground', 'rock'],
      'defense_0.5x': ['fire', 'grass', 'ice', 'bug', 'steel', 'fairy'],
      'defense_0x': [],
    },
    'water': {
      'offense_2x': ['fire', 'ground', 'rock'],
      'offense_0.5x': ['water', 'grass', 'dragon'],
      'offense_0x': [],
      'defense_2x': ['electric', 'grass'],
      'defense_0.5x': ['fire', 'water', 'ice', 'steel'],
      'defense_0x': [],
    },
    'electric': {
      'offense_2x': ['water', 'flying'],
      'offense_0.5x': ['electric', 'grass', 'dragon'],
      'offense_0x': ['ground'],
      'defense_2x': ['ground'],
      'defense_0.5x': ['electric', 'flying', 'steel'],
      'defense_0x': [],
    },
    'grass': {
      'offense_2x': ['water', 'ground', 'rock'],
      'offense_0.5x': ['fire', 'grass', 'poison', 'flying', 'bug', 'dragon', 'steel'],
      'offense_0x': [],
      'defense_2x': ['fire', 'ice', 'poison', 'flying', 'bug'],
      'defense_0.5x': ['water', 'electric', 'grass', 'ground'],
      'defense_0x': [],
    },
    'ice': {
      'offense_2x': ['grass', 'ground', 'flying', 'dragon'],
      'offense_0.5x': ['fire', 'water', 'ice', 'steel'],
      'offense_0x': [],
      'defense_2x': ['fire', 'fighting', 'rock', 'steel'],
      'defense_0.5x': ['ice'],
      'defense_0x': [],
    },
    'fighting': {
      'offense_2x': ['normal', 'ice', 'rock', 'dark', 'steel'],
      'offense_0.5x': ['poison', 'flying', 'psychic', 'bug', 'fairy'],
      'offense_0x': ['ghost'],
      'defense_2x': ['flying', 'psychic', 'fairy'],
      'defense_0.5x': ['bug', 'rock', 'dark'],
      'defense_0x': [],
    },
    'poison': {
      'offense_2x': ['grass', 'fairy'],
      'offense_0.5x': ['poison', 'ground', 'rock', 'ghost'],
      'offense_0x': ['steel'],
      'defense_2x': ['ground', 'psychic'],
      'defense_0.5x': ['grass', 'fighting', 'poison', 'bug', 'fairy'],
      'defense_0x': [],
    },
    'ground': {
      'offense_2x': ['fire', 'electric', 'poison', 'rock', 'steel'],
      'offense_0.5x': ['grass', 'bug'],
      'offense_0x': ['flying'],
      'defense_2x': ['water', 'grass', 'ice'],
      'defense_0.5x': ['poison', 'rock'],
      'defense_0x': ['electric'],
    },
    'flying': {
      'offense_2x': ['grass', 'fighting', 'bug'],
      'offense_0.5x': ['electric', 'rock', 'steel'],
      'offense_0x': [],
      'defense_2x': ['electric', 'ice', 'rock'],
      'defense_0.5x': ['grass', 'fighting', 'bug'],
      'defense_0x': ['ground'],
    },
    'psychic': {
      'offense_2x': ['fighting', 'poison'],
      'offense_0.5x': ['psychic', 'steel'],
      'offense_0x': ['dark'],
      'defense_2x': ['bug', 'ghost', 'dark'],
      'defense_0.5x': ['fighting', 'psychic'],
      'defense_0x': [],
    },
    'bug': {
      'offense_2x': ['grass', 'psychic', 'dark'],
      'offense_0.5x': ['fire', 'fighting', 'poison', 'flying', 'ghost', 'steel', 'fairy'],
      'offense_0x': [],
      'defense_2x': ['fire', 'flying', 'rock'],
      'defense_0.5x': ['fighting', 'grass', 'ground'],
      'defense_0x': [],
    },
    'rock': {
      'offense_2x': ['fire', 'ice', 'flying', 'bug'],
      'offense_0.5x': ['fighting', 'ground', 'steel'],
      'offense_0x': [],
      'defense_2x': ['water', 'grass', 'fighting', 'ground', 'steel'],
      'defense_0.5x': ['normal', 'fire', 'poison', 'flying'],
      'defense_0x': [],
    },
    'ghost': {
      'offense_2x': ['psychic', 'ghost'],
      'offense_0.5x': ['dark'],
      'offense_0x': ['normal'],
      'defense_2x': ['ghost', 'dark'],
      'defense_0.5x': ['poison', 'bug'],
      'defense_0x': ['normal', 'fighting'],
    },
    'dragon': {
      'offense_2x': ['dragon'],
      'offense_0.5x': ['steel'],
      'offense_0x': ['fairy'],
      'defense_2x': ['ice', 'dragon', 'fairy'],
      'defense_0.5x': ['fire', 'water', 'electric', 'grass'],
      'defense_0x': [],
    },
    'dark': {
      'offense_2x': ['psychic', 'ghost'],
      'offense_0.5x': ['fighting', 'dark', 'fairy'],
      'offense_0x': [],
      'defense_2x': ['fighting', 'bug', 'fairy'],
      'defense_0.5x': ['ghost', 'dark'],
      'defense_0x': ['psychic'],
    },
    'steel': {
      'offense_2x': ['ice', 'rock', 'fairy'],
      'offense_0.5x': ['fire', 'water', 'electric', 'steel'],
      'offense_0x': [],
      'defense_2x': ['fire', 'fighting', 'ground'],
      'defense_0.5x': ['normal', 'grass', 'ice', 'flying', 'psychic', 'bug', 'rock', 'dragon', 'steel', 'fairy'],
      'defense_0x': ['poison'],
    },
    'fairy': {
      'offense_2x': ['fighting', 'dragon', 'dark'],
      'offense_0.5x': ['fire', 'poison', 'steel'],
      'offense_0x': [],
      'defense_2x': ['poison', 'steel'],
      'defense_0.5x': ['fighting', 'bug', 'dark'],
      'defense_0x': ['dragon'],
    },
  };

  /// Calculates defensive effectiveness multiplier for a specific type against this combinations.
  double _getDefenseMultiplier(String defenderType, String attackerType) {
    final typeData = _effectiveness[defenderType];
    if (typeData == null) return 1.0;

    final double2x = typeData['defense_2x'] ?? [];
    final double0_5x = typeData['defense_0.5x'] ?? [];
    final double0x = typeData['defense_0x'] ?? [];

    if (double0x.contains(attackerType)) return 0.0;
    if (double2x.contains(attackerType)) return 2.0;
    if (double0_5x.contains(attackerType)) return 0.5;
    return 1.0;
  }

  /// Combined defensive multipliers for all 18 types
  Map<String, double> _calculateCombinedDefense() {
    final Map<String, double> combined = {};
    for (final attacker in _allTypes) {
      double mult = _getDefenseMultiplier(_primaryType, attacker);
      if (_secondaryType != 'none' && _secondaryType != _primaryType) {
        mult *= _getDefenseMultiplier(_secondaryType, attacker);
      }
      combined[attacker] = mult;
    }
    return combined;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    final primaryThemeColor = _typeColors[_primaryType] ?? Colors.grey;
    final secondaryThemeColor = _typeColors[_secondaryType] ?? Colors.grey;

    final combinedDefense = _calculateCombinedDefense();

    // Group defensive matchups
    final List<String> immune0x = [];
    final List<String> resist0_25x = [];
    final List<String> resist0_5x = [];
    final List<String> weak2x = [];
    final List<String> weak4x = [];
    final List<String> neutral1x = [];

    combinedDefense.forEach((type, multiplier) {
      if (multiplier == 0.0) {
        immune0x.add(type);
      } else if (multiplier == 0.25) {
        resist0_25x.add(type);
      } else if (multiplier == 0.5) {
        resist0_5x.add(type);
      } else if (multiplier == 2.0) {
        weak2x.add(type);
      } else if (multiplier == 4.0) {
        weak4x.add(type);
      } else {
        neutral1x.add(type);
      }
    });

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('TypeDex Matchups', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const AppDrawer(currentRoute: 'type_chart'),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Selectors Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Primary Type Box
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PRIMARY TYPE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF121212) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: primaryThemeColor.withValues(alpha: 0.5), width: 1.5),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _primaryType,
                              isExpanded: true,
                              dropdownColor: isDark ? const Color(0xFF121212) : Colors.white,
                              style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                              items: _allTypes.map((t) {
                                return DropdownMenuItem<String>(
                                  value: t,
                                  child: Text(t.toUpperCase(), style: TextStyle(color: _typeColors[t])),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _primaryType = val;
                                    if (_secondaryType == _primaryType) {
                                      _secondaryType = 'none';
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Secondary Type Box
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SECONDARY TYPE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF121212) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: secondaryThemeColor.withValues(alpha: 0.5), width: 1.5),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _secondaryType,
                              isExpanded: true,
                              dropdownColor: isDark ? const Color(0xFF121212) : Colors.white,
                              style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                              items: ['none', ..._allTypes].map((t) {
                                final color = _typeColors[t] ?? Colors.grey;
                                return DropdownMenuItem<String>(
                                  value: t,
                                  child: Text(t.toUpperCase(), style: TextStyle(color: color)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _secondaryType = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Combined Badges Header Panel (Top-Left & Bottom-Right Premium Stacking)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _secondaryType == 'none'
                      ? [primaryThemeColor.withValues(alpha: 0.45), primaryThemeColor.withValues(alpha: 0.1)]
                      : [primaryThemeColor.withValues(alpha: 0.45), secondaryThemeColor.withValues(alpha: 0.45)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryThemeColor.withValues(alpha: 0.35), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: primaryThemeColor.withValues(alpha: 0.15),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Decorative Background Shield Icon
                    Positioned(
                      right: -15,
                      top: -15,
                      child: Icon(
                        Icons.shield_outlined,
                        size: 150,
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                    
                    // Top-Left Badge: Primary Type
                    Positioned(
                      left: 16,
                      top: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryThemeColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryThemeColor.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              _primaryType.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'PRIMARY TYPE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Center Slash separator
                    if (_secondaryType != 'none')
                      const Center(
                        child: Text(
                          '/',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white24,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    
                    // Bottom-Right Badge: Secondary Type
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _secondaryType == 'none' ? 'PURE ELEMENT' : 'SECONDARY TYPE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _secondaryType == 'none' ? Colors.transparent : secondaryThemeColor,
                              borderRadius: BorderRadius.circular(10),
                              border: _secondaryType == 'none' 
                                  ? Border.all(color: isDark ? Colors.white24 : Colors.black26, width: 1.5)
                                  : null,
                              boxShadow: _secondaryType == 'none'
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: secondaryThemeColor.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                            ),
                            child: Text(
                              _secondaryType == 'none' ? 'NONE' : _secondaryType.toUpperCase(),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: _secondaryType == 'none' 
                                    ? (isDark ? Colors.white38 : Colors.black45) 
                                    : Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Defending Effectiveness List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSectionHeader('DEFENSIVE COVERAGE', 'Incoming damage multipliers', isDark),
                  const SizedBox(height: 10),

                  // Weaknesses 4x
                  _buildEffectivenessRow('Double Weakness (Takes 4.0x)', weak4x, Colors.red[900]!, isDark),

                  // Weaknesses 2x
                  _buildEffectivenessRow('Weakness (Takes 2.0x)', weak2x, Colors.red[400]!, isDark),

                  // Resistances 0.5x
                  _buildEffectivenessRow('Resistance (Takes 0.5x)', resist0_5x, Colors.green[400]!, isDark),

                  // Double Resistances 0.25x
                  _buildEffectivenessRow('Double Resistance (Takes 0.25x)', resist0_25x, Colors.green[900]!, isDark),

                  // Immunities 0x
                  _buildEffectivenessRow('Immunity (Takes 0.0x)', immune0x, Colors.blueAccent, isDark),

                  // Neutral 1x
                  _buildEffectivenessRow('Neutral (Takes 1.0x)', neutral1x, Colors.grey, isDark),

                  const SizedBox(height: 32),

                  // Offensive reference sections
                  _buildSectionHeader('OFFENSIVE EFFECTIVENESS', 'Super Effective (2x) attacks when using', isDark),
                  const SizedBox(height: 12),

                  _buildOffenseCard(_primaryType, isDark),
                  if (_secondaryType != 'none' && _secondaryType != _primaryType) ...[
                    const SizedBox(height: 12),
                    _buildOffenseCard(_secondaryType, isDark),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.grey[350] : Colors.grey[800],
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildEffectivenessRow(String label, List<String> types, Color color, bool isDark) {
    if (types.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1C1C1C) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: types.map((t) {
              final badgeColor = _typeColors[t] ?? Colors.grey;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  t[0].toUpperCase() + t.substring(1),
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOffenseCard(String type, bool isDark) {
    final color = _typeColors[type] ?? Colors.grey;
    final data = _effectiveness[type] ?? {};
    final superEffectiveList = List<String>.from(data['offense_2x'] ?? []);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Attacking Moves',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (superEffectiveList.isEmpty)
            const Text('No offensive advantages.', style: TextStyle(fontSize: 11, color: Colors.grey))
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: superEffectiveList.map((t) {
                final badgeColor = _typeColors[t] ?? Colors.grey;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    t[0].toUpperCase() + t.substring(1),
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
