// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PokemonTableTable extends PokemonTable
    with TableInfo<$PokemonTableTable, Pokemon> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formMeta = const VerificationMeta('form');
  @override
  late final GeneratedColumn<String> form = GeneratedColumn<String>(
    'form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _type1Meta = const VerificationMeta('type1');
  @override
  late final GeneratedColumn<String> type1 = GeneratedColumn<String>(
    'type1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _type2Meta = const VerificationMeta('type2');
  @override
  late final GeneratedColumn<String> type2 = GeneratedColumn<String>(
    'type2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseHpMeta = const VerificationMeta('baseHp');
  @override
  late final GeneratedColumn<int> baseHp = GeneratedColumn<int>(
    'base_hp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseAtkMeta = const VerificationMeta(
    'baseAtk',
  );
  @override
  late final GeneratedColumn<int> baseAtk = GeneratedColumn<int>(
    'base_atk',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseDefMeta = const VerificationMeta(
    'baseDef',
  );
  @override
  late final GeneratedColumn<int> baseDef = GeneratedColumn<int>(
    'base_def',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseSpAtkMeta = const VerificationMeta(
    'baseSpAtk',
  );
  @override
  late final GeneratedColumn<int> baseSpAtk = GeneratedColumn<int>(
    'base_sp_atk',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseSpDefMeta = const VerificationMeta(
    'baseSpDef',
  );
  @override
  late final GeneratedColumn<int> baseSpDef = GeneratedColumn<int>(
    'base_sp_def',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseSpdMeta = const VerificationMeta(
    'baseSpd',
  );
  @override
  late final GeneratedColumn<int> baseSpd = GeneratedColumn<int>(
    'base_spd',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLegendaryMeta = const VerificationMeta(
    'isLegendary',
  );
  @override
  late final GeneratedColumn<bool> isLegendary = GeneratedColumn<bool>(
    'is_legendary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_legendary" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isMythicalMeta = const VerificationMeta(
    'isMythical',
  );
  @override
  late final GeneratedColumn<bool> isMythical = GeneratedColumn<bool>(
    'is_mythical',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mythical" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isParadoxMeta = const VerificationMeta(
    'isParadox',
  );
  @override
  late final GeneratedColumn<bool> isParadox = GeneratedColumn<bool>(
    'is_paradox',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paradox" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isUltraBeastMeta = const VerificationMeta(
    'isUltraBeast',
  );
  @override
  late final GeneratedColumn<bool> isUltraBeast = GeneratedColumn<bool>(
    'is_ultra_beast',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_ultra_beast" IN (0, 1))',
    ),
  );
  static const VerificationMeta _spriteUrlMeta = const VerificationMeta(
    'spriteUrl',
  );
  @override
  late final GeneratedColumn<String> spriteUrl = GeneratedColumn<String>(
    'sprite_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shinySpriteUrlMeta = const VerificationMeta(
    'shinySpriteUrl',
  );
  @override
  late final GeneratedColumn<String> shinySpriteUrl = GeneratedColumn<String>(
    'shiny_sprite_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nationalDexNumberMeta = const VerificationMeta(
    'nationalDexNumber',
  );
  @override
  late final GeneratedColumn<int> nationalDexNumber = GeneratedColumn<int>(
    'national_dex_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(0),
  );
  static const VerificationMeta _generationMeta = const VerificationMeta(
    'generation',
  );
  @override
  late final GeneratedColumn<int> generation = GeneratedColumn<int>(
    'generation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(1),
  );
  static const VerificationMeta _evolutionStageMeta = const VerificationMeta(
    'evolutionStage',
  );
  @override
  late final GeneratedColumn<int> evolutionStage = GeneratedColumn<int>(
    'evolution_stage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(0),
  );
  static const VerificationMeta _eggGroupsMeta = const VerificationMeta(
    'eggGroups',
  );
  @override
  late final GeneratedColumn<String> eggGroups = GeneratedColumn<String>(
    'egg_groups',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formSourceMeta = const VerificationMeta(
    'formSource',
  );
  @override
  late final GeneratedColumn<String> formSource = GeneratedColumn<String>(
    'form_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dlcSourceMeta = const VerificationMeta(
    'dlcSource',
  );
  @override
  late final GeneratedColumn<String> dlcSource = GeneratedColumn<String>(
    'dlc_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isChampionsMeta = const VerificationMeta(
    'isChampions',
  );
  @override
  late final GeneratedColumn<bool> isChampions = GeneratedColumn<bool>(
    'is_champions',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_champions" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isLegendsZAMeta = const VerificationMeta(
    'isLegendsZA',
  );
  @override
  late final GeneratedColumn<bool> isLegendsZA = GeneratedColumn<bool>(
    'is_legends_z_a',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_legends_z_a" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    form,
    type1,
    type2,
    baseHp,
    baseAtk,
    baseDef,
    baseSpAtk,
    baseSpDef,
    baseSpd,
    isLegendary,
    isMythical,
    isParadox,
    isUltraBeast,
    spriteUrl,
    shinySpriteUrl,
    nationalDexNumber,
    generation,
    evolutionStage,
    eggGroups,
    formSource,
    dlcSource,
    isChampions,
    isLegendsZA,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pokemon> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('form')) {
      context.handle(
        _formMeta,
        form.isAcceptableOrUnknown(data['form']!, _formMeta),
      );
    } else if (isInserting) {
      context.missing(_formMeta);
    }
    if (data.containsKey('type1')) {
      context.handle(
        _type1Meta,
        type1.isAcceptableOrUnknown(data['type1']!, _type1Meta),
      );
    } else if (isInserting) {
      context.missing(_type1Meta);
    }
    if (data.containsKey('type2')) {
      context.handle(
        _type2Meta,
        type2.isAcceptableOrUnknown(data['type2']!, _type2Meta),
      );
    }
    if (data.containsKey('base_hp')) {
      context.handle(
        _baseHpMeta,
        baseHp.isAcceptableOrUnknown(data['base_hp']!, _baseHpMeta),
      );
    } else if (isInserting) {
      context.missing(_baseHpMeta);
    }
    if (data.containsKey('base_atk')) {
      context.handle(
        _baseAtkMeta,
        baseAtk.isAcceptableOrUnknown(data['base_atk']!, _baseAtkMeta),
      );
    } else if (isInserting) {
      context.missing(_baseAtkMeta);
    }
    if (data.containsKey('base_def')) {
      context.handle(
        _baseDefMeta,
        baseDef.isAcceptableOrUnknown(data['base_def']!, _baseDefMeta),
      );
    } else if (isInserting) {
      context.missing(_baseDefMeta);
    }
    if (data.containsKey('base_sp_atk')) {
      context.handle(
        _baseSpAtkMeta,
        baseSpAtk.isAcceptableOrUnknown(data['base_sp_atk']!, _baseSpAtkMeta),
      );
    } else if (isInserting) {
      context.missing(_baseSpAtkMeta);
    }
    if (data.containsKey('base_sp_def')) {
      context.handle(
        _baseSpDefMeta,
        baseSpDef.isAcceptableOrUnknown(data['base_sp_def']!, _baseSpDefMeta),
      );
    } else if (isInserting) {
      context.missing(_baseSpDefMeta);
    }
    if (data.containsKey('base_spd')) {
      context.handle(
        _baseSpdMeta,
        baseSpd.isAcceptableOrUnknown(data['base_spd']!, _baseSpdMeta),
      );
    } else if (isInserting) {
      context.missing(_baseSpdMeta);
    }
    if (data.containsKey('is_legendary')) {
      context.handle(
        _isLegendaryMeta,
        isLegendary.isAcceptableOrUnknown(
          data['is_legendary']!,
          _isLegendaryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isLegendaryMeta);
    }
    if (data.containsKey('is_mythical')) {
      context.handle(
        _isMythicalMeta,
        isMythical.isAcceptableOrUnknown(data['is_mythical']!, _isMythicalMeta),
      );
    } else if (isInserting) {
      context.missing(_isMythicalMeta);
    }
    if (data.containsKey('is_paradox')) {
      context.handle(
        _isParadoxMeta,
        isParadox.isAcceptableOrUnknown(data['is_paradox']!, _isParadoxMeta),
      );
    } else if (isInserting) {
      context.missing(_isParadoxMeta);
    }
    if (data.containsKey('is_ultra_beast')) {
      context.handle(
        _isUltraBeastMeta,
        isUltraBeast.isAcceptableOrUnknown(
          data['is_ultra_beast']!,
          _isUltraBeastMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isUltraBeastMeta);
    }
    if (data.containsKey('sprite_url')) {
      context.handle(
        _spriteUrlMeta,
        spriteUrl.isAcceptableOrUnknown(data['sprite_url']!, _spriteUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_spriteUrlMeta);
    }
    if (data.containsKey('shiny_sprite_url')) {
      context.handle(
        _shinySpriteUrlMeta,
        shinySpriteUrl.isAcceptableOrUnknown(
          data['shiny_sprite_url']!,
          _shinySpriteUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shinySpriteUrlMeta);
    }
    if (data.containsKey('national_dex_number')) {
      context.handle(
        _nationalDexNumberMeta,
        nationalDexNumber.isAcceptableOrUnknown(
          data['national_dex_number']!,
          _nationalDexNumberMeta,
        ),
      );
    }
    if (data.containsKey('generation')) {
      context.handle(
        _generationMeta,
        generation.isAcceptableOrUnknown(data['generation']!, _generationMeta),
      );
    }
    if (data.containsKey('evolution_stage')) {
      context.handle(
        _evolutionStageMeta,
        evolutionStage.isAcceptableOrUnknown(
          data['evolution_stage']!,
          _evolutionStageMeta,
        ),
      );
    }
    if (data.containsKey('egg_groups')) {
      context.handle(
        _eggGroupsMeta,
        eggGroups.isAcceptableOrUnknown(data['egg_groups']!, _eggGroupsMeta),
      );
    }
    if (data.containsKey('form_source')) {
      context.handle(
        _formSourceMeta,
        formSource.isAcceptableOrUnknown(data['form_source']!, _formSourceMeta),
      );
    }
    if (data.containsKey('dlc_source')) {
      context.handle(
        _dlcSourceMeta,
        dlcSource.isAcceptableOrUnknown(data['dlc_source']!, _dlcSourceMeta),
      );
    }
    if (data.containsKey('is_champions')) {
      context.handle(
        _isChampionsMeta,
        isChampions.isAcceptableOrUnknown(
          data['is_champions']!,
          _isChampionsMeta,
        ),
      );
    }
    if (data.containsKey('is_legends_z_a')) {
      context.handle(
        _isLegendsZAMeta,
        isLegendsZA.isAcceptableOrUnknown(
          data['is_legends_z_a']!,
          _isLegendsZAMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pokemon map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pokemon(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      form: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form'],
      )!,
      type1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type1'],
      )!,
      type2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type2'],
      ),
      baseHp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_hp'],
      )!,
      baseAtk: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_atk'],
      )!,
      baseDef: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_def'],
      )!,
      baseSpAtk: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_sp_atk'],
      )!,
      baseSpDef: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_sp_def'],
      )!,
      baseSpd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_spd'],
      )!,
      isLegendary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_legendary'],
      )!,
      isMythical: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mythical'],
      )!,
      isParadox: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paradox'],
      )!,
      isUltraBeast: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ultra_beast'],
      )!,
      spriteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sprite_url'],
      )!,
      shinySpriteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shiny_sprite_url'],
      )!,
      nationalDexNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}national_dex_number'],
      )!,
      generation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generation'],
      )!,
      evolutionStage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}evolution_stage'],
      )!,
      eggGroups: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}egg_groups'],
      ),
      formSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form_source'],
      ),
      dlcSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dlc_source'],
      ),
      isChampions: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_champions'],
      )!,
      isLegendsZA: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_legends_z_a'],
      )!,
    );
  }

  @override
  $PokemonTableTable createAlias(String alias) {
    return $PokemonTableTable(attachedDatabase, alias);
  }
}

class Pokemon extends DataClass implements Insertable<Pokemon> {
  final int id;
  final String name;
  final String form;
  final String type1;
  final String? type2;
  final int baseHp;
  final int baseAtk;
  final int baseDef;
  final int baseSpAtk;
  final int baseSpDef;
  final int baseSpd;
  final bool isLegendary;
  final bool isMythical;
  final bool isParadox;
  final bool isUltraBeast;
  final String spriteUrl;
  final String shinySpriteUrl;
  final int nationalDexNumber;
  final int generation;
  final int evolutionStage;
  final String? eggGroups;
  final String? formSource;
  final String? dlcSource;
  final bool isChampions;
  final bool isLegendsZA;
  const Pokemon({
    required this.id,
    required this.name,
    required this.form,
    required this.type1,
    this.type2,
    required this.baseHp,
    required this.baseAtk,
    required this.baseDef,
    required this.baseSpAtk,
    required this.baseSpDef,
    required this.baseSpd,
    required this.isLegendary,
    required this.isMythical,
    required this.isParadox,
    required this.isUltraBeast,
    required this.spriteUrl,
    required this.shinySpriteUrl,
    required this.nationalDexNumber,
    required this.generation,
    required this.evolutionStage,
    this.eggGroups,
    this.formSource,
    this.dlcSource,
    required this.isChampions,
    required this.isLegendsZA,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['form'] = Variable<String>(form);
    map['type1'] = Variable<String>(type1);
    if (!nullToAbsent || type2 != null) {
      map['type2'] = Variable<String>(type2);
    }
    map['base_hp'] = Variable<int>(baseHp);
    map['base_atk'] = Variable<int>(baseAtk);
    map['base_def'] = Variable<int>(baseDef);
    map['base_sp_atk'] = Variable<int>(baseSpAtk);
    map['base_sp_def'] = Variable<int>(baseSpDef);
    map['base_spd'] = Variable<int>(baseSpd);
    map['is_legendary'] = Variable<bool>(isLegendary);
    map['is_mythical'] = Variable<bool>(isMythical);
    map['is_paradox'] = Variable<bool>(isParadox);
    map['is_ultra_beast'] = Variable<bool>(isUltraBeast);
    map['sprite_url'] = Variable<String>(spriteUrl);
    map['shiny_sprite_url'] = Variable<String>(shinySpriteUrl);
    map['national_dex_number'] = Variable<int>(nationalDexNumber);
    map['generation'] = Variable<int>(generation);
    map['evolution_stage'] = Variable<int>(evolutionStage);
    if (!nullToAbsent || eggGroups != null) {
      map['egg_groups'] = Variable<String>(eggGroups);
    }
    if (!nullToAbsent || formSource != null) {
      map['form_source'] = Variable<String>(formSource);
    }
    if (!nullToAbsent || dlcSource != null) {
      map['dlc_source'] = Variable<String>(dlcSource);
    }
    map['is_champions'] = Variable<bool>(isChampions);
    map['is_legends_z_a'] = Variable<bool>(isLegendsZA);
    return map;
  }

  PokemonTableCompanion toCompanion(bool nullToAbsent) {
    return PokemonTableCompanion(
      id: Value(id),
      name: Value(name),
      form: Value(form),
      type1: Value(type1),
      type2: type2 == null && nullToAbsent
          ? const Value.absent()
          : Value(type2),
      baseHp: Value(baseHp),
      baseAtk: Value(baseAtk),
      baseDef: Value(baseDef),
      baseSpAtk: Value(baseSpAtk),
      baseSpDef: Value(baseSpDef),
      baseSpd: Value(baseSpd),
      isLegendary: Value(isLegendary),
      isMythical: Value(isMythical),
      isParadox: Value(isParadox),
      isUltraBeast: Value(isUltraBeast),
      spriteUrl: Value(spriteUrl),
      shinySpriteUrl: Value(shinySpriteUrl),
      nationalDexNumber: Value(nationalDexNumber),
      generation: Value(generation),
      evolutionStage: Value(evolutionStage),
      eggGroups: eggGroups == null && nullToAbsent
          ? const Value.absent()
          : Value(eggGroups),
      formSource: formSource == null && nullToAbsent
          ? const Value.absent()
          : Value(formSource),
      dlcSource: dlcSource == null && nullToAbsent
          ? const Value.absent()
          : Value(dlcSource),
      isChampions: Value(isChampions),
      isLegendsZA: Value(isLegendsZA),
    );
  }

  factory Pokemon.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pokemon(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      form: serializer.fromJson<String>(json['form']),
      type1: serializer.fromJson<String>(json['type1']),
      type2: serializer.fromJson<String?>(json['type2']),
      baseHp: serializer.fromJson<int>(json['baseHp']),
      baseAtk: serializer.fromJson<int>(json['baseAtk']),
      baseDef: serializer.fromJson<int>(json['baseDef']),
      baseSpAtk: serializer.fromJson<int>(json['baseSpAtk']),
      baseSpDef: serializer.fromJson<int>(json['baseSpDef']),
      baseSpd: serializer.fromJson<int>(json['baseSpd']),
      isLegendary: serializer.fromJson<bool>(json['isLegendary']),
      isMythical: serializer.fromJson<bool>(json['isMythical']),
      isParadox: serializer.fromJson<bool>(json['isParadox']),
      isUltraBeast: serializer.fromJson<bool>(json['isUltraBeast']),
      spriteUrl: serializer.fromJson<String>(json['spriteUrl']),
      shinySpriteUrl: serializer.fromJson<String>(json['shinySpriteUrl']),
      nationalDexNumber: serializer.fromJson<int>(json['nationalDexNumber']),
      generation: serializer.fromJson<int>(json['generation']),
      evolutionStage: serializer.fromJson<int>(json['evolutionStage']),
      eggGroups: serializer.fromJson<String?>(json['eggGroups']),
      formSource: serializer.fromJson<String?>(json['formSource']),
      dlcSource: serializer.fromJson<String?>(json['dlcSource']),
      isChampions: serializer.fromJson<bool>(json['isChampions']),
      isLegendsZA: serializer.fromJson<bool>(json['isLegendsZA']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'form': serializer.toJson<String>(form),
      'type1': serializer.toJson<String>(type1),
      'type2': serializer.toJson<String?>(type2),
      'baseHp': serializer.toJson<int>(baseHp),
      'baseAtk': serializer.toJson<int>(baseAtk),
      'baseDef': serializer.toJson<int>(baseDef),
      'baseSpAtk': serializer.toJson<int>(baseSpAtk),
      'baseSpDef': serializer.toJson<int>(baseSpDef),
      'baseSpd': serializer.toJson<int>(baseSpd),
      'isLegendary': serializer.toJson<bool>(isLegendary),
      'isMythical': serializer.toJson<bool>(isMythical),
      'isParadox': serializer.toJson<bool>(isParadox),
      'isUltraBeast': serializer.toJson<bool>(isUltraBeast),
      'spriteUrl': serializer.toJson<String>(spriteUrl),
      'shinySpriteUrl': serializer.toJson<String>(shinySpriteUrl),
      'nationalDexNumber': serializer.toJson<int>(nationalDexNumber),
      'generation': serializer.toJson<int>(generation),
      'evolutionStage': serializer.toJson<int>(evolutionStage),
      'eggGroups': serializer.toJson<String?>(eggGroups),
      'formSource': serializer.toJson<String?>(formSource),
      'dlcSource': serializer.toJson<String?>(dlcSource),
      'isChampions': serializer.toJson<bool>(isChampions),
      'isLegendsZA': serializer.toJson<bool>(isLegendsZA),
    };
  }

  Pokemon copyWith({
    int? id,
    String? name,
    String? form,
    String? type1,
    Value<String?> type2 = const Value.absent(),
    int? baseHp,
    int? baseAtk,
    int? baseDef,
    int? baseSpAtk,
    int? baseSpDef,
    int? baseSpd,
    bool? isLegendary,
    bool? isMythical,
    bool? isParadox,
    bool? isUltraBeast,
    String? spriteUrl,
    String? shinySpriteUrl,
    int? nationalDexNumber,
    int? generation,
    int? evolutionStage,
    Value<String?> eggGroups = const Value.absent(),
    Value<String?> formSource = const Value.absent(),
    Value<String?> dlcSource = const Value.absent(),
    bool? isChampions,
    bool? isLegendsZA,
  }) => Pokemon(
    id: id ?? this.id,
    name: name ?? this.name,
    form: form ?? this.form,
    type1: type1 ?? this.type1,
    type2: type2.present ? type2.value : this.type2,
    baseHp: baseHp ?? this.baseHp,
    baseAtk: baseAtk ?? this.baseAtk,
    baseDef: baseDef ?? this.baseDef,
    baseSpAtk: baseSpAtk ?? this.baseSpAtk,
    baseSpDef: baseSpDef ?? this.baseSpDef,
    baseSpd: baseSpd ?? this.baseSpd,
    isLegendary: isLegendary ?? this.isLegendary,
    isMythical: isMythical ?? this.isMythical,
    isParadox: isParadox ?? this.isParadox,
    isUltraBeast: isUltraBeast ?? this.isUltraBeast,
    spriteUrl: spriteUrl ?? this.spriteUrl,
    shinySpriteUrl: shinySpriteUrl ?? this.shinySpriteUrl,
    nationalDexNumber: nationalDexNumber ?? this.nationalDexNumber,
    generation: generation ?? this.generation,
    evolutionStage: evolutionStage ?? this.evolutionStage,
    eggGroups: eggGroups.present ? eggGroups.value : this.eggGroups,
    formSource: formSource.present ? formSource.value : this.formSource,
    dlcSource: dlcSource.present ? dlcSource.value : this.dlcSource,
    isChampions: isChampions ?? this.isChampions,
    isLegendsZA: isLegendsZA ?? this.isLegendsZA,
  );
  Pokemon copyWithCompanion(PokemonTableCompanion data) {
    return Pokemon(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      form: data.form.present ? data.form.value : this.form,
      type1: data.type1.present ? data.type1.value : this.type1,
      type2: data.type2.present ? data.type2.value : this.type2,
      baseHp: data.baseHp.present ? data.baseHp.value : this.baseHp,
      baseAtk: data.baseAtk.present ? data.baseAtk.value : this.baseAtk,
      baseDef: data.baseDef.present ? data.baseDef.value : this.baseDef,
      baseSpAtk: data.baseSpAtk.present ? data.baseSpAtk.value : this.baseSpAtk,
      baseSpDef: data.baseSpDef.present ? data.baseSpDef.value : this.baseSpDef,
      baseSpd: data.baseSpd.present ? data.baseSpd.value : this.baseSpd,
      isLegendary: data.isLegendary.present
          ? data.isLegendary.value
          : this.isLegendary,
      isMythical: data.isMythical.present
          ? data.isMythical.value
          : this.isMythical,
      isParadox: data.isParadox.present ? data.isParadox.value : this.isParadox,
      isUltraBeast: data.isUltraBeast.present
          ? data.isUltraBeast.value
          : this.isUltraBeast,
      spriteUrl: data.spriteUrl.present ? data.spriteUrl.value : this.spriteUrl,
      shinySpriteUrl: data.shinySpriteUrl.present
          ? data.shinySpriteUrl.value
          : this.shinySpriteUrl,
      nationalDexNumber: data.nationalDexNumber.present
          ? data.nationalDexNumber.value
          : this.nationalDexNumber,
      generation: data.generation.present
          ? data.generation.value
          : this.generation,
      evolutionStage: data.evolutionStage.present
          ? data.evolutionStage.value
          : this.evolutionStage,
      eggGroups: data.eggGroups.present ? data.eggGroups.value : this.eggGroups,
      formSource: data.formSource.present
          ? data.formSource.value
          : this.formSource,
      dlcSource: data.dlcSource.present ? data.dlcSource.value : this.dlcSource,
      isChampions: data.isChampions.present
          ? data.isChampions.value
          : this.isChampions,
      isLegendsZA: data.isLegendsZA.present
          ? data.isLegendsZA.value
          : this.isLegendsZA,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pokemon(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('form: $form, ')
          ..write('type1: $type1, ')
          ..write('type2: $type2, ')
          ..write('baseHp: $baseHp, ')
          ..write('baseAtk: $baseAtk, ')
          ..write('baseDef: $baseDef, ')
          ..write('baseSpAtk: $baseSpAtk, ')
          ..write('baseSpDef: $baseSpDef, ')
          ..write('baseSpd: $baseSpd, ')
          ..write('isLegendary: $isLegendary, ')
          ..write('isMythical: $isMythical, ')
          ..write('isParadox: $isParadox, ')
          ..write('isUltraBeast: $isUltraBeast, ')
          ..write('spriteUrl: $spriteUrl, ')
          ..write('shinySpriteUrl: $shinySpriteUrl, ')
          ..write('nationalDexNumber: $nationalDexNumber, ')
          ..write('generation: $generation, ')
          ..write('evolutionStage: $evolutionStage, ')
          ..write('eggGroups: $eggGroups, ')
          ..write('formSource: $formSource, ')
          ..write('dlcSource: $dlcSource, ')
          ..write('isChampions: $isChampions, ')
          ..write('isLegendsZA: $isLegendsZA')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    form,
    type1,
    type2,
    baseHp,
    baseAtk,
    baseDef,
    baseSpAtk,
    baseSpDef,
    baseSpd,
    isLegendary,
    isMythical,
    isParadox,
    isUltraBeast,
    spriteUrl,
    shinySpriteUrl,
    nationalDexNumber,
    generation,
    evolutionStage,
    eggGroups,
    formSource,
    dlcSource,
    isChampions,
    isLegendsZA,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pokemon &&
          other.id == this.id &&
          other.name == this.name &&
          other.form == this.form &&
          other.type1 == this.type1 &&
          other.type2 == this.type2 &&
          other.baseHp == this.baseHp &&
          other.baseAtk == this.baseAtk &&
          other.baseDef == this.baseDef &&
          other.baseSpAtk == this.baseSpAtk &&
          other.baseSpDef == this.baseSpDef &&
          other.baseSpd == this.baseSpd &&
          other.isLegendary == this.isLegendary &&
          other.isMythical == this.isMythical &&
          other.isParadox == this.isParadox &&
          other.isUltraBeast == this.isUltraBeast &&
          other.spriteUrl == this.spriteUrl &&
          other.shinySpriteUrl == this.shinySpriteUrl &&
          other.nationalDexNumber == this.nationalDexNumber &&
          other.generation == this.generation &&
          other.evolutionStage == this.evolutionStage &&
          other.eggGroups == this.eggGroups &&
          other.formSource == this.formSource &&
          other.dlcSource == this.dlcSource &&
          other.isChampions == this.isChampions &&
          other.isLegendsZA == this.isLegendsZA);
}

class PokemonTableCompanion extends UpdateCompanion<Pokemon> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> form;
  final Value<String> type1;
  final Value<String?> type2;
  final Value<int> baseHp;
  final Value<int> baseAtk;
  final Value<int> baseDef;
  final Value<int> baseSpAtk;
  final Value<int> baseSpDef;
  final Value<int> baseSpd;
  final Value<bool> isLegendary;
  final Value<bool> isMythical;
  final Value<bool> isParadox;
  final Value<bool> isUltraBeast;
  final Value<String> spriteUrl;
  final Value<String> shinySpriteUrl;
  final Value<int> nationalDexNumber;
  final Value<int> generation;
  final Value<int> evolutionStage;
  final Value<String?> eggGroups;
  final Value<String?> formSource;
  final Value<String?> dlcSource;
  final Value<bool> isChampions;
  final Value<bool> isLegendsZA;
  const PokemonTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.form = const Value.absent(),
    this.type1 = const Value.absent(),
    this.type2 = const Value.absent(),
    this.baseHp = const Value.absent(),
    this.baseAtk = const Value.absent(),
    this.baseDef = const Value.absent(),
    this.baseSpAtk = const Value.absent(),
    this.baseSpDef = const Value.absent(),
    this.baseSpd = const Value.absent(),
    this.isLegendary = const Value.absent(),
    this.isMythical = const Value.absent(),
    this.isParadox = const Value.absent(),
    this.isUltraBeast = const Value.absent(),
    this.spriteUrl = const Value.absent(),
    this.shinySpriteUrl = const Value.absent(),
    this.nationalDexNumber = const Value.absent(),
    this.generation = const Value.absent(),
    this.evolutionStage = const Value.absent(),
    this.eggGroups = const Value.absent(),
    this.formSource = const Value.absent(),
    this.dlcSource = const Value.absent(),
    this.isChampions = const Value.absent(),
    this.isLegendsZA = const Value.absent(),
  });
  PokemonTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String form,
    required String type1,
    this.type2 = const Value.absent(),
    required int baseHp,
    required int baseAtk,
    required int baseDef,
    required int baseSpAtk,
    required int baseSpDef,
    required int baseSpd,
    required bool isLegendary,
    required bool isMythical,
    required bool isParadox,
    required bool isUltraBeast,
    required String spriteUrl,
    required String shinySpriteUrl,
    this.nationalDexNumber = const Value.absent(),
    this.generation = const Value.absent(),
    this.evolutionStage = const Value.absent(),
    this.eggGroups = const Value.absent(),
    this.formSource = const Value.absent(),
    this.dlcSource = const Value.absent(),
    this.isChampions = const Value.absent(),
    this.isLegendsZA = const Value.absent(),
  }) : name = Value(name),
       form = Value(form),
       type1 = Value(type1),
       baseHp = Value(baseHp),
       baseAtk = Value(baseAtk),
       baseDef = Value(baseDef),
       baseSpAtk = Value(baseSpAtk),
       baseSpDef = Value(baseSpDef),
       baseSpd = Value(baseSpd),
       isLegendary = Value(isLegendary),
       isMythical = Value(isMythical),
       isParadox = Value(isParadox),
       isUltraBeast = Value(isUltraBeast),
       spriteUrl = Value(spriteUrl),
       shinySpriteUrl = Value(shinySpriteUrl);
  static Insertable<Pokemon> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? form,
    Expression<String>? type1,
    Expression<String>? type2,
    Expression<int>? baseHp,
    Expression<int>? baseAtk,
    Expression<int>? baseDef,
    Expression<int>? baseSpAtk,
    Expression<int>? baseSpDef,
    Expression<int>? baseSpd,
    Expression<bool>? isLegendary,
    Expression<bool>? isMythical,
    Expression<bool>? isParadox,
    Expression<bool>? isUltraBeast,
    Expression<String>? spriteUrl,
    Expression<String>? shinySpriteUrl,
    Expression<int>? nationalDexNumber,
    Expression<int>? generation,
    Expression<int>? evolutionStage,
    Expression<String>? eggGroups,
    Expression<String>? formSource,
    Expression<String>? dlcSource,
    Expression<bool>? isChampions,
    Expression<bool>? isLegendsZA,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (form != null) 'form': form,
      if (type1 != null) 'type1': type1,
      if (type2 != null) 'type2': type2,
      if (baseHp != null) 'base_hp': baseHp,
      if (baseAtk != null) 'base_atk': baseAtk,
      if (baseDef != null) 'base_def': baseDef,
      if (baseSpAtk != null) 'base_sp_atk': baseSpAtk,
      if (baseSpDef != null) 'base_sp_def': baseSpDef,
      if (baseSpd != null) 'base_spd': baseSpd,
      if (isLegendary != null) 'is_legendary': isLegendary,
      if (isMythical != null) 'is_mythical': isMythical,
      if (isParadox != null) 'is_paradox': isParadox,
      if (isUltraBeast != null) 'is_ultra_beast': isUltraBeast,
      if (spriteUrl != null) 'sprite_url': spriteUrl,
      if (shinySpriteUrl != null) 'shiny_sprite_url': shinySpriteUrl,
      if (nationalDexNumber != null) 'national_dex_number': nationalDexNumber,
      if (generation != null) 'generation': generation,
      if (evolutionStage != null) 'evolution_stage': evolutionStage,
      if (eggGroups != null) 'egg_groups': eggGroups,
      if (formSource != null) 'form_source': formSource,
      if (dlcSource != null) 'dlc_source': dlcSource,
      if (isChampions != null) 'is_champions': isChampions,
      if (isLegendsZA != null) 'is_legends_z_a': isLegendsZA,
    });
  }

  PokemonTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? form,
    Value<String>? type1,
    Value<String?>? type2,
    Value<int>? baseHp,
    Value<int>? baseAtk,
    Value<int>? baseDef,
    Value<int>? baseSpAtk,
    Value<int>? baseSpDef,
    Value<int>? baseSpd,
    Value<bool>? isLegendary,
    Value<bool>? isMythical,
    Value<bool>? isParadox,
    Value<bool>? isUltraBeast,
    Value<String>? spriteUrl,
    Value<String>? shinySpriteUrl,
    Value<int>? nationalDexNumber,
    Value<int>? generation,
    Value<int>? evolutionStage,
    Value<String?>? eggGroups,
    Value<String?>? formSource,
    Value<String?>? dlcSource,
    Value<bool>? isChampions,
    Value<bool>? isLegendsZA,
  }) {
    return PokemonTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      form: form ?? this.form,
      type1: type1 ?? this.type1,
      type2: type2 ?? this.type2,
      baseHp: baseHp ?? this.baseHp,
      baseAtk: baseAtk ?? this.baseAtk,
      baseDef: baseDef ?? this.baseDef,
      baseSpAtk: baseSpAtk ?? this.baseSpAtk,
      baseSpDef: baseSpDef ?? this.baseSpDef,
      baseSpd: baseSpd ?? this.baseSpd,
      isLegendary: isLegendary ?? this.isLegendary,
      isMythical: isMythical ?? this.isMythical,
      isParadox: isParadox ?? this.isParadox,
      isUltraBeast: isUltraBeast ?? this.isUltraBeast,
      spriteUrl: spriteUrl ?? this.spriteUrl,
      shinySpriteUrl: shinySpriteUrl ?? this.shinySpriteUrl,
      nationalDexNumber: nationalDexNumber ?? this.nationalDexNumber,
      generation: generation ?? this.generation,
      evolutionStage: evolutionStage ?? this.evolutionStage,
      eggGroups: eggGroups ?? this.eggGroups,
      formSource: formSource ?? this.formSource,
      dlcSource: dlcSource ?? this.dlcSource,
      isChampions: isChampions ?? this.isChampions,
      isLegendsZA: isLegendsZA ?? this.isLegendsZA,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (form.present) {
      map['form'] = Variable<String>(form.value);
    }
    if (type1.present) {
      map['type1'] = Variable<String>(type1.value);
    }
    if (type2.present) {
      map['type2'] = Variable<String>(type2.value);
    }
    if (baseHp.present) {
      map['base_hp'] = Variable<int>(baseHp.value);
    }
    if (baseAtk.present) {
      map['base_atk'] = Variable<int>(baseAtk.value);
    }
    if (baseDef.present) {
      map['base_def'] = Variable<int>(baseDef.value);
    }
    if (baseSpAtk.present) {
      map['base_sp_atk'] = Variable<int>(baseSpAtk.value);
    }
    if (baseSpDef.present) {
      map['base_sp_def'] = Variable<int>(baseSpDef.value);
    }
    if (baseSpd.present) {
      map['base_spd'] = Variable<int>(baseSpd.value);
    }
    if (isLegendary.present) {
      map['is_legendary'] = Variable<bool>(isLegendary.value);
    }
    if (isMythical.present) {
      map['is_mythical'] = Variable<bool>(isMythical.value);
    }
    if (isParadox.present) {
      map['is_paradox'] = Variable<bool>(isParadox.value);
    }
    if (isUltraBeast.present) {
      map['is_ultra_beast'] = Variable<bool>(isUltraBeast.value);
    }
    if (spriteUrl.present) {
      map['sprite_url'] = Variable<String>(spriteUrl.value);
    }
    if (shinySpriteUrl.present) {
      map['shiny_sprite_url'] = Variable<String>(shinySpriteUrl.value);
    }
    if (nationalDexNumber.present) {
      map['national_dex_number'] = Variable<int>(nationalDexNumber.value);
    }
    if (generation.present) {
      map['generation'] = Variable<int>(generation.value);
    }
    if (evolutionStage.present) {
      map['evolution_stage'] = Variable<int>(evolutionStage.value);
    }
    if (eggGroups.present) {
      map['egg_groups'] = Variable<String>(eggGroups.value);
    }
    if (formSource.present) {
      map['form_source'] = Variable<String>(formSource.value);
    }
    if (dlcSource.present) {
      map['dlc_source'] = Variable<String>(dlcSource.value);
    }
    if (isChampions.present) {
      map['is_champions'] = Variable<bool>(isChampions.value);
    }
    if (isLegendsZA.present) {
      map['is_legends_z_a'] = Variable<bool>(isLegendsZA.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('form: $form, ')
          ..write('type1: $type1, ')
          ..write('type2: $type2, ')
          ..write('baseHp: $baseHp, ')
          ..write('baseAtk: $baseAtk, ')
          ..write('baseDef: $baseDef, ')
          ..write('baseSpAtk: $baseSpAtk, ')
          ..write('baseSpDef: $baseSpDef, ')
          ..write('baseSpd: $baseSpd, ')
          ..write('isLegendary: $isLegendary, ')
          ..write('isMythical: $isMythical, ')
          ..write('isParadox: $isParadox, ')
          ..write('isUltraBeast: $isUltraBeast, ')
          ..write('spriteUrl: $spriteUrl, ')
          ..write('shinySpriteUrl: $shinySpriteUrl, ')
          ..write('nationalDexNumber: $nationalDexNumber, ')
          ..write('generation: $generation, ')
          ..write('evolutionStage: $evolutionStage, ')
          ..write('eggGroups: $eggGroups, ')
          ..write('formSource: $formSource, ')
          ..write('dlcSource: $dlcSource, ')
          ..write('isChampions: $isChampions, ')
          ..write('isLegendsZA: $isLegendsZA')
          ..write(')'))
        .toString();
  }
}

class $MoveTableTable extends MoveTable with TableInfo<$MoveTableTable, Move> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoveTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _powerMeta = const VerificationMeta('power');
  @override
  late final GeneratedColumn<int> power = GeneratedColumn<int>(
    'power',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<int> accuracy = GeneratedColumn<int>(
    'accuracy',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ppMeta = const VerificationMeta('pp');
  @override
  late final GeneratedColumn<int> pp = GeneratedColumn<int>(
    'pp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _damageClassMeta = const VerificationMeta(
    'damageClass',
  );
  @override
  late final GeneratedColumn<String> damageClass = GeneratedColumn<String>(
    'damage_class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(0),
  );
  static const VerificationMeta _isContactMeta = const VerificationMeta(
    'isContact',
  );
  @override
  late final GeneratedColumn<bool> isContact = GeneratedColumn<bool>(
    'is_contact',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_contact" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isHealingMeta = const VerificationMeta(
    'isHealing',
  );
  @override
  late final GeneratedColumn<bool> isHealing = GeneratedColumn<bool>(
    'is_healing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_healing" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isSoundMeta = const VerificationMeta(
    'isSound',
  );
  @override
  late final GeneratedColumn<bool> isSound = GeneratedColumn<bool>(
    'is_sound',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_sound" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isPunchingMeta = const VerificationMeta(
    'isPunching',
  );
  @override
  late final GeneratedColumn<bool> isPunching = GeneratedColumn<bool>(
    'is_punching',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_punching" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isBitingMeta = const VerificationMeta(
    'isBiting',
  );
  @override
  late final GeneratedColumn<bool> isBiting = GeneratedColumn<bool>(
    'is_biting',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_biting" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isPowderMeta = const VerificationMeta(
    'isPowder',
  );
  @override
  late final GeneratedColumn<bool> isPowder = GeneratedColumn<bool>(
    'is_powder',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_powder" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isPulseMeta = const VerificationMeta(
    'isPulse',
  );
  @override
  late final GeneratedColumn<bool> isPulse = GeneratedColumn<bool>(
    'is_pulse',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pulse" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isBallisticMeta = const VerificationMeta(
    'isBallistic',
  );
  @override
  late final GeneratedColumn<bool> isBallistic = GeneratedColumn<bool>(
    'is_ballistic',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_ballistic" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isSlicingMeta = const VerificationMeta(
    'isSlicing',
  );
  @override
  late final GeneratedColumn<bool> isSlicing = GeneratedColumn<bool>(
    'is_slicing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_slicing" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isWindMeta = const VerificationMeta('isWind');
  @override
  late final GeneratedColumn<bool> isWind = GeneratedColumn<bool>(
    'is_wind',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_wind" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isDanceMeta = const VerificationMeta(
    'isDance',
  );
  @override
  late final GeneratedColumn<bool> isDance = GeneratedColumn<bool>(
    'is_dance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dance" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isBiteMeta = const VerificationMeta('isBite');
  @override
  late final GeneratedColumn<bool> isBite = GeneratedColumn<bool>(
    'is_bite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bite" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isMultiHitMeta = const VerificationMeta(
    'isMultiHit',
  );
  @override
  late final GeneratedColumn<bool> isMultiHit = GeneratedColumn<bool>(
    'is_multi_hit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_multi_hit" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isProtectiveMeta = const VerificationMeta(
    'isProtective',
  );
  @override
  late final GeneratedColumn<bool> isProtective = GeneratedColumn<bool>(
    'is_protective',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_protective" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isSwitchingMeta = const VerificationMeta(
    'isSwitching',
  );
  @override
  late final GeneratedColumn<bool> isSwitching = GeneratedColumn<bool>(
    'is_switching',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_switching" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isRechargeMeta = const VerificationMeta(
    'isRecharge',
  );
  @override
  late final GeneratedColumn<bool> isRecharge = GeneratedColumn<bool>(
    'is_recharge',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recharge" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isRecoilMeta = const VerificationMeta(
    'isRecoil',
  );
  @override
  late final GeneratedColumn<bool> isRecoil = GeneratedColumn<bool>(
    'is_recoil',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recoil" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isDrainingMeta = const VerificationMeta(
    'isDraining',
  );
  @override
  late final GeneratedColumn<bool> isDraining = GeneratedColumn<bool>(
    'is_draining',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_draining" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isStatusMoveMeta = const VerificationMeta(
    'isStatusMove',
  );
  @override
  late final GeneratedColumn<bool> isStatusMove = GeneratedColumn<bool>(
    'is_status_move',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_status_move" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isDamagingMoveMeta = const VerificationMeta(
    'isDamagingMove',
  );
  @override
  late final GeneratedColumn<bool> isDamagingMove = GeneratedColumn<bool>(
    'is_damaging_move',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_damaging_move" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isSignatureMoveMeta = const VerificationMeta(
    'isSignatureMove',
  );
  @override
  late final GeneratedColumn<bool> isSignatureMove = GeneratedColumn<bool>(
    'is_signature_move',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_signature_move" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isDLCMoveMeta = const VerificationMeta(
    'isDLCMove',
  );
  @override
  late final GeneratedColumn<bool> isDLCMove = GeneratedColumn<bool>(
    'is_d_l_c_move',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_d_l_c_move" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isChampionsMoveMeta = const VerificationMeta(
    'isChampionsMove',
  );
  @override
  late final GeneratedColumn<bool> isChampionsMove = GeneratedColumn<bool>(
    'is_champions_move',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_champions_move" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isLegendsZAMoveMeta = const VerificationMeta(
    'isLegendsZAMove',
  );
  @override
  late final GeneratedColumn<bool> isLegendsZAMove = GeneratedColumn<bool>(
    'is_legends_z_a_move',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_legends_z_a_move" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _generationMeta = const VerificationMeta(
    'generation',
  );
  @override
  late final GeneratedColumn<int> generation = GeneratedColumn<int>(
    'generation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(1),
  );
  static const VerificationMeta _introducedInMeta = const VerificationMeta(
    'introducedIn',
  );
  @override
  late final GeneratedColumn<String> introducedIn = GeneratedColumn<String>(
    'introduced_in',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    power,
    accuracy,
    pp,
    damageClass,
    description,
    priority,
    isContact,
    isHealing,
    isSound,
    isPunching,
    isBiting,
    isPowder,
    isPulse,
    isBallistic,
    isSlicing,
    isWind,
    isDance,
    isBite,
    isMultiHit,
    isProtective,
    isSwitching,
    isRecharge,
    isRecoil,
    isDraining,
    isStatusMove,
    isDamagingMove,
    isSignatureMove,
    isDLCMove,
    isChampionsMove,
    isLegendsZAMove,
    generation,
    introducedIn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'move_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<Move> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('power')) {
      context.handle(
        _powerMeta,
        power.isAcceptableOrUnknown(data['power']!, _powerMeta),
      );
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    if (data.containsKey('pp')) {
      context.handle(_ppMeta, pp.isAcceptableOrUnknown(data['pp']!, _ppMeta));
    } else if (isInserting) {
      context.missing(_ppMeta);
    }
    if (data.containsKey('damage_class')) {
      context.handle(
        _damageClassMeta,
        damageClass.isAcceptableOrUnknown(
          data['damage_class']!,
          _damageClassMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_damageClassMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('is_contact')) {
      context.handle(
        _isContactMeta,
        isContact.isAcceptableOrUnknown(data['is_contact']!, _isContactMeta),
      );
    }
    if (data.containsKey('is_healing')) {
      context.handle(
        _isHealingMeta,
        isHealing.isAcceptableOrUnknown(data['is_healing']!, _isHealingMeta),
      );
    }
    if (data.containsKey('is_sound')) {
      context.handle(
        _isSoundMeta,
        isSound.isAcceptableOrUnknown(data['is_sound']!, _isSoundMeta),
      );
    }
    if (data.containsKey('is_punching')) {
      context.handle(
        _isPunchingMeta,
        isPunching.isAcceptableOrUnknown(data['is_punching']!, _isPunchingMeta),
      );
    }
    if (data.containsKey('is_biting')) {
      context.handle(
        _isBitingMeta,
        isBiting.isAcceptableOrUnknown(data['is_biting']!, _isBitingMeta),
      );
    }
    if (data.containsKey('is_powder')) {
      context.handle(
        _isPowderMeta,
        isPowder.isAcceptableOrUnknown(data['is_powder']!, _isPowderMeta),
      );
    }
    if (data.containsKey('is_pulse')) {
      context.handle(
        _isPulseMeta,
        isPulse.isAcceptableOrUnknown(data['is_pulse']!, _isPulseMeta),
      );
    }
    if (data.containsKey('is_ballistic')) {
      context.handle(
        _isBallisticMeta,
        isBallistic.isAcceptableOrUnknown(
          data['is_ballistic']!,
          _isBallisticMeta,
        ),
      );
    }
    if (data.containsKey('is_slicing')) {
      context.handle(
        _isSlicingMeta,
        isSlicing.isAcceptableOrUnknown(data['is_slicing']!, _isSlicingMeta),
      );
    }
    if (data.containsKey('is_wind')) {
      context.handle(
        _isWindMeta,
        isWind.isAcceptableOrUnknown(data['is_wind']!, _isWindMeta),
      );
    }
    if (data.containsKey('is_dance')) {
      context.handle(
        _isDanceMeta,
        isDance.isAcceptableOrUnknown(data['is_dance']!, _isDanceMeta),
      );
    }
    if (data.containsKey('is_bite')) {
      context.handle(
        _isBiteMeta,
        isBite.isAcceptableOrUnknown(data['is_bite']!, _isBiteMeta),
      );
    }
    if (data.containsKey('is_multi_hit')) {
      context.handle(
        _isMultiHitMeta,
        isMultiHit.isAcceptableOrUnknown(
          data['is_multi_hit']!,
          _isMultiHitMeta,
        ),
      );
    }
    if (data.containsKey('is_protective')) {
      context.handle(
        _isProtectiveMeta,
        isProtective.isAcceptableOrUnknown(
          data['is_protective']!,
          _isProtectiveMeta,
        ),
      );
    }
    if (data.containsKey('is_switching')) {
      context.handle(
        _isSwitchingMeta,
        isSwitching.isAcceptableOrUnknown(
          data['is_switching']!,
          _isSwitchingMeta,
        ),
      );
    }
    if (data.containsKey('is_recharge')) {
      context.handle(
        _isRechargeMeta,
        isRecharge.isAcceptableOrUnknown(data['is_recharge']!, _isRechargeMeta),
      );
    }
    if (data.containsKey('is_recoil')) {
      context.handle(
        _isRecoilMeta,
        isRecoil.isAcceptableOrUnknown(data['is_recoil']!, _isRecoilMeta),
      );
    }
    if (data.containsKey('is_draining')) {
      context.handle(
        _isDrainingMeta,
        isDraining.isAcceptableOrUnknown(data['is_draining']!, _isDrainingMeta),
      );
    }
    if (data.containsKey('is_status_move')) {
      context.handle(
        _isStatusMoveMeta,
        isStatusMove.isAcceptableOrUnknown(
          data['is_status_move']!,
          _isStatusMoveMeta,
        ),
      );
    }
    if (data.containsKey('is_damaging_move')) {
      context.handle(
        _isDamagingMoveMeta,
        isDamagingMove.isAcceptableOrUnknown(
          data['is_damaging_move']!,
          _isDamagingMoveMeta,
        ),
      );
    }
    if (data.containsKey('is_signature_move')) {
      context.handle(
        _isSignatureMoveMeta,
        isSignatureMove.isAcceptableOrUnknown(
          data['is_signature_move']!,
          _isSignatureMoveMeta,
        ),
      );
    }
    if (data.containsKey('is_d_l_c_move')) {
      context.handle(
        _isDLCMoveMeta,
        isDLCMove.isAcceptableOrUnknown(data['is_d_l_c_move']!, _isDLCMoveMeta),
      );
    }
    if (data.containsKey('is_champions_move')) {
      context.handle(
        _isChampionsMoveMeta,
        isChampionsMove.isAcceptableOrUnknown(
          data['is_champions_move']!,
          _isChampionsMoveMeta,
        ),
      );
    }
    if (data.containsKey('is_legends_z_a_move')) {
      context.handle(
        _isLegendsZAMoveMeta,
        isLegendsZAMove.isAcceptableOrUnknown(
          data['is_legends_z_a_move']!,
          _isLegendsZAMoveMeta,
        ),
      );
    }
    if (data.containsKey('generation')) {
      context.handle(
        _generationMeta,
        generation.isAcceptableOrUnknown(data['generation']!, _generationMeta),
      );
    }
    if (data.containsKey('introduced_in')) {
      context.handle(
        _introducedInMeta,
        introducedIn.isAcceptableOrUnknown(
          data['introduced_in']!,
          _introducedInMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Move map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Move(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      power: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}power'],
      ),
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accuracy'],
      ),
      pp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pp'],
      )!,
      damageClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}damage_class'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      isContact: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_contact'],
      )!,
      isHealing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_healing'],
      )!,
      isSound: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_sound'],
      )!,
      isPunching: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_punching'],
      )!,
      isBiting: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_biting'],
      )!,
      isPowder: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_powder'],
      )!,
      isPulse: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pulse'],
      )!,
      isBallistic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ballistic'],
      )!,
      isSlicing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_slicing'],
      )!,
      isWind: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_wind'],
      )!,
      isDance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dance'],
      )!,
      isBite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bite'],
      )!,
      isMultiHit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_multi_hit'],
      )!,
      isProtective: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_protective'],
      )!,
      isSwitching: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_switching'],
      )!,
      isRecharge: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recharge'],
      )!,
      isRecoil: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recoil'],
      )!,
      isDraining: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_draining'],
      )!,
      isStatusMove: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_status_move'],
      )!,
      isDamagingMove: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_damaging_move'],
      )!,
      isSignatureMove: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_signature_move'],
      )!,
      isDLCMove: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_d_l_c_move'],
      )!,
      isChampionsMove: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_champions_move'],
      )!,
      isLegendsZAMove: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_legends_z_a_move'],
      )!,
      generation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generation'],
      )!,
      introducedIn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}introduced_in'],
      ),
    );
  }

  @override
  $MoveTableTable createAlias(String alias) {
    return $MoveTableTable(attachedDatabase, alias);
  }
}

class Move extends DataClass implements Insertable<Move> {
  final int id;
  final String name;
  final String type;
  final int? power;
  final int? accuracy;
  final int pp;
  final String damageClass;
  final String? description;
  final int priority;
  final bool isContact;
  final bool isHealing;
  final bool isSound;
  final bool isPunching;
  final bool isBiting;
  final bool isPowder;
  final bool isPulse;
  final bool isBallistic;
  final bool isSlicing;
  final bool isWind;
  final bool isDance;
  final bool isBite;
  final bool isMultiHit;
  final bool isProtective;
  final bool isSwitching;
  final bool isRecharge;
  final bool isRecoil;
  final bool isDraining;
  final bool isStatusMove;
  final bool isDamagingMove;
  final bool isSignatureMove;
  final bool isDLCMove;
  final bool isChampionsMove;
  final bool isLegendsZAMove;
  final int generation;
  final String? introducedIn;
  const Move({
    required this.id,
    required this.name,
    required this.type,
    this.power,
    this.accuracy,
    required this.pp,
    required this.damageClass,
    this.description,
    required this.priority,
    required this.isContact,
    required this.isHealing,
    required this.isSound,
    required this.isPunching,
    required this.isBiting,
    required this.isPowder,
    required this.isPulse,
    required this.isBallistic,
    required this.isSlicing,
    required this.isWind,
    required this.isDance,
    required this.isBite,
    required this.isMultiHit,
    required this.isProtective,
    required this.isSwitching,
    required this.isRecharge,
    required this.isRecoil,
    required this.isDraining,
    required this.isStatusMove,
    required this.isDamagingMove,
    required this.isSignatureMove,
    required this.isDLCMove,
    required this.isChampionsMove,
    required this.isLegendsZAMove,
    required this.generation,
    this.introducedIn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || power != null) {
      map['power'] = Variable<int>(power);
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<int>(accuracy);
    }
    map['pp'] = Variable<int>(pp);
    map['damage_class'] = Variable<String>(damageClass);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['priority'] = Variable<int>(priority);
    map['is_contact'] = Variable<bool>(isContact);
    map['is_healing'] = Variable<bool>(isHealing);
    map['is_sound'] = Variable<bool>(isSound);
    map['is_punching'] = Variable<bool>(isPunching);
    map['is_biting'] = Variable<bool>(isBiting);
    map['is_powder'] = Variable<bool>(isPowder);
    map['is_pulse'] = Variable<bool>(isPulse);
    map['is_ballistic'] = Variable<bool>(isBallistic);
    map['is_slicing'] = Variable<bool>(isSlicing);
    map['is_wind'] = Variable<bool>(isWind);
    map['is_dance'] = Variable<bool>(isDance);
    map['is_bite'] = Variable<bool>(isBite);
    map['is_multi_hit'] = Variable<bool>(isMultiHit);
    map['is_protective'] = Variable<bool>(isProtective);
    map['is_switching'] = Variable<bool>(isSwitching);
    map['is_recharge'] = Variable<bool>(isRecharge);
    map['is_recoil'] = Variable<bool>(isRecoil);
    map['is_draining'] = Variable<bool>(isDraining);
    map['is_status_move'] = Variable<bool>(isStatusMove);
    map['is_damaging_move'] = Variable<bool>(isDamagingMove);
    map['is_signature_move'] = Variable<bool>(isSignatureMove);
    map['is_d_l_c_move'] = Variable<bool>(isDLCMove);
    map['is_champions_move'] = Variable<bool>(isChampionsMove);
    map['is_legends_z_a_move'] = Variable<bool>(isLegendsZAMove);
    map['generation'] = Variable<int>(generation);
    if (!nullToAbsent || introducedIn != null) {
      map['introduced_in'] = Variable<String>(introducedIn);
    }
    return map;
  }

  MoveTableCompanion toCompanion(bool nullToAbsent) {
    return MoveTableCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      power: power == null && nullToAbsent
          ? const Value.absent()
          : Value(power),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      pp: Value(pp),
      damageClass: Value(damageClass),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      priority: Value(priority),
      isContact: Value(isContact),
      isHealing: Value(isHealing),
      isSound: Value(isSound),
      isPunching: Value(isPunching),
      isBiting: Value(isBiting),
      isPowder: Value(isPowder),
      isPulse: Value(isPulse),
      isBallistic: Value(isBallistic),
      isSlicing: Value(isSlicing),
      isWind: Value(isWind),
      isDance: Value(isDance),
      isBite: Value(isBite),
      isMultiHit: Value(isMultiHit),
      isProtective: Value(isProtective),
      isSwitching: Value(isSwitching),
      isRecharge: Value(isRecharge),
      isRecoil: Value(isRecoil),
      isDraining: Value(isDraining),
      isStatusMove: Value(isStatusMove),
      isDamagingMove: Value(isDamagingMove),
      isSignatureMove: Value(isSignatureMove),
      isDLCMove: Value(isDLCMove),
      isChampionsMove: Value(isChampionsMove),
      isLegendsZAMove: Value(isLegendsZAMove),
      generation: Value(generation),
      introducedIn: introducedIn == null && nullToAbsent
          ? const Value.absent()
          : Value(introducedIn),
    );
  }

  factory Move.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Move(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      power: serializer.fromJson<int?>(json['power']),
      accuracy: serializer.fromJson<int?>(json['accuracy']),
      pp: serializer.fromJson<int>(json['pp']),
      damageClass: serializer.fromJson<String>(json['damageClass']),
      description: serializer.fromJson<String?>(json['description']),
      priority: serializer.fromJson<int>(json['priority']),
      isContact: serializer.fromJson<bool>(json['isContact']),
      isHealing: serializer.fromJson<bool>(json['isHealing']),
      isSound: serializer.fromJson<bool>(json['isSound']),
      isPunching: serializer.fromJson<bool>(json['isPunching']),
      isBiting: serializer.fromJson<bool>(json['isBiting']),
      isPowder: serializer.fromJson<bool>(json['isPowder']),
      isPulse: serializer.fromJson<bool>(json['isPulse']),
      isBallistic: serializer.fromJson<bool>(json['isBallistic']),
      isSlicing: serializer.fromJson<bool>(json['isSlicing']),
      isWind: serializer.fromJson<bool>(json['isWind']),
      isDance: serializer.fromJson<bool>(json['isDance']),
      isBite: serializer.fromJson<bool>(json['isBite']),
      isMultiHit: serializer.fromJson<bool>(json['isMultiHit']),
      isProtective: serializer.fromJson<bool>(json['isProtective']),
      isSwitching: serializer.fromJson<bool>(json['isSwitching']),
      isRecharge: serializer.fromJson<bool>(json['isRecharge']),
      isRecoil: serializer.fromJson<bool>(json['isRecoil']),
      isDraining: serializer.fromJson<bool>(json['isDraining']),
      isStatusMove: serializer.fromJson<bool>(json['isStatusMove']),
      isDamagingMove: serializer.fromJson<bool>(json['isDamagingMove']),
      isSignatureMove: serializer.fromJson<bool>(json['isSignatureMove']),
      isDLCMove: serializer.fromJson<bool>(json['isDLCMove']),
      isChampionsMove: serializer.fromJson<bool>(json['isChampionsMove']),
      isLegendsZAMove: serializer.fromJson<bool>(json['isLegendsZAMove']),
      generation: serializer.fromJson<int>(json['generation']),
      introducedIn: serializer.fromJson<String?>(json['introducedIn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'power': serializer.toJson<int?>(power),
      'accuracy': serializer.toJson<int?>(accuracy),
      'pp': serializer.toJson<int>(pp),
      'damageClass': serializer.toJson<String>(damageClass),
      'description': serializer.toJson<String?>(description),
      'priority': serializer.toJson<int>(priority),
      'isContact': serializer.toJson<bool>(isContact),
      'isHealing': serializer.toJson<bool>(isHealing),
      'isSound': serializer.toJson<bool>(isSound),
      'isPunching': serializer.toJson<bool>(isPunching),
      'isBiting': serializer.toJson<bool>(isBiting),
      'isPowder': serializer.toJson<bool>(isPowder),
      'isPulse': serializer.toJson<bool>(isPulse),
      'isBallistic': serializer.toJson<bool>(isBallistic),
      'isSlicing': serializer.toJson<bool>(isSlicing),
      'isWind': serializer.toJson<bool>(isWind),
      'isDance': serializer.toJson<bool>(isDance),
      'isBite': serializer.toJson<bool>(isBite),
      'isMultiHit': serializer.toJson<bool>(isMultiHit),
      'isProtective': serializer.toJson<bool>(isProtective),
      'isSwitching': serializer.toJson<bool>(isSwitching),
      'isRecharge': serializer.toJson<bool>(isRecharge),
      'isRecoil': serializer.toJson<bool>(isRecoil),
      'isDraining': serializer.toJson<bool>(isDraining),
      'isStatusMove': serializer.toJson<bool>(isStatusMove),
      'isDamagingMove': serializer.toJson<bool>(isDamagingMove),
      'isSignatureMove': serializer.toJson<bool>(isSignatureMove),
      'isDLCMove': serializer.toJson<bool>(isDLCMove),
      'isChampionsMove': serializer.toJson<bool>(isChampionsMove),
      'isLegendsZAMove': serializer.toJson<bool>(isLegendsZAMove),
      'generation': serializer.toJson<int>(generation),
      'introducedIn': serializer.toJson<String?>(introducedIn),
    };
  }

  Move copyWith({
    int? id,
    String? name,
    String? type,
    Value<int?> power = const Value.absent(),
    Value<int?> accuracy = const Value.absent(),
    int? pp,
    String? damageClass,
    Value<String?> description = const Value.absent(),
    int? priority,
    bool? isContact,
    bool? isHealing,
    bool? isSound,
    bool? isPunching,
    bool? isBiting,
    bool? isPowder,
    bool? isPulse,
    bool? isBallistic,
    bool? isSlicing,
    bool? isWind,
    bool? isDance,
    bool? isBite,
    bool? isMultiHit,
    bool? isProtective,
    bool? isSwitching,
    bool? isRecharge,
    bool? isRecoil,
    bool? isDraining,
    bool? isStatusMove,
    bool? isDamagingMove,
    bool? isSignatureMove,
    bool? isDLCMove,
    bool? isChampionsMove,
    bool? isLegendsZAMove,
    int? generation,
    Value<String?> introducedIn = const Value.absent(),
  }) => Move(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    power: power.present ? power.value : this.power,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
    pp: pp ?? this.pp,
    damageClass: damageClass ?? this.damageClass,
    description: description.present ? description.value : this.description,
    priority: priority ?? this.priority,
    isContact: isContact ?? this.isContact,
    isHealing: isHealing ?? this.isHealing,
    isSound: isSound ?? this.isSound,
    isPunching: isPunching ?? this.isPunching,
    isBiting: isBiting ?? this.isBiting,
    isPowder: isPowder ?? this.isPowder,
    isPulse: isPulse ?? this.isPulse,
    isBallistic: isBallistic ?? this.isBallistic,
    isSlicing: isSlicing ?? this.isSlicing,
    isWind: isWind ?? this.isWind,
    isDance: isDance ?? this.isDance,
    isBite: isBite ?? this.isBite,
    isMultiHit: isMultiHit ?? this.isMultiHit,
    isProtective: isProtective ?? this.isProtective,
    isSwitching: isSwitching ?? this.isSwitching,
    isRecharge: isRecharge ?? this.isRecharge,
    isRecoil: isRecoil ?? this.isRecoil,
    isDraining: isDraining ?? this.isDraining,
    isStatusMove: isStatusMove ?? this.isStatusMove,
    isDamagingMove: isDamagingMove ?? this.isDamagingMove,
    isSignatureMove: isSignatureMove ?? this.isSignatureMove,
    isDLCMove: isDLCMove ?? this.isDLCMove,
    isChampionsMove: isChampionsMove ?? this.isChampionsMove,
    isLegendsZAMove: isLegendsZAMove ?? this.isLegendsZAMove,
    generation: generation ?? this.generation,
    introducedIn: introducedIn.present ? introducedIn.value : this.introducedIn,
  );
  Move copyWithCompanion(MoveTableCompanion data) {
    return Move(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      power: data.power.present ? data.power.value : this.power,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      pp: data.pp.present ? data.pp.value : this.pp,
      damageClass: data.damageClass.present
          ? data.damageClass.value
          : this.damageClass,
      description: data.description.present
          ? data.description.value
          : this.description,
      priority: data.priority.present ? data.priority.value : this.priority,
      isContact: data.isContact.present ? data.isContact.value : this.isContact,
      isHealing: data.isHealing.present ? data.isHealing.value : this.isHealing,
      isSound: data.isSound.present ? data.isSound.value : this.isSound,
      isPunching: data.isPunching.present
          ? data.isPunching.value
          : this.isPunching,
      isBiting: data.isBiting.present ? data.isBiting.value : this.isBiting,
      isPowder: data.isPowder.present ? data.isPowder.value : this.isPowder,
      isPulse: data.isPulse.present ? data.isPulse.value : this.isPulse,
      isBallistic: data.isBallistic.present
          ? data.isBallistic.value
          : this.isBallistic,
      isSlicing: data.isSlicing.present ? data.isSlicing.value : this.isSlicing,
      isWind: data.isWind.present ? data.isWind.value : this.isWind,
      isDance: data.isDance.present ? data.isDance.value : this.isDance,
      isBite: data.isBite.present ? data.isBite.value : this.isBite,
      isMultiHit: data.isMultiHit.present
          ? data.isMultiHit.value
          : this.isMultiHit,
      isProtective: data.isProtective.present
          ? data.isProtective.value
          : this.isProtective,
      isSwitching: data.isSwitching.present
          ? data.isSwitching.value
          : this.isSwitching,
      isRecharge: data.isRecharge.present
          ? data.isRecharge.value
          : this.isRecharge,
      isRecoil: data.isRecoil.present ? data.isRecoil.value : this.isRecoil,
      isDraining: data.isDraining.present
          ? data.isDraining.value
          : this.isDraining,
      isStatusMove: data.isStatusMove.present
          ? data.isStatusMove.value
          : this.isStatusMove,
      isDamagingMove: data.isDamagingMove.present
          ? data.isDamagingMove.value
          : this.isDamagingMove,
      isSignatureMove: data.isSignatureMove.present
          ? data.isSignatureMove.value
          : this.isSignatureMove,
      isDLCMove: data.isDLCMove.present ? data.isDLCMove.value : this.isDLCMove,
      isChampionsMove: data.isChampionsMove.present
          ? data.isChampionsMove.value
          : this.isChampionsMove,
      isLegendsZAMove: data.isLegendsZAMove.present
          ? data.isLegendsZAMove.value
          : this.isLegendsZAMove,
      generation: data.generation.present
          ? data.generation.value
          : this.generation,
      introducedIn: data.introducedIn.present
          ? data.introducedIn.value
          : this.introducedIn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Move(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('power: $power, ')
          ..write('accuracy: $accuracy, ')
          ..write('pp: $pp, ')
          ..write('damageClass: $damageClass, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('isContact: $isContact, ')
          ..write('isHealing: $isHealing, ')
          ..write('isSound: $isSound, ')
          ..write('isPunching: $isPunching, ')
          ..write('isBiting: $isBiting, ')
          ..write('isPowder: $isPowder, ')
          ..write('isPulse: $isPulse, ')
          ..write('isBallistic: $isBallistic, ')
          ..write('isSlicing: $isSlicing, ')
          ..write('isWind: $isWind, ')
          ..write('isDance: $isDance, ')
          ..write('isBite: $isBite, ')
          ..write('isMultiHit: $isMultiHit, ')
          ..write('isProtective: $isProtective, ')
          ..write('isSwitching: $isSwitching, ')
          ..write('isRecharge: $isRecharge, ')
          ..write('isRecoil: $isRecoil, ')
          ..write('isDraining: $isDraining, ')
          ..write('isStatusMove: $isStatusMove, ')
          ..write('isDamagingMove: $isDamagingMove, ')
          ..write('isSignatureMove: $isSignatureMove, ')
          ..write('isDLCMove: $isDLCMove, ')
          ..write('isChampionsMove: $isChampionsMove, ')
          ..write('isLegendsZAMove: $isLegendsZAMove, ')
          ..write('generation: $generation, ')
          ..write('introducedIn: $introducedIn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    type,
    power,
    accuracy,
    pp,
    damageClass,
    description,
    priority,
    isContact,
    isHealing,
    isSound,
    isPunching,
    isBiting,
    isPowder,
    isPulse,
    isBallistic,
    isSlicing,
    isWind,
    isDance,
    isBite,
    isMultiHit,
    isProtective,
    isSwitching,
    isRecharge,
    isRecoil,
    isDraining,
    isStatusMove,
    isDamagingMove,
    isSignatureMove,
    isDLCMove,
    isChampionsMove,
    isLegendsZAMove,
    generation,
    introducedIn,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Move &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.power == this.power &&
          other.accuracy == this.accuracy &&
          other.pp == this.pp &&
          other.damageClass == this.damageClass &&
          other.description == this.description &&
          other.priority == this.priority &&
          other.isContact == this.isContact &&
          other.isHealing == this.isHealing &&
          other.isSound == this.isSound &&
          other.isPunching == this.isPunching &&
          other.isBiting == this.isBiting &&
          other.isPowder == this.isPowder &&
          other.isPulse == this.isPulse &&
          other.isBallistic == this.isBallistic &&
          other.isSlicing == this.isSlicing &&
          other.isWind == this.isWind &&
          other.isDance == this.isDance &&
          other.isBite == this.isBite &&
          other.isMultiHit == this.isMultiHit &&
          other.isProtective == this.isProtective &&
          other.isSwitching == this.isSwitching &&
          other.isRecharge == this.isRecharge &&
          other.isRecoil == this.isRecoil &&
          other.isDraining == this.isDraining &&
          other.isStatusMove == this.isStatusMove &&
          other.isDamagingMove == this.isDamagingMove &&
          other.isSignatureMove == this.isSignatureMove &&
          other.isDLCMove == this.isDLCMove &&
          other.isChampionsMove == this.isChampionsMove &&
          other.isLegendsZAMove == this.isLegendsZAMove &&
          other.generation == this.generation &&
          other.introducedIn == this.introducedIn);
}

class MoveTableCompanion extends UpdateCompanion<Move> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<int?> power;
  final Value<int?> accuracy;
  final Value<int> pp;
  final Value<String> damageClass;
  final Value<String?> description;
  final Value<int> priority;
  final Value<bool> isContact;
  final Value<bool> isHealing;
  final Value<bool> isSound;
  final Value<bool> isPunching;
  final Value<bool> isBiting;
  final Value<bool> isPowder;
  final Value<bool> isPulse;
  final Value<bool> isBallistic;
  final Value<bool> isSlicing;
  final Value<bool> isWind;
  final Value<bool> isDance;
  final Value<bool> isBite;
  final Value<bool> isMultiHit;
  final Value<bool> isProtective;
  final Value<bool> isSwitching;
  final Value<bool> isRecharge;
  final Value<bool> isRecoil;
  final Value<bool> isDraining;
  final Value<bool> isStatusMove;
  final Value<bool> isDamagingMove;
  final Value<bool> isSignatureMove;
  final Value<bool> isDLCMove;
  final Value<bool> isChampionsMove;
  final Value<bool> isLegendsZAMove;
  final Value<int> generation;
  final Value<String?> introducedIn;
  const MoveTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.power = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.pp = const Value.absent(),
    this.damageClass = const Value.absent(),
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.isContact = const Value.absent(),
    this.isHealing = const Value.absent(),
    this.isSound = const Value.absent(),
    this.isPunching = const Value.absent(),
    this.isBiting = const Value.absent(),
    this.isPowder = const Value.absent(),
    this.isPulse = const Value.absent(),
    this.isBallistic = const Value.absent(),
    this.isSlicing = const Value.absent(),
    this.isWind = const Value.absent(),
    this.isDance = const Value.absent(),
    this.isBite = const Value.absent(),
    this.isMultiHit = const Value.absent(),
    this.isProtective = const Value.absent(),
    this.isSwitching = const Value.absent(),
    this.isRecharge = const Value.absent(),
    this.isRecoil = const Value.absent(),
    this.isDraining = const Value.absent(),
    this.isStatusMove = const Value.absent(),
    this.isDamagingMove = const Value.absent(),
    this.isSignatureMove = const Value.absent(),
    this.isDLCMove = const Value.absent(),
    this.isChampionsMove = const Value.absent(),
    this.isLegendsZAMove = const Value.absent(),
    this.generation = const Value.absent(),
    this.introducedIn = const Value.absent(),
  });
  MoveTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    this.power = const Value.absent(),
    this.accuracy = const Value.absent(),
    required int pp,
    required String damageClass,
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.isContact = const Value.absent(),
    this.isHealing = const Value.absent(),
    this.isSound = const Value.absent(),
    this.isPunching = const Value.absent(),
    this.isBiting = const Value.absent(),
    this.isPowder = const Value.absent(),
    this.isPulse = const Value.absent(),
    this.isBallistic = const Value.absent(),
    this.isSlicing = const Value.absent(),
    this.isWind = const Value.absent(),
    this.isDance = const Value.absent(),
    this.isBite = const Value.absent(),
    this.isMultiHit = const Value.absent(),
    this.isProtective = const Value.absent(),
    this.isSwitching = const Value.absent(),
    this.isRecharge = const Value.absent(),
    this.isRecoil = const Value.absent(),
    this.isDraining = const Value.absent(),
    this.isStatusMove = const Value.absent(),
    this.isDamagingMove = const Value.absent(),
    this.isSignatureMove = const Value.absent(),
    this.isDLCMove = const Value.absent(),
    this.isChampionsMove = const Value.absent(),
    this.isLegendsZAMove = const Value.absent(),
    this.generation = const Value.absent(),
    this.introducedIn = const Value.absent(),
  }) : name = Value(name),
       type = Value(type),
       pp = Value(pp),
       damageClass = Value(damageClass);
  static Insertable<Move> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? power,
    Expression<int>? accuracy,
    Expression<int>? pp,
    Expression<String>? damageClass,
    Expression<String>? description,
    Expression<int>? priority,
    Expression<bool>? isContact,
    Expression<bool>? isHealing,
    Expression<bool>? isSound,
    Expression<bool>? isPunching,
    Expression<bool>? isBiting,
    Expression<bool>? isPowder,
    Expression<bool>? isPulse,
    Expression<bool>? isBallistic,
    Expression<bool>? isSlicing,
    Expression<bool>? isWind,
    Expression<bool>? isDance,
    Expression<bool>? isBite,
    Expression<bool>? isMultiHit,
    Expression<bool>? isProtective,
    Expression<bool>? isSwitching,
    Expression<bool>? isRecharge,
    Expression<bool>? isRecoil,
    Expression<bool>? isDraining,
    Expression<bool>? isStatusMove,
    Expression<bool>? isDamagingMove,
    Expression<bool>? isSignatureMove,
    Expression<bool>? isDLCMove,
    Expression<bool>? isChampionsMove,
    Expression<bool>? isLegendsZAMove,
    Expression<int>? generation,
    Expression<String>? introducedIn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (power != null) 'power': power,
      if (accuracy != null) 'accuracy': accuracy,
      if (pp != null) 'pp': pp,
      if (damageClass != null) 'damage_class': damageClass,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (isContact != null) 'is_contact': isContact,
      if (isHealing != null) 'is_healing': isHealing,
      if (isSound != null) 'is_sound': isSound,
      if (isPunching != null) 'is_punching': isPunching,
      if (isBiting != null) 'is_biting': isBiting,
      if (isPowder != null) 'is_powder': isPowder,
      if (isPulse != null) 'is_pulse': isPulse,
      if (isBallistic != null) 'is_ballistic': isBallistic,
      if (isSlicing != null) 'is_slicing': isSlicing,
      if (isWind != null) 'is_wind': isWind,
      if (isDance != null) 'is_dance': isDance,
      if (isBite != null) 'is_bite': isBite,
      if (isMultiHit != null) 'is_multi_hit': isMultiHit,
      if (isProtective != null) 'is_protective': isProtective,
      if (isSwitching != null) 'is_switching': isSwitching,
      if (isRecharge != null) 'is_recharge': isRecharge,
      if (isRecoil != null) 'is_recoil': isRecoil,
      if (isDraining != null) 'is_draining': isDraining,
      if (isStatusMove != null) 'is_status_move': isStatusMove,
      if (isDamagingMove != null) 'is_damaging_move': isDamagingMove,
      if (isSignatureMove != null) 'is_signature_move': isSignatureMove,
      if (isDLCMove != null) 'is_d_l_c_move': isDLCMove,
      if (isChampionsMove != null) 'is_champions_move': isChampionsMove,
      if (isLegendsZAMove != null) 'is_legends_z_a_move': isLegendsZAMove,
      if (generation != null) 'generation': generation,
      if (introducedIn != null) 'introduced_in': introducedIn,
    });
  }

  MoveTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<int?>? power,
    Value<int?>? accuracy,
    Value<int>? pp,
    Value<String>? damageClass,
    Value<String?>? description,
    Value<int>? priority,
    Value<bool>? isContact,
    Value<bool>? isHealing,
    Value<bool>? isSound,
    Value<bool>? isPunching,
    Value<bool>? isBiting,
    Value<bool>? isPowder,
    Value<bool>? isPulse,
    Value<bool>? isBallistic,
    Value<bool>? isSlicing,
    Value<bool>? isWind,
    Value<bool>? isDance,
    Value<bool>? isBite,
    Value<bool>? isMultiHit,
    Value<bool>? isProtective,
    Value<bool>? isSwitching,
    Value<bool>? isRecharge,
    Value<bool>? isRecoil,
    Value<bool>? isDraining,
    Value<bool>? isStatusMove,
    Value<bool>? isDamagingMove,
    Value<bool>? isSignatureMove,
    Value<bool>? isDLCMove,
    Value<bool>? isChampionsMove,
    Value<bool>? isLegendsZAMove,
    Value<int>? generation,
    Value<String?>? introducedIn,
  }) {
    return MoveTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      power: power ?? this.power,
      accuracy: accuracy ?? this.accuracy,
      pp: pp ?? this.pp,
      damageClass: damageClass ?? this.damageClass,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isContact: isContact ?? this.isContact,
      isHealing: isHealing ?? this.isHealing,
      isSound: isSound ?? this.isSound,
      isPunching: isPunching ?? this.isPunching,
      isBiting: isBiting ?? this.isBiting,
      isPowder: isPowder ?? this.isPowder,
      isPulse: isPulse ?? this.isPulse,
      isBallistic: isBallistic ?? this.isBallistic,
      isSlicing: isSlicing ?? this.isSlicing,
      isWind: isWind ?? this.isWind,
      isDance: isDance ?? this.isDance,
      isBite: isBite ?? this.isBite,
      isMultiHit: isMultiHit ?? this.isMultiHit,
      isProtective: isProtective ?? this.isProtective,
      isSwitching: isSwitching ?? this.isSwitching,
      isRecharge: isRecharge ?? this.isRecharge,
      isRecoil: isRecoil ?? this.isRecoil,
      isDraining: isDraining ?? this.isDraining,
      isStatusMove: isStatusMove ?? this.isStatusMove,
      isDamagingMove: isDamagingMove ?? this.isDamagingMove,
      isSignatureMove: isSignatureMove ?? this.isSignatureMove,
      isDLCMove: isDLCMove ?? this.isDLCMove,
      isChampionsMove: isChampionsMove ?? this.isChampionsMove,
      isLegendsZAMove: isLegendsZAMove ?? this.isLegendsZAMove,
      generation: generation ?? this.generation,
      introducedIn: introducedIn ?? this.introducedIn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (power.present) {
      map['power'] = Variable<int>(power.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<int>(accuracy.value);
    }
    if (pp.present) {
      map['pp'] = Variable<int>(pp.value);
    }
    if (damageClass.present) {
      map['damage_class'] = Variable<String>(damageClass.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (isContact.present) {
      map['is_contact'] = Variable<bool>(isContact.value);
    }
    if (isHealing.present) {
      map['is_healing'] = Variable<bool>(isHealing.value);
    }
    if (isSound.present) {
      map['is_sound'] = Variable<bool>(isSound.value);
    }
    if (isPunching.present) {
      map['is_punching'] = Variable<bool>(isPunching.value);
    }
    if (isBiting.present) {
      map['is_biting'] = Variable<bool>(isBiting.value);
    }
    if (isPowder.present) {
      map['is_powder'] = Variable<bool>(isPowder.value);
    }
    if (isPulse.present) {
      map['is_pulse'] = Variable<bool>(isPulse.value);
    }
    if (isBallistic.present) {
      map['is_ballistic'] = Variable<bool>(isBallistic.value);
    }
    if (isSlicing.present) {
      map['is_slicing'] = Variable<bool>(isSlicing.value);
    }
    if (isWind.present) {
      map['is_wind'] = Variable<bool>(isWind.value);
    }
    if (isDance.present) {
      map['is_dance'] = Variable<bool>(isDance.value);
    }
    if (isBite.present) {
      map['is_bite'] = Variable<bool>(isBite.value);
    }
    if (isMultiHit.present) {
      map['is_multi_hit'] = Variable<bool>(isMultiHit.value);
    }
    if (isProtective.present) {
      map['is_protective'] = Variable<bool>(isProtective.value);
    }
    if (isSwitching.present) {
      map['is_switching'] = Variable<bool>(isSwitching.value);
    }
    if (isRecharge.present) {
      map['is_recharge'] = Variable<bool>(isRecharge.value);
    }
    if (isRecoil.present) {
      map['is_recoil'] = Variable<bool>(isRecoil.value);
    }
    if (isDraining.present) {
      map['is_draining'] = Variable<bool>(isDraining.value);
    }
    if (isStatusMove.present) {
      map['is_status_move'] = Variable<bool>(isStatusMove.value);
    }
    if (isDamagingMove.present) {
      map['is_damaging_move'] = Variable<bool>(isDamagingMove.value);
    }
    if (isSignatureMove.present) {
      map['is_signature_move'] = Variable<bool>(isSignatureMove.value);
    }
    if (isDLCMove.present) {
      map['is_d_l_c_move'] = Variable<bool>(isDLCMove.value);
    }
    if (isChampionsMove.present) {
      map['is_champions_move'] = Variable<bool>(isChampionsMove.value);
    }
    if (isLegendsZAMove.present) {
      map['is_legends_z_a_move'] = Variable<bool>(isLegendsZAMove.value);
    }
    if (generation.present) {
      map['generation'] = Variable<int>(generation.value);
    }
    if (introducedIn.present) {
      map['introduced_in'] = Variable<String>(introducedIn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoveTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('power: $power, ')
          ..write('accuracy: $accuracy, ')
          ..write('pp: $pp, ')
          ..write('damageClass: $damageClass, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('isContact: $isContact, ')
          ..write('isHealing: $isHealing, ')
          ..write('isSound: $isSound, ')
          ..write('isPunching: $isPunching, ')
          ..write('isBiting: $isBiting, ')
          ..write('isPowder: $isPowder, ')
          ..write('isPulse: $isPulse, ')
          ..write('isBallistic: $isBallistic, ')
          ..write('isSlicing: $isSlicing, ')
          ..write('isWind: $isWind, ')
          ..write('isDance: $isDance, ')
          ..write('isBite: $isBite, ')
          ..write('isMultiHit: $isMultiHit, ')
          ..write('isProtective: $isProtective, ')
          ..write('isSwitching: $isSwitching, ')
          ..write('isRecharge: $isRecharge, ')
          ..write('isRecoil: $isRecoil, ')
          ..write('isDraining: $isDraining, ')
          ..write('isStatusMove: $isStatusMove, ')
          ..write('isDamagingMove: $isDamagingMove, ')
          ..write('isSignatureMove: $isSignatureMove, ')
          ..write('isDLCMove: $isDLCMove, ')
          ..write('isChampionsMove: $isChampionsMove, ')
          ..write('isLegendsZAMove: $isLegendsZAMove, ')
          ..write('generation: $generation, ')
          ..write('introducedIn: $introducedIn')
          ..write(')'))
        .toString();
  }
}

class $AbilityTableTable extends AbilityTable
    with TableInfo<$AbilityTableTable, Ability> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AbilityTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generationMeta = const VerificationMeta(
    'generation',
  );
  @override
  late final GeneratedColumn<int> generation = GeneratedColumn<int>(
    'generation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(1),
  );
  static const VerificationMeta _isHiddenAbilityMeta = const VerificationMeta(
    'isHiddenAbility',
  );
  @override
  late final GeneratedColumn<bool> isHiddenAbility = GeneratedColumn<bool>(
    'is_hidden_ability',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden_ability" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isChampionsAbilityMeta =
      const VerificationMeta('isChampionsAbility');
  @override
  late final GeneratedColumn<bool> isChampionsAbility = GeneratedColumn<bool>(
    'is_champions_ability',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_champions_ability" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _isLegendsZAAbilityMeta =
      const VerificationMeta('isLegendsZAAbility');
  @override
  late final GeneratedColumn<bool> isLegendsZAAbility = GeneratedColumn<bool>(
    'is_legends_z_a_ability',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_legends_z_a_ability" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _introducedInMeta = const VerificationMeta(
    'introducedIn',
  );
  @override
  late final GeneratedColumn<String> introducedIn = GeneratedColumn<String>(
    'introduced_in',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceGamesMeta = const VerificationMeta(
    'sourceGames',
  );
  @override
  late final GeneratedColumn<String> sourceGames = GeneratedColumn<String>(
    'source_games',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _effectTagsMeta = const VerificationMeta(
    'effectTags',
  );
  @override
  late final GeneratedColumn<String> effectTags = GeneratedColumn<String>(
    'effect_tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _battleEffectTagsMeta = const VerificationMeta(
    'battleEffectTags',
  );
  @override
  late final GeneratedColumn<String> battleEffectTags = GeneratedColumn<String>(
    'battle_effect_tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pokemonTypesMeta = const VerificationMeta(
    'pokemonTypes',
  );
  @override
  late final GeneratedColumn<String> pokemonTypes = GeneratedColumn<String>(
    'pokemon_types',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    generation,
    isHiddenAbility,
    isChampionsAbility,
    isLegendsZAAbility,
    introducedIn,
    sourceGames,
    effectTags,
    battleEffectTags,
    pokemonTypes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ability_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ability> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('generation')) {
      context.handle(
        _generationMeta,
        generation.isAcceptableOrUnknown(data['generation']!, _generationMeta),
      );
    }
    if (data.containsKey('is_hidden_ability')) {
      context.handle(
        _isHiddenAbilityMeta,
        isHiddenAbility.isAcceptableOrUnknown(
          data['is_hidden_ability']!,
          _isHiddenAbilityMeta,
        ),
      );
    }
    if (data.containsKey('is_champions_ability')) {
      context.handle(
        _isChampionsAbilityMeta,
        isChampionsAbility.isAcceptableOrUnknown(
          data['is_champions_ability']!,
          _isChampionsAbilityMeta,
        ),
      );
    }
    if (data.containsKey('is_legends_z_a_ability')) {
      context.handle(
        _isLegendsZAAbilityMeta,
        isLegendsZAAbility.isAcceptableOrUnknown(
          data['is_legends_z_a_ability']!,
          _isLegendsZAAbilityMeta,
        ),
      );
    }
    if (data.containsKey('introduced_in')) {
      context.handle(
        _introducedInMeta,
        introducedIn.isAcceptableOrUnknown(
          data['introduced_in']!,
          _introducedInMeta,
        ),
      );
    }
    if (data.containsKey('source_games')) {
      context.handle(
        _sourceGamesMeta,
        sourceGames.isAcceptableOrUnknown(
          data['source_games']!,
          _sourceGamesMeta,
        ),
      );
    }
    if (data.containsKey('effect_tags')) {
      context.handle(
        _effectTagsMeta,
        effectTags.isAcceptableOrUnknown(data['effect_tags']!, _effectTagsMeta),
      );
    }
    if (data.containsKey('battle_effect_tags')) {
      context.handle(
        _battleEffectTagsMeta,
        battleEffectTags.isAcceptableOrUnknown(
          data['battle_effect_tags']!,
          _battleEffectTagsMeta,
        ),
      );
    }
    if (data.containsKey('pokemon_types')) {
      context.handle(
        _pokemonTypesMeta,
        pokemonTypes.isAcceptableOrUnknown(
          data['pokemon_types']!,
          _pokemonTypesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ability map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ability(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      generation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generation'],
      )!,
      isHiddenAbility: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden_ability'],
      )!,
      isChampionsAbility: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_champions_ability'],
      )!,
      isLegendsZAAbility: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_legends_z_a_ability'],
      )!,
      introducedIn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}introduced_in'],
      ),
      sourceGames: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_games'],
      ),
      effectTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effect_tags'],
      ),
      battleEffectTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}battle_effect_tags'],
      ),
      pokemonTypes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pokemon_types'],
      ),
    );
  }

  @override
  $AbilityTableTable createAlias(String alias) {
    return $AbilityTableTable(attachedDatabase, alias);
  }
}

class Ability extends DataClass implements Insertable<Ability> {
  final int id;
  final String name;
  final String description;
  final int generation;
  final bool isHiddenAbility;
  final bool isChampionsAbility;
  final bool isLegendsZAAbility;
  final String? introducedIn;
  final String? sourceGames;
  final String? effectTags;
  final String? battleEffectTags;
  final String? pokemonTypes;
  const Ability({
    required this.id,
    required this.name,
    required this.description,
    required this.generation,
    required this.isHiddenAbility,
    required this.isChampionsAbility,
    required this.isLegendsZAAbility,
    this.introducedIn,
    this.sourceGames,
    this.effectTags,
    this.battleEffectTags,
    this.pokemonTypes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['generation'] = Variable<int>(generation);
    map['is_hidden_ability'] = Variable<bool>(isHiddenAbility);
    map['is_champions_ability'] = Variable<bool>(isChampionsAbility);
    map['is_legends_z_a_ability'] = Variable<bool>(isLegendsZAAbility);
    if (!nullToAbsent || introducedIn != null) {
      map['introduced_in'] = Variable<String>(introducedIn);
    }
    if (!nullToAbsent || sourceGames != null) {
      map['source_games'] = Variable<String>(sourceGames);
    }
    if (!nullToAbsent || effectTags != null) {
      map['effect_tags'] = Variable<String>(effectTags);
    }
    if (!nullToAbsent || battleEffectTags != null) {
      map['battle_effect_tags'] = Variable<String>(battleEffectTags);
    }
    if (!nullToAbsent || pokemonTypes != null) {
      map['pokemon_types'] = Variable<String>(pokemonTypes);
    }
    return map;
  }

  AbilityTableCompanion toCompanion(bool nullToAbsent) {
    return AbilityTableCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      generation: Value(generation),
      isHiddenAbility: Value(isHiddenAbility),
      isChampionsAbility: Value(isChampionsAbility),
      isLegendsZAAbility: Value(isLegendsZAAbility),
      introducedIn: introducedIn == null && nullToAbsent
          ? const Value.absent()
          : Value(introducedIn),
      sourceGames: sourceGames == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceGames),
      effectTags: effectTags == null && nullToAbsent
          ? const Value.absent()
          : Value(effectTags),
      battleEffectTags: battleEffectTags == null && nullToAbsent
          ? const Value.absent()
          : Value(battleEffectTags),
      pokemonTypes: pokemonTypes == null && nullToAbsent
          ? const Value.absent()
          : Value(pokemonTypes),
    );
  }

  factory Ability.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ability(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      generation: serializer.fromJson<int>(json['generation']),
      isHiddenAbility: serializer.fromJson<bool>(json['isHiddenAbility']),
      isChampionsAbility: serializer.fromJson<bool>(json['isChampionsAbility']),
      isLegendsZAAbility: serializer.fromJson<bool>(json['isLegendsZAAbility']),
      introducedIn: serializer.fromJson<String?>(json['introducedIn']),
      sourceGames: serializer.fromJson<String?>(json['sourceGames']),
      effectTags: serializer.fromJson<String?>(json['effectTags']),
      battleEffectTags: serializer.fromJson<String?>(json['battleEffectTags']),
      pokemonTypes: serializer.fromJson<String?>(json['pokemonTypes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'generation': serializer.toJson<int>(generation),
      'isHiddenAbility': serializer.toJson<bool>(isHiddenAbility),
      'isChampionsAbility': serializer.toJson<bool>(isChampionsAbility),
      'isLegendsZAAbility': serializer.toJson<bool>(isLegendsZAAbility),
      'introducedIn': serializer.toJson<String?>(introducedIn),
      'sourceGames': serializer.toJson<String?>(sourceGames),
      'effectTags': serializer.toJson<String?>(effectTags),
      'battleEffectTags': serializer.toJson<String?>(battleEffectTags),
      'pokemonTypes': serializer.toJson<String?>(pokemonTypes),
    };
  }

  Ability copyWith({
    int? id,
    String? name,
    String? description,
    int? generation,
    bool? isHiddenAbility,
    bool? isChampionsAbility,
    bool? isLegendsZAAbility,
    Value<String?> introducedIn = const Value.absent(),
    Value<String?> sourceGames = const Value.absent(),
    Value<String?> effectTags = const Value.absent(),
    Value<String?> battleEffectTags = const Value.absent(),
    Value<String?> pokemonTypes = const Value.absent(),
  }) => Ability(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    generation: generation ?? this.generation,
    isHiddenAbility: isHiddenAbility ?? this.isHiddenAbility,
    isChampionsAbility: isChampionsAbility ?? this.isChampionsAbility,
    isLegendsZAAbility: isLegendsZAAbility ?? this.isLegendsZAAbility,
    introducedIn: introducedIn.present ? introducedIn.value : this.introducedIn,
    sourceGames: sourceGames.present ? sourceGames.value : this.sourceGames,
    effectTags: effectTags.present ? effectTags.value : this.effectTags,
    battleEffectTags: battleEffectTags.present
        ? battleEffectTags.value
        : this.battleEffectTags,
    pokemonTypes: pokemonTypes.present ? pokemonTypes.value : this.pokemonTypes,
  );
  Ability copyWithCompanion(AbilityTableCompanion data) {
    return Ability(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      generation: data.generation.present
          ? data.generation.value
          : this.generation,
      isHiddenAbility: data.isHiddenAbility.present
          ? data.isHiddenAbility.value
          : this.isHiddenAbility,
      isChampionsAbility: data.isChampionsAbility.present
          ? data.isChampionsAbility.value
          : this.isChampionsAbility,
      isLegendsZAAbility: data.isLegendsZAAbility.present
          ? data.isLegendsZAAbility.value
          : this.isLegendsZAAbility,
      introducedIn: data.introducedIn.present
          ? data.introducedIn.value
          : this.introducedIn,
      sourceGames: data.sourceGames.present
          ? data.sourceGames.value
          : this.sourceGames,
      effectTags: data.effectTags.present
          ? data.effectTags.value
          : this.effectTags,
      battleEffectTags: data.battleEffectTags.present
          ? data.battleEffectTags.value
          : this.battleEffectTags,
      pokemonTypes: data.pokemonTypes.present
          ? data.pokemonTypes.value
          : this.pokemonTypes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ability(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('generation: $generation, ')
          ..write('isHiddenAbility: $isHiddenAbility, ')
          ..write('isChampionsAbility: $isChampionsAbility, ')
          ..write('isLegendsZAAbility: $isLegendsZAAbility, ')
          ..write('introducedIn: $introducedIn, ')
          ..write('sourceGames: $sourceGames, ')
          ..write('effectTags: $effectTags, ')
          ..write('battleEffectTags: $battleEffectTags, ')
          ..write('pokemonTypes: $pokemonTypes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    generation,
    isHiddenAbility,
    isChampionsAbility,
    isLegendsZAAbility,
    introducedIn,
    sourceGames,
    effectTags,
    battleEffectTags,
    pokemonTypes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ability &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.generation == this.generation &&
          other.isHiddenAbility == this.isHiddenAbility &&
          other.isChampionsAbility == this.isChampionsAbility &&
          other.isLegendsZAAbility == this.isLegendsZAAbility &&
          other.introducedIn == this.introducedIn &&
          other.sourceGames == this.sourceGames &&
          other.effectTags == this.effectTags &&
          other.battleEffectTags == this.battleEffectTags &&
          other.pokemonTypes == this.pokemonTypes);
}

class AbilityTableCompanion extends UpdateCompanion<Ability> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> description;
  final Value<int> generation;
  final Value<bool> isHiddenAbility;
  final Value<bool> isChampionsAbility;
  final Value<bool> isLegendsZAAbility;
  final Value<String?> introducedIn;
  final Value<String?> sourceGames;
  final Value<String?> effectTags;
  final Value<String?> battleEffectTags;
  final Value<String?> pokemonTypes;
  const AbilityTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.generation = const Value.absent(),
    this.isHiddenAbility = const Value.absent(),
    this.isChampionsAbility = const Value.absent(),
    this.isLegendsZAAbility = const Value.absent(),
    this.introducedIn = const Value.absent(),
    this.sourceGames = const Value.absent(),
    this.effectTags = const Value.absent(),
    this.battleEffectTags = const Value.absent(),
    this.pokemonTypes = const Value.absent(),
  });
  AbilityTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String description,
    this.generation = const Value.absent(),
    this.isHiddenAbility = const Value.absent(),
    this.isChampionsAbility = const Value.absent(),
    this.isLegendsZAAbility = const Value.absent(),
    this.introducedIn = const Value.absent(),
    this.sourceGames = const Value.absent(),
    this.effectTags = const Value.absent(),
    this.battleEffectTags = const Value.absent(),
    this.pokemonTypes = const Value.absent(),
  }) : name = Value(name),
       description = Value(description);
  static Insertable<Ability> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? generation,
    Expression<bool>? isHiddenAbility,
    Expression<bool>? isChampionsAbility,
    Expression<bool>? isLegendsZAAbility,
    Expression<String>? introducedIn,
    Expression<String>? sourceGames,
    Expression<String>? effectTags,
    Expression<String>? battleEffectTags,
    Expression<String>? pokemonTypes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (generation != null) 'generation': generation,
      if (isHiddenAbility != null) 'is_hidden_ability': isHiddenAbility,
      if (isChampionsAbility != null)
        'is_champions_ability': isChampionsAbility,
      if (isLegendsZAAbility != null)
        'is_legends_z_a_ability': isLegendsZAAbility,
      if (introducedIn != null) 'introduced_in': introducedIn,
      if (sourceGames != null) 'source_games': sourceGames,
      if (effectTags != null) 'effect_tags': effectTags,
      if (battleEffectTags != null) 'battle_effect_tags': battleEffectTags,
      if (pokemonTypes != null) 'pokemon_types': pokemonTypes,
    });
  }

  AbilityTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? description,
    Value<int>? generation,
    Value<bool>? isHiddenAbility,
    Value<bool>? isChampionsAbility,
    Value<bool>? isLegendsZAAbility,
    Value<String?>? introducedIn,
    Value<String?>? sourceGames,
    Value<String?>? effectTags,
    Value<String?>? battleEffectTags,
    Value<String?>? pokemonTypes,
  }) {
    return AbilityTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      generation: generation ?? this.generation,
      isHiddenAbility: isHiddenAbility ?? this.isHiddenAbility,
      isChampionsAbility: isChampionsAbility ?? this.isChampionsAbility,
      isLegendsZAAbility: isLegendsZAAbility ?? this.isLegendsZAAbility,
      introducedIn: introducedIn ?? this.introducedIn,
      sourceGames: sourceGames ?? this.sourceGames,
      effectTags: effectTags ?? this.effectTags,
      battleEffectTags: battleEffectTags ?? this.battleEffectTags,
      pokemonTypes: pokemonTypes ?? this.pokemonTypes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (generation.present) {
      map['generation'] = Variable<int>(generation.value);
    }
    if (isHiddenAbility.present) {
      map['is_hidden_ability'] = Variable<bool>(isHiddenAbility.value);
    }
    if (isChampionsAbility.present) {
      map['is_champions_ability'] = Variable<bool>(isChampionsAbility.value);
    }
    if (isLegendsZAAbility.present) {
      map['is_legends_z_a_ability'] = Variable<bool>(isLegendsZAAbility.value);
    }
    if (introducedIn.present) {
      map['introduced_in'] = Variable<String>(introducedIn.value);
    }
    if (sourceGames.present) {
      map['source_games'] = Variable<String>(sourceGames.value);
    }
    if (effectTags.present) {
      map['effect_tags'] = Variable<String>(effectTags.value);
    }
    if (battleEffectTags.present) {
      map['battle_effect_tags'] = Variable<String>(battleEffectTags.value);
    }
    if (pokemonTypes.present) {
      map['pokemon_types'] = Variable<String>(pokemonTypes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AbilityTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('generation: $generation, ')
          ..write('isHiddenAbility: $isHiddenAbility, ')
          ..write('isChampionsAbility: $isChampionsAbility, ')
          ..write('isLegendsZAAbility: $isLegendsZAAbility, ')
          ..write('introducedIn: $introducedIn, ')
          ..write('sourceGames: $sourceGames, ')
          ..write('effectTags: $effectTags, ')
          ..write('battleEffectTags: $battleEffectTags, ')
          ..write('pokemonTypes: $pokemonTypes')
          ..write(')'))
        .toString();
  }
}

class $PokemonMovesTableTable extends PokemonMovesTable
    with TableInfo<$PokemonMovesTableTable, PokemonMove> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonMovesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pokemon_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _moveIdMeta = const VerificationMeta('moveId');
  @override
  late final GeneratedColumn<int> moveId = GeneratedColumn<int>(
    'move_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES move_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _learnMethodMeta = const VerificationMeta(
    'learnMethod',
  );
  @override
  late final GeneratedColumn<String> learnMethod = GeneratedColumn<String>(
    'learn_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelLearnedMeta = const VerificationMeta(
    'levelLearned',
  );
  @override
  late final GeneratedColumn<int> levelLearned = GeneratedColumn<int>(
    'level_learned',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    pokemonId,
    moveId,
    learnMethod,
    levelLearned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_moves_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonMove> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pokemonIdMeta);
    }
    if (data.containsKey('move_id')) {
      context.handle(
        _moveIdMeta,
        moveId.isAcceptableOrUnknown(data['move_id']!, _moveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moveIdMeta);
    }
    if (data.containsKey('learn_method')) {
      context.handle(
        _learnMethodMeta,
        learnMethod.isAcceptableOrUnknown(
          data['learn_method']!,
          _learnMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_learnMethodMeta);
    }
    if (data.containsKey('level_learned')) {
      context.handle(
        _levelLearnedMeta,
        levelLearned.isAcceptableOrUnknown(
          data['level_learned']!,
          _levelLearnedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pokemonId, moveId, learnMethod};
  @override
  PokemonMove map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonMove(
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokemon_id'],
      )!,
      moveId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}move_id'],
      )!,
      learnMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learn_method'],
      )!,
      levelLearned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level_learned'],
      ),
    );
  }

  @override
  $PokemonMovesTableTable createAlias(String alias) {
    return $PokemonMovesTableTable(attachedDatabase, alias);
  }
}

class PokemonMove extends DataClass implements Insertable<PokemonMove> {
  final int pokemonId;
  final int moveId;
  final String learnMethod;
  final int? levelLearned;
  const PokemonMove({
    required this.pokemonId,
    required this.moveId,
    required this.learnMethod,
    this.levelLearned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['move_id'] = Variable<int>(moveId);
    map['learn_method'] = Variable<String>(learnMethod);
    if (!nullToAbsent || levelLearned != null) {
      map['level_learned'] = Variable<int>(levelLearned);
    }
    return map;
  }

  PokemonMovesTableCompanion toCompanion(bool nullToAbsent) {
    return PokemonMovesTableCompanion(
      pokemonId: Value(pokemonId),
      moveId: Value(moveId),
      learnMethod: Value(learnMethod),
      levelLearned: levelLearned == null && nullToAbsent
          ? const Value.absent()
          : Value(levelLearned),
    );
  }

  factory PokemonMove.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonMove(
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      moveId: serializer.fromJson<int>(json['moveId']),
      learnMethod: serializer.fromJson<String>(json['learnMethod']),
      levelLearned: serializer.fromJson<int?>(json['levelLearned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pokemonId': serializer.toJson<int>(pokemonId),
      'moveId': serializer.toJson<int>(moveId),
      'learnMethod': serializer.toJson<String>(learnMethod),
      'levelLearned': serializer.toJson<int?>(levelLearned),
    };
  }

  PokemonMove copyWith({
    int? pokemonId,
    int? moveId,
    String? learnMethod,
    Value<int?> levelLearned = const Value.absent(),
  }) => PokemonMove(
    pokemonId: pokemonId ?? this.pokemonId,
    moveId: moveId ?? this.moveId,
    learnMethod: learnMethod ?? this.learnMethod,
    levelLearned: levelLearned.present ? levelLearned.value : this.levelLearned,
  );
  PokemonMove copyWithCompanion(PokemonMovesTableCompanion data) {
    return PokemonMove(
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      moveId: data.moveId.present ? data.moveId.value : this.moveId,
      learnMethod: data.learnMethod.present
          ? data.learnMethod.value
          : this.learnMethod,
      levelLearned: data.levelLearned.present
          ? data.levelLearned.value
          : this.levelLearned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonMove(')
          ..write('pokemonId: $pokemonId, ')
          ..write('moveId: $moveId, ')
          ..write('learnMethod: $learnMethod, ')
          ..write('levelLearned: $levelLearned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pokemonId, moveId, learnMethod, levelLearned);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonMove &&
          other.pokemonId == this.pokemonId &&
          other.moveId == this.moveId &&
          other.learnMethod == this.learnMethod &&
          other.levelLearned == this.levelLearned);
}

class PokemonMovesTableCompanion extends UpdateCompanion<PokemonMove> {
  final Value<int> pokemonId;
  final Value<int> moveId;
  final Value<String> learnMethod;
  final Value<int?> levelLearned;
  final Value<int> rowid;
  const PokemonMovesTableCompanion({
    this.pokemonId = const Value.absent(),
    this.moveId = const Value.absent(),
    this.learnMethod = const Value.absent(),
    this.levelLearned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PokemonMovesTableCompanion.insert({
    required int pokemonId,
    required int moveId,
    required String learnMethod,
    this.levelLearned = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : pokemonId = Value(pokemonId),
       moveId = Value(moveId),
       learnMethod = Value(learnMethod);
  static Insertable<PokemonMove> custom({
    Expression<int>? pokemonId,
    Expression<int>? moveId,
    Expression<String>? learnMethod,
    Expression<int>? levelLearned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (moveId != null) 'move_id': moveId,
      if (learnMethod != null) 'learn_method': learnMethod,
      if (levelLearned != null) 'level_learned': levelLearned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PokemonMovesTableCompanion copyWith({
    Value<int>? pokemonId,
    Value<int>? moveId,
    Value<String>? learnMethod,
    Value<int?>? levelLearned,
    Value<int>? rowid,
  }) {
    return PokemonMovesTableCompanion(
      pokemonId: pokemonId ?? this.pokemonId,
      moveId: moveId ?? this.moveId,
      learnMethod: learnMethod ?? this.learnMethod,
      levelLearned: levelLearned ?? this.levelLearned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (moveId.present) {
      map['move_id'] = Variable<int>(moveId.value);
    }
    if (learnMethod.present) {
      map['learn_method'] = Variable<String>(learnMethod.value);
    }
    if (levelLearned.present) {
      map['level_learned'] = Variable<int>(levelLearned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonMovesTableCompanion(')
          ..write('pokemonId: $pokemonId, ')
          ..write('moveId: $moveId, ')
          ..write('learnMethod: $learnMethod, ')
          ..write('levelLearned: $levelLearned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PokemonAbilitiesTableTable extends PokemonAbilitiesTable
    with TableInfo<$PokemonAbilitiesTableTable, PokemonAbility> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonAbilitiesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pokemon_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _abilityIdMeta = const VerificationMeta(
    'abilityId',
  );
  @override
  late final GeneratedColumn<int> abilityId = GeneratedColumn<int>(
    'ability_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ability_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [pokemonId, abilityId, isHidden];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_abilities_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonAbility> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pokemonIdMeta);
    }
    if (data.containsKey('ability_id')) {
      context.handle(
        _abilityIdMeta,
        abilityId.isAcceptableOrUnknown(data['ability_id']!, _abilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_abilityIdMeta);
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    } else if (isInserting) {
      context.missing(_isHiddenMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pokemonId, abilityId};
  @override
  PokemonAbility map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonAbility(
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokemon_id'],
      )!,
      abilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ability_id'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
    );
  }

  @override
  $PokemonAbilitiesTableTable createAlias(String alias) {
    return $PokemonAbilitiesTableTable(attachedDatabase, alias);
  }
}

class PokemonAbility extends DataClass implements Insertable<PokemonAbility> {
  final int pokemonId;
  final int abilityId;
  final bool isHidden;
  const PokemonAbility({
    required this.pokemonId,
    required this.abilityId,
    required this.isHidden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['ability_id'] = Variable<int>(abilityId);
    map['is_hidden'] = Variable<bool>(isHidden);
    return map;
  }

  PokemonAbilitiesTableCompanion toCompanion(bool nullToAbsent) {
    return PokemonAbilitiesTableCompanion(
      pokemonId: Value(pokemonId),
      abilityId: Value(abilityId),
      isHidden: Value(isHidden),
    );
  }

  factory PokemonAbility.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonAbility(
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      abilityId: serializer.fromJson<int>(json['abilityId']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pokemonId': serializer.toJson<int>(pokemonId),
      'abilityId': serializer.toJson<int>(abilityId),
      'isHidden': serializer.toJson<bool>(isHidden),
    };
  }

  PokemonAbility copyWith({int? pokemonId, int? abilityId, bool? isHidden}) =>
      PokemonAbility(
        pokemonId: pokemonId ?? this.pokemonId,
        abilityId: abilityId ?? this.abilityId,
        isHidden: isHidden ?? this.isHidden,
      );
  PokemonAbility copyWithCompanion(PokemonAbilitiesTableCompanion data) {
    return PokemonAbility(
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      abilityId: data.abilityId.present ? data.abilityId.value : this.abilityId,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonAbility(')
          ..write('pokemonId: $pokemonId, ')
          ..write('abilityId: $abilityId, ')
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pokemonId, abilityId, isHidden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonAbility &&
          other.pokemonId == this.pokemonId &&
          other.abilityId == this.abilityId &&
          other.isHidden == this.isHidden);
}

class PokemonAbilitiesTableCompanion extends UpdateCompanion<PokemonAbility> {
  final Value<int> pokemonId;
  final Value<int> abilityId;
  final Value<bool> isHidden;
  final Value<int> rowid;
  const PokemonAbilitiesTableCompanion({
    this.pokemonId = const Value.absent(),
    this.abilityId = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PokemonAbilitiesTableCompanion.insert({
    required int pokemonId,
    required int abilityId,
    required bool isHidden,
    this.rowid = const Value.absent(),
  }) : pokemonId = Value(pokemonId),
       abilityId = Value(abilityId),
       isHidden = Value(isHidden);
  static Insertable<PokemonAbility> custom({
    Expression<int>? pokemonId,
    Expression<int>? abilityId,
    Expression<bool>? isHidden,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (abilityId != null) 'ability_id': abilityId,
      if (isHidden != null) 'is_hidden': isHidden,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PokemonAbilitiesTableCompanion copyWith({
    Value<int>? pokemonId,
    Value<int>? abilityId,
    Value<bool>? isHidden,
    Value<int>? rowid,
  }) {
    return PokemonAbilitiesTableCompanion(
      pokemonId: pokemonId ?? this.pokemonId,
      abilityId: abilityId ?? this.abilityId,
      isHidden: isHidden ?? this.isHidden,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (abilityId.present) {
      map['ability_id'] = Variable<int>(abilityId.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonAbilitiesTableCompanion(')
          ..write('pokemonId: $pokemonId, ')
          ..write('abilityId: $abilityId, ')
          ..write('isHidden: $isHidden, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PokemonTableTable pokemonTable = $PokemonTableTable(this);
  late final $MoveTableTable moveTable = $MoveTableTable(this);
  late final $AbilityTableTable abilityTable = $AbilityTableTable(this);
  late final $PokemonMovesTableTable pokemonMovesTable =
      $PokemonMovesTableTable(this);
  late final $PokemonAbilitiesTableTable pokemonAbilitiesTable =
      $PokemonAbilitiesTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pokemonTable,
    moveTable,
    abilityTable,
    pokemonMovesTable,
    pokemonAbilitiesTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pokemon_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pokemon_moves_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'move_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pokemon_moves_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pokemon_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pokemon_abilities_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ability_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pokemon_abilities_table', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PokemonTableTableCreateCompanionBuilder =
    PokemonTableCompanion Function({
      Value<int> id,
      required String name,
      required String form,
      required String type1,
      Value<String?> type2,
      required int baseHp,
      required int baseAtk,
      required int baseDef,
      required int baseSpAtk,
      required int baseSpDef,
      required int baseSpd,
      required bool isLegendary,
      required bool isMythical,
      required bool isParadox,
      required bool isUltraBeast,
      required String spriteUrl,
      required String shinySpriteUrl,
      Value<int> nationalDexNumber,
      Value<int> generation,
      Value<int> evolutionStage,
      Value<String?> eggGroups,
      Value<String?> formSource,
      Value<String?> dlcSource,
      Value<bool> isChampions,
      Value<bool> isLegendsZA,
    });
typedef $$PokemonTableTableUpdateCompanionBuilder =
    PokemonTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> form,
      Value<String> type1,
      Value<String?> type2,
      Value<int> baseHp,
      Value<int> baseAtk,
      Value<int> baseDef,
      Value<int> baseSpAtk,
      Value<int> baseSpDef,
      Value<int> baseSpd,
      Value<bool> isLegendary,
      Value<bool> isMythical,
      Value<bool> isParadox,
      Value<bool> isUltraBeast,
      Value<String> spriteUrl,
      Value<String> shinySpriteUrl,
      Value<int> nationalDexNumber,
      Value<int> generation,
      Value<int> evolutionStage,
      Value<String?> eggGroups,
      Value<String?> formSource,
      Value<String?> dlcSource,
      Value<bool> isChampions,
      Value<bool> isLegendsZA,
    });

final class $$PokemonTableTableReferences
    extends BaseReferences<_$AppDatabase, $PokemonTableTable, Pokemon> {
  $$PokemonTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PokemonMovesTableTable, List<PokemonMove>>
  _pokemonMovesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pokemonMovesTable,
        aliasName: $_aliasNameGenerator(
          db.pokemonTable.id,
          db.pokemonMovesTable.pokemonId,
        ),
      );

  $$PokemonMovesTableTableProcessedTableManager get pokemonMovesTableRefs {
    final manager = $$PokemonMovesTableTableTableManager(
      $_db,
      $_db.pokemonMovesTable,
    ).filter((f) => f.pokemonId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pokemonMovesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PokemonAbilitiesTableTable, List<PokemonAbility>>
  _pokemonAbilitiesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pokemonAbilitiesTable,
        aliasName: $_aliasNameGenerator(
          db.pokemonTable.id,
          db.pokemonAbilitiesTable.pokemonId,
        ),
      );

  $$PokemonAbilitiesTableTableProcessedTableManager
  get pokemonAbilitiesTableRefs {
    final manager = $$PokemonAbilitiesTableTableTableManager(
      $_db,
      $_db.pokemonAbilitiesTable,
    ).filter((f) => f.pokemonId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pokemonAbilitiesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PokemonTableTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonTableTable> {
  $$PokemonTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type1 => $composableBuilder(
    column: $table.type1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type2 => $composableBuilder(
    column: $table.type2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseHp => $composableBuilder(
    column: $table.baseHp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseAtk => $composableBuilder(
    column: $table.baseAtk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseDef => $composableBuilder(
    column: $table.baseDef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseSpAtk => $composableBuilder(
    column: $table.baseSpAtk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseSpDef => $composableBuilder(
    column: $table.baseSpDef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseSpd => $composableBuilder(
    column: $table.baseSpd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLegendary => $composableBuilder(
    column: $table.isLegendary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMythical => $composableBuilder(
    column: $table.isMythical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isParadox => $composableBuilder(
    column: $table.isParadox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUltraBeast => $composableBuilder(
    column: $table.isUltraBeast,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spriteUrl => $composableBuilder(
    column: $table.spriteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shinySpriteUrl => $composableBuilder(
    column: $table.shinySpriteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nationalDexNumber => $composableBuilder(
    column: $table.nationalDexNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get evolutionStage => $composableBuilder(
    column: $table.evolutionStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eggGroups => $composableBuilder(
    column: $table.eggGroups,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formSource => $composableBuilder(
    column: $table.formSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dlcSource => $composableBuilder(
    column: $table.dlcSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isChampions => $composableBuilder(
    column: $table.isChampions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLegendsZA => $composableBuilder(
    column: $table.isLegendsZA,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pokemonMovesTableRefs(
    Expression<bool> Function($$PokemonMovesTableTableFilterComposer f) f,
  ) {
    final $$PokemonMovesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pokemonMovesTable,
      getReferencedColumn: (t) => t.pokemonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonMovesTableTableFilterComposer(
            $db: $db,
            $table: $db.pokemonMovesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pokemonAbilitiesTableRefs(
    Expression<bool> Function($$PokemonAbilitiesTableTableFilterComposer f) f,
  ) {
    final $$PokemonAbilitiesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pokemonAbilitiesTable,
          getReferencedColumn: (t) => t.pokemonId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PokemonAbilitiesTableTableFilterComposer(
                $db: $db,
                $table: $db.pokemonAbilitiesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PokemonTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonTableTable> {
  $$PokemonTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type1 => $composableBuilder(
    column: $table.type1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type2 => $composableBuilder(
    column: $table.type2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseHp => $composableBuilder(
    column: $table.baseHp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseAtk => $composableBuilder(
    column: $table.baseAtk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseDef => $composableBuilder(
    column: $table.baseDef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseSpAtk => $composableBuilder(
    column: $table.baseSpAtk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseSpDef => $composableBuilder(
    column: $table.baseSpDef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseSpd => $composableBuilder(
    column: $table.baseSpd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLegendary => $composableBuilder(
    column: $table.isLegendary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMythical => $composableBuilder(
    column: $table.isMythical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isParadox => $composableBuilder(
    column: $table.isParadox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUltraBeast => $composableBuilder(
    column: $table.isUltraBeast,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spriteUrl => $composableBuilder(
    column: $table.spriteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shinySpriteUrl => $composableBuilder(
    column: $table.shinySpriteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nationalDexNumber => $composableBuilder(
    column: $table.nationalDexNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get evolutionStage => $composableBuilder(
    column: $table.evolutionStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eggGroups => $composableBuilder(
    column: $table.eggGroups,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formSource => $composableBuilder(
    column: $table.formSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dlcSource => $composableBuilder(
    column: $table.dlcSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isChampions => $composableBuilder(
    column: $table.isChampions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLegendsZA => $composableBuilder(
    column: $table.isLegendsZA,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PokemonTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonTableTable> {
  $$PokemonTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => column);

  GeneratedColumn<String> get type1 =>
      $composableBuilder(column: $table.type1, builder: (column) => column);

  GeneratedColumn<String> get type2 =>
      $composableBuilder(column: $table.type2, builder: (column) => column);

  GeneratedColumn<int> get baseHp =>
      $composableBuilder(column: $table.baseHp, builder: (column) => column);

  GeneratedColumn<int> get baseAtk =>
      $composableBuilder(column: $table.baseAtk, builder: (column) => column);

  GeneratedColumn<int> get baseDef =>
      $composableBuilder(column: $table.baseDef, builder: (column) => column);

  GeneratedColumn<int> get baseSpAtk =>
      $composableBuilder(column: $table.baseSpAtk, builder: (column) => column);

  GeneratedColumn<int> get baseSpDef =>
      $composableBuilder(column: $table.baseSpDef, builder: (column) => column);

  GeneratedColumn<int> get baseSpd =>
      $composableBuilder(column: $table.baseSpd, builder: (column) => column);

  GeneratedColumn<bool> get isLegendary => $composableBuilder(
    column: $table.isLegendary,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMythical => $composableBuilder(
    column: $table.isMythical,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isParadox =>
      $composableBuilder(column: $table.isParadox, builder: (column) => column);

  GeneratedColumn<bool> get isUltraBeast => $composableBuilder(
    column: $table.isUltraBeast,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spriteUrl =>
      $composableBuilder(column: $table.spriteUrl, builder: (column) => column);

  GeneratedColumn<String> get shinySpriteUrl => $composableBuilder(
    column: $table.shinySpriteUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nationalDexNumber => $composableBuilder(
    column: $table.nationalDexNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get evolutionStage => $composableBuilder(
    column: $table.evolutionStage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eggGroups =>
      $composableBuilder(column: $table.eggGroups, builder: (column) => column);

  GeneratedColumn<String> get formSource => $composableBuilder(
    column: $table.formSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dlcSource =>
      $composableBuilder(column: $table.dlcSource, builder: (column) => column);

  GeneratedColumn<bool> get isChampions => $composableBuilder(
    column: $table.isChampions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLegendsZA => $composableBuilder(
    column: $table.isLegendsZA,
    builder: (column) => column,
  );

  Expression<T> pokemonMovesTableRefs<T extends Object>(
    Expression<T> Function($$PokemonMovesTableTableAnnotationComposer a) f,
  ) {
    final $$PokemonMovesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pokemonMovesTable,
          getReferencedColumn: (t) => t.pokemonId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PokemonMovesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pokemonMovesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> pokemonAbilitiesTableRefs<T extends Object>(
    Expression<T> Function($$PokemonAbilitiesTableTableAnnotationComposer a) f,
  ) {
    final $$PokemonAbilitiesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pokemonAbilitiesTable,
          getReferencedColumn: (t) => t.pokemonId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PokemonAbilitiesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pokemonAbilitiesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PokemonTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokemonTableTable,
          Pokemon,
          $$PokemonTableTableFilterComposer,
          $$PokemonTableTableOrderingComposer,
          $$PokemonTableTableAnnotationComposer,
          $$PokemonTableTableCreateCompanionBuilder,
          $$PokemonTableTableUpdateCompanionBuilder,
          (Pokemon, $$PokemonTableTableReferences),
          Pokemon,
          PrefetchHooks Function({
            bool pokemonMovesTableRefs,
            bool pokemonAbilitiesTableRefs,
          })
        > {
  $$PokemonTableTableTableManager(_$AppDatabase db, $PokemonTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PokemonTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PokemonTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> form = const Value.absent(),
                Value<String> type1 = const Value.absent(),
                Value<String?> type2 = const Value.absent(),
                Value<int> baseHp = const Value.absent(),
                Value<int> baseAtk = const Value.absent(),
                Value<int> baseDef = const Value.absent(),
                Value<int> baseSpAtk = const Value.absent(),
                Value<int> baseSpDef = const Value.absent(),
                Value<int> baseSpd = const Value.absent(),
                Value<bool> isLegendary = const Value.absent(),
                Value<bool> isMythical = const Value.absent(),
                Value<bool> isParadox = const Value.absent(),
                Value<bool> isUltraBeast = const Value.absent(),
                Value<String> spriteUrl = const Value.absent(),
                Value<String> shinySpriteUrl = const Value.absent(),
                Value<int> nationalDexNumber = const Value.absent(),
                Value<int> generation = const Value.absent(),
                Value<int> evolutionStage = const Value.absent(),
                Value<String?> eggGroups = const Value.absent(),
                Value<String?> formSource = const Value.absent(),
                Value<String?> dlcSource = const Value.absent(),
                Value<bool> isChampions = const Value.absent(),
                Value<bool> isLegendsZA = const Value.absent(),
              }) => PokemonTableCompanion(
                id: id,
                name: name,
                form: form,
                type1: type1,
                type2: type2,
                baseHp: baseHp,
                baseAtk: baseAtk,
                baseDef: baseDef,
                baseSpAtk: baseSpAtk,
                baseSpDef: baseSpDef,
                baseSpd: baseSpd,
                isLegendary: isLegendary,
                isMythical: isMythical,
                isParadox: isParadox,
                isUltraBeast: isUltraBeast,
                spriteUrl: spriteUrl,
                shinySpriteUrl: shinySpriteUrl,
                nationalDexNumber: nationalDexNumber,
                generation: generation,
                evolutionStage: evolutionStage,
                eggGroups: eggGroups,
                formSource: formSource,
                dlcSource: dlcSource,
                isChampions: isChampions,
                isLegendsZA: isLegendsZA,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String form,
                required String type1,
                Value<String?> type2 = const Value.absent(),
                required int baseHp,
                required int baseAtk,
                required int baseDef,
                required int baseSpAtk,
                required int baseSpDef,
                required int baseSpd,
                required bool isLegendary,
                required bool isMythical,
                required bool isParadox,
                required bool isUltraBeast,
                required String spriteUrl,
                required String shinySpriteUrl,
                Value<int> nationalDexNumber = const Value.absent(),
                Value<int> generation = const Value.absent(),
                Value<int> evolutionStage = const Value.absent(),
                Value<String?> eggGroups = const Value.absent(),
                Value<String?> formSource = const Value.absent(),
                Value<String?> dlcSource = const Value.absent(),
                Value<bool> isChampions = const Value.absent(),
                Value<bool> isLegendsZA = const Value.absent(),
              }) => PokemonTableCompanion.insert(
                id: id,
                name: name,
                form: form,
                type1: type1,
                type2: type2,
                baseHp: baseHp,
                baseAtk: baseAtk,
                baseDef: baseDef,
                baseSpAtk: baseSpAtk,
                baseSpDef: baseSpDef,
                baseSpd: baseSpd,
                isLegendary: isLegendary,
                isMythical: isMythical,
                isParadox: isParadox,
                isUltraBeast: isUltraBeast,
                spriteUrl: spriteUrl,
                shinySpriteUrl: shinySpriteUrl,
                nationalDexNumber: nationalDexNumber,
                generation: generation,
                evolutionStage: evolutionStage,
                eggGroups: eggGroups,
                formSource: formSource,
                dlcSource: dlcSource,
                isChampions: isChampions,
                isLegendsZA: isLegendsZA,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PokemonTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pokemonMovesTableRefs = false,
                pokemonAbilitiesTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pokemonMovesTableRefs) db.pokemonMovesTable,
                    if (pokemonAbilitiesTableRefs) db.pokemonAbilitiesTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pokemonMovesTableRefs)
                        await $_getPrefetchedData<
                          Pokemon,
                          $PokemonTableTable,
                          PokemonMove
                        >(
                          currentTable: table,
                          referencedTable: $$PokemonTableTableReferences
                              ._pokemonMovesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PokemonTableTableReferences(
                                db,
                                table,
                                p0,
                              ).pokemonMovesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pokemonId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pokemonAbilitiesTableRefs)
                        await $_getPrefetchedData<
                          Pokemon,
                          $PokemonTableTable,
                          PokemonAbility
                        >(
                          currentTable: table,
                          referencedTable: $$PokemonTableTableReferences
                              ._pokemonAbilitiesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PokemonTableTableReferences(
                                db,
                                table,
                                p0,
                              ).pokemonAbilitiesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pokemonId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PokemonTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokemonTableTable,
      Pokemon,
      $$PokemonTableTableFilterComposer,
      $$PokemonTableTableOrderingComposer,
      $$PokemonTableTableAnnotationComposer,
      $$PokemonTableTableCreateCompanionBuilder,
      $$PokemonTableTableUpdateCompanionBuilder,
      (Pokemon, $$PokemonTableTableReferences),
      Pokemon,
      PrefetchHooks Function({
        bool pokemonMovesTableRefs,
        bool pokemonAbilitiesTableRefs,
      })
    >;
typedef $$MoveTableTableCreateCompanionBuilder =
    MoveTableCompanion Function({
      Value<int> id,
      required String name,
      required String type,
      Value<int?> power,
      Value<int?> accuracy,
      required int pp,
      required String damageClass,
      Value<String?> description,
      Value<int> priority,
      Value<bool> isContact,
      Value<bool> isHealing,
      Value<bool> isSound,
      Value<bool> isPunching,
      Value<bool> isBiting,
      Value<bool> isPowder,
      Value<bool> isPulse,
      Value<bool> isBallistic,
      Value<bool> isSlicing,
      Value<bool> isWind,
      Value<bool> isDance,
      Value<bool> isBite,
      Value<bool> isMultiHit,
      Value<bool> isProtective,
      Value<bool> isSwitching,
      Value<bool> isRecharge,
      Value<bool> isRecoil,
      Value<bool> isDraining,
      Value<bool> isStatusMove,
      Value<bool> isDamagingMove,
      Value<bool> isSignatureMove,
      Value<bool> isDLCMove,
      Value<bool> isChampionsMove,
      Value<bool> isLegendsZAMove,
      Value<int> generation,
      Value<String?> introducedIn,
    });
typedef $$MoveTableTableUpdateCompanionBuilder =
    MoveTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> type,
      Value<int?> power,
      Value<int?> accuracy,
      Value<int> pp,
      Value<String> damageClass,
      Value<String?> description,
      Value<int> priority,
      Value<bool> isContact,
      Value<bool> isHealing,
      Value<bool> isSound,
      Value<bool> isPunching,
      Value<bool> isBiting,
      Value<bool> isPowder,
      Value<bool> isPulse,
      Value<bool> isBallistic,
      Value<bool> isSlicing,
      Value<bool> isWind,
      Value<bool> isDance,
      Value<bool> isBite,
      Value<bool> isMultiHit,
      Value<bool> isProtective,
      Value<bool> isSwitching,
      Value<bool> isRecharge,
      Value<bool> isRecoil,
      Value<bool> isDraining,
      Value<bool> isStatusMove,
      Value<bool> isDamagingMove,
      Value<bool> isSignatureMove,
      Value<bool> isDLCMove,
      Value<bool> isChampionsMove,
      Value<bool> isLegendsZAMove,
      Value<int> generation,
      Value<String?> introducedIn,
    });

final class $$MoveTableTableReferences
    extends BaseReferences<_$AppDatabase, $MoveTableTable, Move> {
  $$MoveTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PokemonMovesTableTable, List<PokemonMove>>
  _pokemonMovesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pokemonMovesTable,
        aliasName: $_aliasNameGenerator(
          db.moveTable.id,
          db.pokemonMovesTable.moveId,
        ),
      );

  $$PokemonMovesTableTableProcessedTableManager get pokemonMovesTableRefs {
    final manager = $$PokemonMovesTableTableTableManager(
      $_db,
      $_db.pokemonMovesTable,
    ).filter((f) => f.moveId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pokemonMovesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MoveTableTableFilterComposer
    extends Composer<_$AppDatabase, $MoveTableTable> {
  $$MoveTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get power => $composableBuilder(
    column: $table.power,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pp => $composableBuilder(
    column: $table.pp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get damageClass => $composableBuilder(
    column: $table.damageClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isContact => $composableBuilder(
    column: $table.isContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHealing => $composableBuilder(
    column: $table.isHealing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSound => $composableBuilder(
    column: $table.isSound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPunching => $composableBuilder(
    column: $table.isPunching,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBiting => $composableBuilder(
    column: $table.isBiting,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPowder => $composableBuilder(
    column: $table.isPowder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPulse => $composableBuilder(
    column: $table.isPulse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBallistic => $composableBuilder(
    column: $table.isBallistic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSlicing => $composableBuilder(
    column: $table.isSlicing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWind => $composableBuilder(
    column: $table.isWind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDance => $composableBuilder(
    column: $table.isDance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBite => $composableBuilder(
    column: $table.isBite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMultiHit => $composableBuilder(
    column: $table.isMultiHit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isProtective => $composableBuilder(
    column: $table.isProtective,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSwitching => $composableBuilder(
    column: $table.isSwitching,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecharge => $composableBuilder(
    column: $table.isRecharge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecoil => $composableBuilder(
    column: $table.isRecoil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDraining => $composableBuilder(
    column: $table.isDraining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStatusMove => $composableBuilder(
    column: $table.isStatusMove,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDamagingMove => $composableBuilder(
    column: $table.isDamagingMove,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSignatureMove => $composableBuilder(
    column: $table.isSignatureMove,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDLCMove => $composableBuilder(
    column: $table.isDLCMove,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isChampionsMove => $composableBuilder(
    column: $table.isChampionsMove,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLegendsZAMove => $composableBuilder(
    column: $table.isLegendsZAMove,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get introducedIn => $composableBuilder(
    column: $table.introducedIn,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pokemonMovesTableRefs(
    Expression<bool> Function($$PokemonMovesTableTableFilterComposer f) f,
  ) {
    final $$PokemonMovesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pokemonMovesTable,
      getReferencedColumn: (t) => t.moveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonMovesTableTableFilterComposer(
            $db: $db,
            $table: $db.pokemonMovesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MoveTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MoveTableTable> {
  $$MoveTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get power => $composableBuilder(
    column: $table.power,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pp => $composableBuilder(
    column: $table.pp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get damageClass => $composableBuilder(
    column: $table.damageClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isContact => $composableBuilder(
    column: $table.isContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHealing => $composableBuilder(
    column: $table.isHealing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSound => $composableBuilder(
    column: $table.isSound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPunching => $composableBuilder(
    column: $table.isPunching,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBiting => $composableBuilder(
    column: $table.isBiting,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPowder => $composableBuilder(
    column: $table.isPowder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPulse => $composableBuilder(
    column: $table.isPulse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBallistic => $composableBuilder(
    column: $table.isBallistic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSlicing => $composableBuilder(
    column: $table.isSlicing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWind => $composableBuilder(
    column: $table.isWind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDance => $composableBuilder(
    column: $table.isDance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBite => $composableBuilder(
    column: $table.isBite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMultiHit => $composableBuilder(
    column: $table.isMultiHit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isProtective => $composableBuilder(
    column: $table.isProtective,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSwitching => $composableBuilder(
    column: $table.isSwitching,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecharge => $composableBuilder(
    column: $table.isRecharge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecoil => $composableBuilder(
    column: $table.isRecoil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDraining => $composableBuilder(
    column: $table.isDraining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStatusMove => $composableBuilder(
    column: $table.isStatusMove,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDamagingMove => $composableBuilder(
    column: $table.isDamagingMove,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSignatureMove => $composableBuilder(
    column: $table.isSignatureMove,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDLCMove => $composableBuilder(
    column: $table.isDLCMove,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isChampionsMove => $composableBuilder(
    column: $table.isChampionsMove,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLegendsZAMove => $composableBuilder(
    column: $table.isLegendsZAMove,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get introducedIn => $composableBuilder(
    column: $table.introducedIn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoveTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoveTableTable> {
  $$MoveTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get power =>
      $composableBuilder(column: $table.power, builder: (column) => column);

  GeneratedColumn<int> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<int> get pp =>
      $composableBuilder(column: $table.pp, builder: (column) => column);

  GeneratedColumn<String> get damageClass => $composableBuilder(
    column: $table.damageClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get isContact =>
      $composableBuilder(column: $table.isContact, builder: (column) => column);

  GeneratedColumn<bool> get isHealing =>
      $composableBuilder(column: $table.isHealing, builder: (column) => column);

  GeneratedColumn<bool> get isSound =>
      $composableBuilder(column: $table.isSound, builder: (column) => column);

  GeneratedColumn<bool> get isPunching => $composableBuilder(
    column: $table.isPunching,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBiting =>
      $composableBuilder(column: $table.isBiting, builder: (column) => column);

  GeneratedColumn<bool> get isPowder =>
      $composableBuilder(column: $table.isPowder, builder: (column) => column);

  GeneratedColumn<bool> get isPulse =>
      $composableBuilder(column: $table.isPulse, builder: (column) => column);

  GeneratedColumn<bool> get isBallistic => $composableBuilder(
    column: $table.isBallistic,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSlicing =>
      $composableBuilder(column: $table.isSlicing, builder: (column) => column);

  GeneratedColumn<bool> get isWind =>
      $composableBuilder(column: $table.isWind, builder: (column) => column);

  GeneratedColumn<bool> get isDance =>
      $composableBuilder(column: $table.isDance, builder: (column) => column);

  GeneratedColumn<bool> get isBite =>
      $composableBuilder(column: $table.isBite, builder: (column) => column);

  GeneratedColumn<bool> get isMultiHit => $composableBuilder(
    column: $table.isMultiHit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isProtective => $composableBuilder(
    column: $table.isProtective,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSwitching => $composableBuilder(
    column: $table.isSwitching,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRecharge => $composableBuilder(
    column: $table.isRecharge,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRecoil =>
      $composableBuilder(column: $table.isRecoil, builder: (column) => column);

  GeneratedColumn<bool> get isDraining => $composableBuilder(
    column: $table.isDraining,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isStatusMove => $composableBuilder(
    column: $table.isStatusMove,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDamagingMove => $composableBuilder(
    column: $table.isDamagingMove,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSignatureMove => $composableBuilder(
    column: $table.isSignatureMove,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDLCMove =>
      $composableBuilder(column: $table.isDLCMove, builder: (column) => column);

  GeneratedColumn<bool> get isChampionsMove => $composableBuilder(
    column: $table.isChampionsMove,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLegendsZAMove => $composableBuilder(
    column: $table.isLegendsZAMove,
    builder: (column) => column,
  );

  GeneratedColumn<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get introducedIn => $composableBuilder(
    column: $table.introducedIn,
    builder: (column) => column,
  );

  Expression<T> pokemonMovesTableRefs<T extends Object>(
    Expression<T> Function($$PokemonMovesTableTableAnnotationComposer a) f,
  ) {
    final $$PokemonMovesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pokemonMovesTable,
          getReferencedColumn: (t) => t.moveId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PokemonMovesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pokemonMovesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MoveTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoveTableTable,
          Move,
          $$MoveTableTableFilterComposer,
          $$MoveTableTableOrderingComposer,
          $$MoveTableTableAnnotationComposer,
          $$MoveTableTableCreateCompanionBuilder,
          $$MoveTableTableUpdateCompanionBuilder,
          (Move, $$MoveTableTableReferences),
          Move,
          PrefetchHooks Function({bool pokemonMovesTableRefs})
        > {
  $$MoveTableTableTableManager(_$AppDatabase db, $MoveTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoveTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoveTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoveTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> power = const Value.absent(),
                Value<int?> accuracy = const Value.absent(),
                Value<int> pp = const Value.absent(),
                Value<String> damageClass = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> isContact = const Value.absent(),
                Value<bool> isHealing = const Value.absent(),
                Value<bool> isSound = const Value.absent(),
                Value<bool> isPunching = const Value.absent(),
                Value<bool> isBiting = const Value.absent(),
                Value<bool> isPowder = const Value.absent(),
                Value<bool> isPulse = const Value.absent(),
                Value<bool> isBallistic = const Value.absent(),
                Value<bool> isSlicing = const Value.absent(),
                Value<bool> isWind = const Value.absent(),
                Value<bool> isDance = const Value.absent(),
                Value<bool> isBite = const Value.absent(),
                Value<bool> isMultiHit = const Value.absent(),
                Value<bool> isProtective = const Value.absent(),
                Value<bool> isSwitching = const Value.absent(),
                Value<bool> isRecharge = const Value.absent(),
                Value<bool> isRecoil = const Value.absent(),
                Value<bool> isDraining = const Value.absent(),
                Value<bool> isStatusMove = const Value.absent(),
                Value<bool> isDamagingMove = const Value.absent(),
                Value<bool> isSignatureMove = const Value.absent(),
                Value<bool> isDLCMove = const Value.absent(),
                Value<bool> isChampionsMove = const Value.absent(),
                Value<bool> isLegendsZAMove = const Value.absent(),
                Value<int> generation = const Value.absent(),
                Value<String?> introducedIn = const Value.absent(),
              }) => MoveTableCompanion(
                id: id,
                name: name,
                type: type,
                power: power,
                accuracy: accuracy,
                pp: pp,
                damageClass: damageClass,
                description: description,
                priority: priority,
                isContact: isContact,
                isHealing: isHealing,
                isSound: isSound,
                isPunching: isPunching,
                isBiting: isBiting,
                isPowder: isPowder,
                isPulse: isPulse,
                isBallistic: isBallistic,
                isSlicing: isSlicing,
                isWind: isWind,
                isDance: isDance,
                isBite: isBite,
                isMultiHit: isMultiHit,
                isProtective: isProtective,
                isSwitching: isSwitching,
                isRecharge: isRecharge,
                isRecoil: isRecoil,
                isDraining: isDraining,
                isStatusMove: isStatusMove,
                isDamagingMove: isDamagingMove,
                isSignatureMove: isSignatureMove,
                isDLCMove: isDLCMove,
                isChampionsMove: isChampionsMove,
                isLegendsZAMove: isLegendsZAMove,
                generation: generation,
                introducedIn: introducedIn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                Value<int?> power = const Value.absent(),
                Value<int?> accuracy = const Value.absent(),
                required int pp,
                required String damageClass,
                Value<String?> description = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> isContact = const Value.absent(),
                Value<bool> isHealing = const Value.absent(),
                Value<bool> isSound = const Value.absent(),
                Value<bool> isPunching = const Value.absent(),
                Value<bool> isBiting = const Value.absent(),
                Value<bool> isPowder = const Value.absent(),
                Value<bool> isPulse = const Value.absent(),
                Value<bool> isBallistic = const Value.absent(),
                Value<bool> isSlicing = const Value.absent(),
                Value<bool> isWind = const Value.absent(),
                Value<bool> isDance = const Value.absent(),
                Value<bool> isBite = const Value.absent(),
                Value<bool> isMultiHit = const Value.absent(),
                Value<bool> isProtective = const Value.absent(),
                Value<bool> isSwitching = const Value.absent(),
                Value<bool> isRecharge = const Value.absent(),
                Value<bool> isRecoil = const Value.absent(),
                Value<bool> isDraining = const Value.absent(),
                Value<bool> isStatusMove = const Value.absent(),
                Value<bool> isDamagingMove = const Value.absent(),
                Value<bool> isSignatureMove = const Value.absent(),
                Value<bool> isDLCMove = const Value.absent(),
                Value<bool> isChampionsMove = const Value.absent(),
                Value<bool> isLegendsZAMove = const Value.absent(),
                Value<int> generation = const Value.absent(),
                Value<String?> introducedIn = const Value.absent(),
              }) => MoveTableCompanion.insert(
                id: id,
                name: name,
                type: type,
                power: power,
                accuracy: accuracy,
                pp: pp,
                damageClass: damageClass,
                description: description,
                priority: priority,
                isContact: isContact,
                isHealing: isHealing,
                isSound: isSound,
                isPunching: isPunching,
                isBiting: isBiting,
                isPowder: isPowder,
                isPulse: isPulse,
                isBallistic: isBallistic,
                isSlicing: isSlicing,
                isWind: isWind,
                isDance: isDance,
                isBite: isBite,
                isMultiHit: isMultiHit,
                isProtective: isProtective,
                isSwitching: isSwitching,
                isRecharge: isRecharge,
                isRecoil: isRecoil,
                isDraining: isDraining,
                isStatusMove: isStatusMove,
                isDamagingMove: isDamagingMove,
                isSignatureMove: isSignatureMove,
                isDLCMove: isDLCMove,
                isChampionsMove: isChampionsMove,
                isLegendsZAMove: isLegendsZAMove,
                generation: generation,
                introducedIn: introducedIn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MoveTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pokemonMovesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (pokemonMovesTableRefs) db.pokemonMovesTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pokemonMovesTableRefs)
                    await $_getPrefetchedData<
                      Move,
                      $MoveTableTable,
                      PokemonMove
                    >(
                      currentTable: table,
                      referencedTable: $$MoveTableTableReferences
                          ._pokemonMovesTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MoveTableTableReferences(
                            db,
                            table,
                            p0,
                          ).pokemonMovesTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.moveId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MoveTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoveTableTable,
      Move,
      $$MoveTableTableFilterComposer,
      $$MoveTableTableOrderingComposer,
      $$MoveTableTableAnnotationComposer,
      $$MoveTableTableCreateCompanionBuilder,
      $$MoveTableTableUpdateCompanionBuilder,
      (Move, $$MoveTableTableReferences),
      Move,
      PrefetchHooks Function({bool pokemonMovesTableRefs})
    >;
typedef $$AbilityTableTableCreateCompanionBuilder =
    AbilityTableCompanion Function({
      Value<int> id,
      required String name,
      required String description,
      Value<int> generation,
      Value<bool> isHiddenAbility,
      Value<bool> isChampionsAbility,
      Value<bool> isLegendsZAAbility,
      Value<String?> introducedIn,
      Value<String?> sourceGames,
      Value<String?> effectTags,
      Value<String?> battleEffectTags,
      Value<String?> pokemonTypes,
    });
typedef $$AbilityTableTableUpdateCompanionBuilder =
    AbilityTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> description,
      Value<int> generation,
      Value<bool> isHiddenAbility,
      Value<bool> isChampionsAbility,
      Value<bool> isLegendsZAAbility,
      Value<String?> introducedIn,
      Value<String?> sourceGames,
      Value<String?> effectTags,
      Value<String?> battleEffectTags,
      Value<String?> pokemonTypes,
    });

final class $$AbilityTableTableReferences
    extends BaseReferences<_$AppDatabase, $AbilityTableTable, Ability> {
  $$AbilityTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PokemonAbilitiesTableTable, List<PokemonAbility>>
  _pokemonAbilitiesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pokemonAbilitiesTable,
        aliasName: $_aliasNameGenerator(
          db.abilityTable.id,
          db.pokemonAbilitiesTable.abilityId,
        ),
      );

  $$PokemonAbilitiesTableTableProcessedTableManager
  get pokemonAbilitiesTableRefs {
    final manager = $$PokemonAbilitiesTableTableTableManager(
      $_db,
      $_db.pokemonAbilitiesTable,
    ).filter((f) => f.abilityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pokemonAbilitiesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AbilityTableTableFilterComposer
    extends Composer<_$AppDatabase, $AbilityTableTable> {
  $$AbilityTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHiddenAbility => $composableBuilder(
    column: $table.isHiddenAbility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isChampionsAbility => $composableBuilder(
    column: $table.isChampionsAbility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLegendsZAAbility => $composableBuilder(
    column: $table.isLegendsZAAbility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get introducedIn => $composableBuilder(
    column: $table.introducedIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceGames => $composableBuilder(
    column: $table.sourceGames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectTags => $composableBuilder(
    column: $table.effectTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get battleEffectTags => $composableBuilder(
    column: $table.battleEffectTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pokemonTypes => $composableBuilder(
    column: $table.pokemonTypes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pokemonAbilitiesTableRefs(
    Expression<bool> Function($$PokemonAbilitiesTableTableFilterComposer f) f,
  ) {
    final $$PokemonAbilitiesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pokemonAbilitiesTable,
          getReferencedColumn: (t) => t.abilityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PokemonAbilitiesTableTableFilterComposer(
                $db: $db,
                $table: $db.pokemonAbilitiesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AbilityTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AbilityTableTable> {
  $$AbilityTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHiddenAbility => $composableBuilder(
    column: $table.isHiddenAbility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isChampionsAbility => $composableBuilder(
    column: $table.isChampionsAbility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLegendsZAAbility => $composableBuilder(
    column: $table.isLegendsZAAbility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get introducedIn => $composableBuilder(
    column: $table.introducedIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceGames => $composableBuilder(
    column: $table.sourceGames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectTags => $composableBuilder(
    column: $table.effectTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get battleEffectTags => $composableBuilder(
    column: $table.battleEffectTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pokemonTypes => $composableBuilder(
    column: $table.pokemonTypes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AbilityTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AbilityTableTable> {
  $$AbilityTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isHiddenAbility => $composableBuilder(
    column: $table.isHiddenAbility,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isChampionsAbility => $composableBuilder(
    column: $table.isChampionsAbility,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLegendsZAAbility => $composableBuilder(
    column: $table.isLegendsZAAbility,
    builder: (column) => column,
  );

  GeneratedColumn<String> get introducedIn => $composableBuilder(
    column: $table.introducedIn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceGames => $composableBuilder(
    column: $table.sourceGames,
    builder: (column) => column,
  );

  GeneratedColumn<String> get effectTags => $composableBuilder(
    column: $table.effectTags,
    builder: (column) => column,
  );

  GeneratedColumn<String> get battleEffectTags => $composableBuilder(
    column: $table.battleEffectTags,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pokemonTypes => $composableBuilder(
    column: $table.pokemonTypes,
    builder: (column) => column,
  );

  Expression<T> pokemonAbilitiesTableRefs<T extends Object>(
    Expression<T> Function($$PokemonAbilitiesTableTableAnnotationComposer a) f,
  ) {
    final $$PokemonAbilitiesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pokemonAbilitiesTable,
          getReferencedColumn: (t) => t.abilityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PokemonAbilitiesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pokemonAbilitiesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AbilityTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AbilityTableTable,
          Ability,
          $$AbilityTableTableFilterComposer,
          $$AbilityTableTableOrderingComposer,
          $$AbilityTableTableAnnotationComposer,
          $$AbilityTableTableCreateCompanionBuilder,
          $$AbilityTableTableUpdateCompanionBuilder,
          (Ability, $$AbilityTableTableReferences),
          Ability,
          PrefetchHooks Function({bool pokemonAbilitiesTableRefs})
        > {
  $$AbilityTableTableTableManager(_$AppDatabase db, $AbilityTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AbilityTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AbilityTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AbilityTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> generation = const Value.absent(),
                Value<bool> isHiddenAbility = const Value.absent(),
                Value<bool> isChampionsAbility = const Value.absent(),
                Value<bool> isLegendsZAAbility = const Value.absent(),
                Value<String?> introducedIn = const Value.absent(),
                Value<String?> sourceGames = const Value.absent(),
                Value<String?> effectTags = const Value.absent(),
                Value<String?> battleEffectTags = const Value.absent(),
                Value<String?> pokemonTypes = const Value.absent(),
              }) => AbilityTableCompanion(
                id: id,
                name: name,
                description: description,
                generation: generation,
                isHiddenAbility: isHiddenAbility,
                isChampionsAbility: isChampionsAbility,
                isLegendsZAAbility: isLegendsZAAbility,
                introducedIn: introducedIn,
                sourceGames: sourceGames,
                effectTags: effectTags,
                battleEffectTags: battleEffectTags,
                pokemonTypes: pokemonTypes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String description,
                Value<int> generation = const Value.absent(),
                Value<bool> isHiddenAbility = const Value.absent(),
                Value<bool> isChampionsAbility = const Value.absent(),
                Value<bool> isLegendsZAAbility = const Value.absent(),
                Value<String?> introducedIn = const Value.absent(),
                Value<String?> sourceGames = const Value.absent(),
                Value<String?> effectTags = const Value.absent(),
                Value<String?> battleEffectTags = const Value.absent(),
                Value<String?> pokemonTypes = const Value.absent(),
              }) => AbilityTableCompanion.insert(
                id: id,
                name: name,
                description: description,
                generation: generation,
                isHiddenAbility: isHiddenAbility,
                isChampionsAbility: isChampionsAbility,
                isLegendsZAAbility: isLegendsZAAbility,
                introducedIn: introducedIn,
                sourceGames: sourceGames,
                effectTags: effectTags,
                battleEffectTags: battleEffectTags,
                pokemonTypes: pokemonTypes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AbilityTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pokemonAbilitiesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (pokemonAbilitiesTableRefs) db.pokemonAbilitiesTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pokemonAbilitiesTableRefs)
                    await $_getPrefetchedData<
                      Ability,
                      $AbilityTableTable,
                      PokemonAbility
                    >(
                      currentTable: table,
                      referencedTable: $$AbilityTableTableReferences
                          ._pokemonAbilitiesTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AbilityTableTableReferences(
                            db,
                            table,
                            p0,
                          ).pokemonAbilitiesTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.abilityId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AbilityTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AbilityTableTable,
      Ability,
      $$AbilityTableTableFilterComposer,
      $$AbilityTableTableOrderingComposer,
      $$AbilityTableTableAnnotationComposer,
      $$AbilityTableTableCreateCompanionBuilder,
      $$AbilityTableTableUpdateCompanionBuilder,
      (Ability, $$AbilityTableTableReferences),
      Ability,
      PrefetchHooks Function({bool pokemonAbilitiesTableRefs})
    >;
typedef $$PokemonMovesTableTableCreateCompanionBuilder =
    PokemonMovesTableCompanion Function({
      required int pokemonId,
      required int moveId,
      required String learnMethod,
      Value<int?> levelLearned,
      Value<int> rowid,
    });
typedef $$PokemonMovesTableTableUpdateCompanionBuilder =
    PokemonMovesTableCompanion Function({
      Value<int> pokemonId,
      Value<int> moveId,
      Value<String> learnMethod,
      Value<int?> levelLearned,
      Value<int> rowid,
    });

final class $$PokemonMovesTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $PokemonMovesTableTable, PokemonMove> {
  $$PokemonMovesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PokemonTableTable _pokemonIdTable(_$AppDatabase db) =>
      db.pokemonTable.createAlias(
        $_aliasNameGenerator(
          db.pokemonMovesTable.pokemonId,
          db.pokemonTable.id,
        ),
      );

  $$PokemonTableTableProcessedTableManager get pokemonId {
    final $_column = $_itemColumn<int>('pokemon_id')!;

    final manager = $$PokemonTableTableTableManager(
      $_db,
      $_db.pokemonTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pokemonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MoveTableTable _moveIdTable(_$AppDatabase db) =>
      db.moveTable.createAlias(
        $_aliasNameGenerator(db.pokemonMovesTable.moveId, db.moveTable.id),
      );

  $$MoveTableTableProcessedTableManager get moveId {
    final $_column = $_itemColumn<int>('move_id')!;

    final manager = $$MoveTableTableTableManager(
      $_db,
      $_db.moveTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_moveIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PokemonMovesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonMovesTableTable> {
  $$PokemonMovesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get learnMethod => $composableBuilder(
    column: $table.learnMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get levelLearned => $composableBuilder(
    column: $table.levelLearned,
    builder: (column) => ColumnFilters(column),
  );

  $$PokemonTableTableFilterComposer get pokemonId {
    final $$PokemonTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableFilterComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoveTableTableFilterComposer get moveId {
    final $$MoveTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moveId,
      referencedTable: $db.moveTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoveTableTableFilterComposer(
            $db: $db,
            $table: $db.moveTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonMovesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonMovesTableTable> {
  $$PokemonMovesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get learnMethod => $composableBuilder(
    column: $table.learnMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get levelLearned => $composableBuilder(
    column: $table.levelLearned,
    builder: (column) => ColumnOrderings(column),
  );

  $$PokemonTableTableOrderingComposer get pokemonId {
    final $$PokemonTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableOrderingComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoveTableTableOrderingComposer get moveId {
    final $$MoveTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moveId,
      referencedTable: $db.moveTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoveTableTableOrderingComposer(
            $db: $db,
            $table: $db.moveTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonMovesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonMovesTableTable> {
  $$PokemonMovesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get learnMethod => $composableBuilder(
    column: $table.learnMethod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get levelLearned => $composableBuilder(
    column: $table.levelLearned,
    builder: (column) => column,
  );

  $$PokemonTableTableAnnotationComposer get pokemonId {
    final $$PokemonTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableAnnotationComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoveTableTableAnnotationComposer get moveId {
    final $$MoveTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moveId,
      referencedTable: $db.moveTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoveTableTableAnnotationComposer(
            $db: $db,
            $table: $db.moveTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonMovesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokemonMovesTableTable,
          PokemonMove,
          $$PokemonMovesTableTableFilterComposer,
          $$PokemonMovesTableTableOrderingComposer,
          $$PokemonMovesTableTableAnnotationComposer,
          $$PokemonMovesTableTableCreateCompanionBuilder,
          $$PokemonMovesTableTableUpdateCompanionBuilder,
          (PokemonMove, $$PokemonMovesTableTableReferences),
          PokemonMove,
          PrefetchHooks Function({bool pokemonId, bool moveId})
        > {
  $$PokemonMovesTableTableTableManager(
    _$AppDatabase db,
    $PokemonMovesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonMovesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PokemonMovesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PokemonMovesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> pokemonId = const Value.absent(),
                Value<int> moveId = const Value.absent(),
                Value<String> learnMethod = const Value.absent(),
                Value<int?> levelLearned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PokemonMovesTableCompanion(
                pokemonId: pokemonId,
                moveId: moveId,
                learnMethod: learnMethod,
                levelLearned: levelLearned,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int pokemonId,
                required int moveId,
                required String learnMethod,
                Value<int?> levelLearned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PokemonMovesTableCompanion.insert(
                pokemonId: pokemonId,
                moveId: moveId,
                learnMethod: learnMethod,
                levelLearned: levelLearned,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PokemonMovesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pokemonId = false, moveId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pokemonId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pokemonId,
                                referencedTable:
                                    $$PokemonMovesTableTableReferences
                                        ._pokemonIdTable(db),
                                referencedColumn:
                                    $$PokemonMovesTableTableReferences
                                        ._pokemonIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (moveId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.moveId,
                                referencedTable:
                                    $$PokemonMovesTableTableReferences
                                        ._moveIdTable(db),
                                referencedColumn:
                                    $$PokemonMovesTableTableReferences
                                        ._moveIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PokemonMovesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokemonMovesTableTable,
      PokemonMove,
      $$PokemonMovesTableTableFilterComposer,
      $$PokemonMovesTableTableOrderingComposer,
      $$PokemonMovesTableTableAnnotationComposer,
      $$PokemonMovesTableTableCreateCompanionBuilder,
      $$PokemonMovesTableTableUpdateCompanionBuilder,
      (PokemonMove, $$PokemonMovesTableTableReferences),
      PokemonMove,
      PrefetchHooks Function({bool pokemonId, bool moveId})
    >;
typedef $$PokemonAbilitiesTableTableCreateCompanionBuilder =
    PokemonAbilitiesTableCompanion Function({
      required int pokemonId,
      required int abilityId,
      required bool isHidden,
      Value<int> rowid,
    });
typedef $$PokemonAbilitiesTableTableUpdateCompanionBuilder =
    PokemonAbilitiesTableCompanion Function({
      Value<int> pokemonId,
      Value<int> abilityId,
      Value<bool> isHidden,
      Value<int> rowid,
    });

final class $$PokemonAbilitiesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PokemonAbilitiesTableTable,
          PokemonAbility
        > {
  $$PokemonAbilitiesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PokemonTableTable _pokemonIdTable(_$AppDatabase db) =>
      db.pokemonTable.createAlias(
        $_aliasNameGenerator(
          db.pokemonAbilitiesTable.pokemonId,
          db.pokemonTable.id,
        ),
      );

  $$PokemonTableTableProcessedTableManager get pokemonId {
    final $_column = $_itemColumn<int>('pokemon_id')!;

    final manager = $$PokemonTableTableTableManager(
      $_db,
      $_db.pokemonTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pokemonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AbilityTableTable _abilityIdTable(_$AppDatabase db) =>
      db.abilityTable.createAlias(
        $_aliasNameGenerator(
          db.pokemonAbilitiesTable.abilityId,
          db.abilityTable.id,
        ),
      );

  $$AbilityTableTableProcessedTableManager get abilityId {
    final $_column = $_itemColumn<int>('ability_id')!;

    final manager = $$AbilityTableTableTableManager(
      $_db,
      $_db.abilityTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_abilityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PokemonAbilitiesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonAbilitiesTableTable> {
  $$PokemonAbilitiesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  $$PokemonTableTableFilterComposer get pokemonId {
    final $$PokemonTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableFilterComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AbilityTableTableFilterComposer get abilityId {
    final $$AbilityTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.abilityId,
      referencedTable: $db.abilityTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AbilityTableTableFilterComposer(
            $db: $db,
            $table: $db.abilityTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonAbilitiesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonAbilitiesTableTable> {
  $$PokemonAbilitiesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  $$PokemonTableTableOrderingComposer get pokemonId {
    final $$PokemonTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableOrderingComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AbilityTableTableOrderingComposer get abilityId {
    final $$AbilityTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.abilityId,
      referencedTable: $db.abilityTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AbilityTableTableOrderingComposer(
            $db: $db,
            $table: $db.abilityTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonAbilitiesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonAbilitiesTableTable> {
  $$PokemonAbilitiesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  $$PokemonTableTableAnnotationComposer get pokemonId {
    final $$PokemonTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pokemonId,
      referencedTable: $db.pokemonTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PokemonTableTableAnnotationComposer(
            $db: $db,
            $table: $db.pokemonTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AbilityTableTableAnnotationComposer get abilityId {
    final $$AbilityTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.abilityId,
      referencedTable: $db.abilityTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AbilityTableTableAnnotationComposer(
            $db: $db,
            $table: $db.abilityTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PokemonAbilitiesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokemonAbilitiesTableTable,
          PokemonAbility,
          $$PokemonAbilitiesTableTableFilterComposer,
          $$PokemonAbilitiesTableTableOrderingComposer,
          $$PokemonAbilitiesTableTableAnnotationComposer,
          $$PokemonAbilitiesTableTableCreateCompanionBuilder,
          $$PokemonAbilitiesTableTableUpdateCompanionBuilder,
          (PokemonAbility, $$PokemonAbilitiesTableTableReferences),
          PokemonAbility,
          PrefetchHooks Function({bool pokemonId, bool abilityId})
        > {
  $$PokemonAbilitiesTableTableTableManager(
    _$AppDatabase db,
    $PokemonAbilitiesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonAbilitiesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PokemonAbilitiesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PokemonAbilitiesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> pokemonId = const Value.absent(),
                Value<int> abilityId = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PokemonAbilitiesTableCompanion(
                pokemonId: pokemonId,
                abilityId: abilityId,
                isHidden: isHidden,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int pokemonId,
                required int abilityId,
                required bool isHidden,
                Value<int> rowid = const Value.absent(),
              }) => PokemonAbilitiesTableCompanion.insert(
                pokemonId: pokemonId,
                abilityId: abilityId,
                isHidden: isHidden,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PokemonAbilitiesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pokemonId = false, abilityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pokemonId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pokemonId,
                                referencedTable:
                                    $$PokemonAbilitiesTableTableReferences
                                        ._pokemonIdTable(db),
                                referencedColumn:
                                    $$PokemonAbilitiesTableTableReferences
                                        ._pokemonIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (abilityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.abilityId,
                                referencedTable:
                                    $$PokemonAbilitiesTableTableReferences
                                        ._abilityIdTable(db),
                                referencedColumn:
                                    $$PokemonAbilitiesTableTableReferences
                                        ._abilityIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PokemonAbilitiesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokemonAbilitiesTableTable,
      PokemonAbility,
      $$PokemonAbilitiesTableTableFilterComposer,
      $$PokemonAbilitiesTableTableOrderingComposer,
      $$PokemonAbilitiesTableTableAnnotationComposer,
      $$PokemonAbilitiesTableTableCreateCompanionBuilder,
      $$PokemonAbilitiesTableTableUpdateCompanionBuilder,
      (PokemonAbility, $$PokemonAbilitiesTableTableReferences),
      PokemonAbility,
      PrefetchHooks Function({bool pokemonId, bool abilityId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PokemonTableTableTableManager get pokemonTable =>
      $$PokemonTableTableTableManager(_db, _db.pokemonTable);
  $$MoveTableTableTableManager get moveTable =>
      $$MoveTableTableTableManager(_db, _db.moveTable);
  $$AbilityTableTableTableManager get abilityTable =>
      $$AbilityTableTableTableManager(_db, _db.abilityTable);
  $$PokemonMovesTableTableTableManager get pokemonMovesTable =>
      $$PokemonMovesTableTableTableManager(_db, _db.pokemonMovesTable);
  $$PokemonAbilitiesTableTableTableManager get pokemonAbilitiesTable =>
      $$PokemonAbilitiesTableTableTableManager(_db, _db.pokemonAbilitiesTable);
}
