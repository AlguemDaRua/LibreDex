/// Pokémon build editor dialog for the Stat Comparison feature.
///
/// Shows level, nature/alignment, IVs/EVs or SPs, ability, item, status,
/// stages, and field conditions in a smooth fade+scale animated dialog.
library;

import 'package:flutter/material.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/calculator/models/battle_ruleset.dart';

import 'package:libredex/features/stat_comparison/models/comparison_entry.dart';

/// Nature dropdown labels shared with the damage calculator.
const Map<String, String> _natureLabels = {
  'hardy': 'Hardy (Neutral)', 'lonely': 'Lonely (+Atk -Def)',
  'brave': 'Brave (+Atk -Spe)', 'adamant': 'Adamant (+Atk -SpA)',
  'naughty': 'Naughty (+Atk -SpD)', 'bold': 'Bold (+Def -Atk)',
  'docile': 'Docile (Neutral)', 'relaxed': 'Relaxed (+Def -Spe)',
  'impish': 'Impish (+Def -SpA)', 'lax': 'Lax (+Def -SpD)',
  'timid': 'Timid (+Spe -Atk)', 'hasty': 'Hasty (+Spe -Def)',
  'jolly': 'Jolly (+Spe -SpA)', 'naive': 'Naive (+Spe -SpD)',
  'serious': 'Serious (Neutral)', 'modest': 'Modest (+SpA -Atk)',
  'mild': 'Mild (+SpA -Def)', 'quiet': 'Quiet (+SpA -Spe)',
  'bashful': 'Bashful (Neutral)', 'rash': 'Rash (+SpA -SpD)',
  'calm': 'Calm (+SpD -Atk)', 'gentle': 'Gentle (+SpD -Def)',
  'sassy': 'Sassy (+SpD -Spe)', 'careful': 'Careful (+SpD -SpA)',
  'quirky': 'Quirky (Neutral)',
};

const _statLabels = {'hp': 'HP', 'atk': 'Atk', 'def': 'Def', 'spa': 'SpA', 'spd': 'SpD', 'spe': 'Spe'};
const _stageStatKeys = ['atk', 'def', 'spa', 'spd', 'spe'];

const _statusOptions = ['none', 'burn', 'paralysis', 'poison', 'toxic', 'sleep', 'freeze'];
const _weatherOptions = ['none', 'sunny', 'rainy', 'sandstorm', 'snow'];
const _terrainOptions = ['none', 'electric', 'grassy', 'psychic', 'misty'];

/// Shows the build editor with the spec's animation: fade+scale, 300ms, easeOutCubic.
Future<ComparisonEntry?> showBuildEditor(
  BuildContext context, {
  required ComparisonEntry entry,
  required BattleRuleset ruleset,
  required bool showFieldControls,
}) {
  return showGeneralDialog<ComparisonEntry>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close editor',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
    pageBuilder: (ctx, anim1, anim2) => _BuildEditorDialog(
      entry: entry, ruleset: ruleset, showFieldControls: showFieldControls,
    ),
  );
}

class _BuildEditorDialog extends StatefulWidget {
  final ComparisonEntry entry;
  final BattleRuleset ruleset;
  final bool showFieldControls;

  const _BuildEditorDialog({
    required this.entry,
    required this.ruleset,
    required this.showFieldControls,
  });

  @override
  State<_BuildEditorDialog> createState() => _BuildEditorDialogState();
}

class _BuildEditorDialogState extends State<_BuildEditorDialog> {
  late ComparisonEntry _entry;
  bool get _isChampions => widget.ruleset.isChampions;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  void _update(ComparisonEntry Function(ComparisonEntry) fn) {
    setState(() => _entry = fn(_entry));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0C0C0C) : Colors.white;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(isDark),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isChampions) _levelSection(),
                      _natureSection(),
                      if (!_isChampions) _ivEvSection(isDark) else _spSection(isDark),
                      _abilityItemSection(isDark),
                      _statusSection(isDark),
                      _stageSection(isDark),
                      if (widget.showFieldControls) _fieldSection(isDark),
                      if (_showSlowStart()) _slowStartSection(isDark),
                      if (_showProtoQuark()) _protoQuarkSection(isDark),
                      if (_showDefeatist()) _defeatistSection(isDark),
                    ],
                  ),
                ),
              ),
              _footer(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(bool isDark) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
    child: Row(
      children: [
        Icon(Icons.tune_rounded, color: AppTheme.pokemonRed, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(
          _entry.pokemon.name,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        )),
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );

  Widget _footer(bool isDark) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.pokemonRed,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () => Navigator.pop(context, _entry),
        child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
    ),
  );

  // ── Sections ────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
  );

  Widget _levelSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionHeader('LEVEL'),
      Row(children: [
        Expanded(child: Slider(
          value: _entry.level.toDouble(), min: 1, max: 100, divisions: 99,
          activeColor: AppTheme.pokemonRed,
          onChanged: (v) => _update((e) => e.copyWith(level: v.round())),
        )),
        SizedBox(width: 40, child: Text('${_entry.level}', style: const TextStyle(fontWeight: FontWeight.w900), textAlign: TextAlign.center)),
      ]),
    ],
  );

  Widget _natureSection() {
    final natures = _isChampions
        ? Map.fromEntries(_natureLabels.entries.where((e) => ChampionsRules.isValidAlignment(e.key)))
        : _natureLabels;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(_isChampions ? 'STAT ALIGNMENT' : 'NATURE'),
        _dropdown<String>(
          value: natures.containsKey(_entry.nature) ? _entry.nature : natures.keys.first,
          items: natures.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: (v) => _update((e) => e.copyWith(nature: v)),
        ),
      ],
    );
  }

  Widget _ivEvSection(bool isDark) {
    final totalEvs = _entry.evs.values.fold(0, (s, v) => s + v);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('IVs'),
        _statGrid(
          values: _entry.ivs, max: 31,
          onChanged: (key, val) => _update((e) {
            final ivs = Map<String, int>.from(e.ivs)..[key] = val;
            return e.copyWith(ivs: ivs);
          }),
        ),
        _sectionHeader('EVs ($totalEvs / 510)'),
        _statGrid(
          values: _entry.evs, max: 252, step: 4,
          onChanged: (key, val) => _update((e) {
            final evs = Map<String, int>.from(e.evs)..[key] = val;
            final total = evs.values.fold(0, (s, v) => s + v);
            if (total > 510) return e; // Reject
            return e.copyWith(evs: evs);
          }),
        ),
      ],
    );
  }

  Widget _spSection(bool isDark) {
    final totalSps = _entry.sps.values.fold(0, (s, v) => s + v);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('STAT POINTS ($totalSps / ${ChampionsRules.totalStatPoints})'),
        _statGrid(
          values: _entry.sps, max: ChampionsRules.maxStatPointsPerStat,
          onChanged: (key, val) => _update((e) {
            final sps = Map<String, int>.from(e.sps);
            sps[key] = ChampionsRules.clampStatPoint(sps, key, val);
            return e.copyWith(sps: sps);
          }),
        ),
      ],
    );
  }

  Widget _abilityItemSection(bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionHeader('ABILITY'),
      TextFormField(
        initialValue: _entry.ability ?? '',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        decoration: _inputDeco('e.g. Huge Power'),
        onChanged: (v) => _update((e) => e.copyWith(ability: v.isEmpty ? null : v.trim())),
      ),
      _sectionHeader('HELD ITEM'),
      TextFormField(
        initialValue: _entry.heldItem,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        decoration: _inputDeco('e.g. Choice Band'),
        onChanged: (v) => _update((e) => e.copyWith(heldItem: v.isEmpty ? 'None' : v.trim())),
      ),
    ],
  );

  Widget _statusSection(bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionHeader('STATUS'),
      _dropdown<String>(
        value: _statusOptions.contains(_entry.status) ? _entry.status : 'none',
        items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s == 'none' ? 'None' : s[0].toUpperCase() + s.substring(1), style: const TextStyle(fontSize: 12)))).toList(),
        onChanged: (v) => _update((e) => e.copyWith(status: v)),
      ),
    ],
  );

  Widget _stageSection(bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionHeader('STAT STAGES'),
      Wrap(spacing: 8, runSpacing: 4, children: [
        for (final key in _stageStatKeys)
          _stageChip(key, _entry.stages[key] ?? 0),
      ]),
    ],
  );

  Widget _stageChip(String key, int stage) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('${_statLabels[key]}:', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
      IconButton(
        icon: const Icon(Icons.remove, size: 14),
        padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        onPressed: stage > -6 ? () => _update((e) {
          final stages = Map<String, int>.from(e.stages)..[key] = stage - 1;
          return e.copyWith(stages: stages);
        }) : null,
      ),
      Text('${stage > 0 ? '+' : ''}$stage', style: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w900,
        color: stage > 0 ? Colors.green : stage < 0 ? Colors.red : Colors.grey,
      )),
      IconButton(
        icon: const Icon(Icons.add, size: 14),
        padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        onPressed: stage < 6 ? () => _update((e) {
          final stages = Map<String, int>.from(e.stages)..[key] = stage + 1;
          return e.copyWith(stages: stages);
        }) : null,
      ),
    ]);
  }

  Widget _fieldSection(bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionHeader('WEATHER'),
      _dropdown<String>(
        value: _weatherOptions.contains(_entry.weather) ? _entry.weather : 'none',
        items: _weatherOptions.map((w) => DropdownMenuItem(value: w, child: Text(w == 'none' ? 'None' : w[0].toUpperCase() + w.substring(1), style: const TextStyle(fontSize: 12)))).toList(),
        onChanged: (v) => _update((e) => e.copyWith(weather: v)),
      ),
      _sectionHeader('TERRAIN'),
      _dropdown<String>(
        value: _terrainOptions.contains(_entry.terrain) ? _entry.terrain : 'none',
        items: _terrainOptions.map((t) => DropdownMenuItem(value: t, child: Text(t == 'none' ? 'None' : t[0].toUpperCase() + t.substring(1), style: const TextStyle(fontSize: 12)))).toList(),
        onChanged: (v) => _update((e) => e.copyWith(terrain: v)),
      ),
      SwitchListTile.adaptive(
        title: const Text('Trick Room', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        value: _entry.trickRoom,
        activeTrackColor: AppTheme.pokemonRed,
        contentPadding: EdgeInsets.zero, dense: true,
        onChanged: (v) => _update((e) => e.copyWith(trickRoom: v)),
      ),
    ],
  );

  bool _showSlowStart() => (_entry.ability ?? '').toLowerCase().replaceAll(' ', '') == 'slowstart';
  bool _showProtoQuark() {
    final a = (_entry.ability ?? '').toLowerCase().replaceAll(' ', '');
    return a == 'protosynthesis' || a == 'quarkdrive';
  }
  bool _showDefeatist() => (_entry.ability ?? '').toLowerCase().replaceAll(' ', '') == 'defeatist';

  Widget _slowStartSection(bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionHeader('SLOW START — TURNS ON FIELD'),
      Row(children: [
        Expanded(child: Slider(
          value: _entry.turnsOnField.toDouble(), min: 0, max: 5, divisions: 5,
          activeColor: AppTheme.pokemonRed,
          onChanged: (v) => _update((e) => e.copyWith(turnsOnField: v.round())),
        )),
        Text('${_entry.turnsOnField}', style: TextStyle(
          fontWeight: FontWeight.w900,
          color: _entry.turnsOnField < 5 ? Colors.red : Colors.green,
        )),
      ]),
      Text(
        _entry.turnsOnField < 5 ? 'Atk ×0.5, Spe ×0.5' : 'Normal stats',
        style: TextStyle(fontSize: 10, color: _entry.turnsOnField < 5 ? Colors.red : Colors.green),
      ),
    ],
  );

  Widget _protoQuarkSection(bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionHeader('PROTOSYNTHESIS / QUARK DRIVE'),
      _dropdown<ProtoQuarkState>(
        value: _entry.protoQuarkState,
        items: ProtoQuarkState.values.map((s) => DropdownMenuItem(
          value: s,
          child: Text(switch (s) {
            ProtoQuarkState.inactive => 'Inactive',
            ProtoQuarkState.automatic => 'Automatic',
            ProtoQuarkState.forceActive => 'Force Active',
          }, style: const TextStyle(fontSize: 12)),
        )).toList(),
        onChanged: (v) => _update((e) => e.copyWith(protoQuarkState: v)),
      ),
    ],
  );

  Widget _defeatistSection(bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionHeader('HP % (FOR DEFEATIST)'),
      Row(children: [
        Expanded(child: Slider(
          value: _entry.hpPercent, min: 1, max: 100, divisions: 99,
          activeColor: _entry.hpPercent <= 50 ? Colors.red : AppTheme.pokemonRed,
          onChanged: (v) => _update((e) => e.copyWith(hpPercent: v)),
        )),
        Text('${_entry.hpPercent.round()}%', style: TextStyle(
          fontWeight: FontWeight.w900,
          color: _entry.hpPercent <= 50 ? Colors.red : null,
        )),
      ]),
    ],
  );

  // ── Shared Widgets ──────────────────────────────────────────────────────

  Widget _dropdown<T>({required T value, required List<DropdownMenuItem<T>> items, required ValueChanged<T> onChanged}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value, isExpanded: true,
          style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black, fontSize: 12),
          items: items,
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }

  Widget _statGrid({
    required Map<String, int> values,
    required int max,
    int step = 1,
    required void Function(String key, int value) onChanged,
  }) {
    return Wrap(spacing: 6, runSpacing: 6, children: [
      for (final key in _statLabels.keys)
        SizedBox(
          width: 96,
          child: Row(children: [
            SizedBox(width: 28, child: Text(_statLabels[key]!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
            Expanded(child: SizedBox(
              height: 28,
              child: TextFormField(
                initialValue: '${values[key] ?? 0}',
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onChanged: (v) {
                  final parsed = int.tryParse(v) ?? 0;
                  onChanged(key, parsed.clamp(0, max));
                },
              ),
            )),
          ]),
        ),
    ]);
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    hintText: hint, hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );
}
