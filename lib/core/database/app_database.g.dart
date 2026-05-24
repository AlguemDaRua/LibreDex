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
          ..write('shinySpriteUrl: $shinySpriteUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
  );
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
          other.shinySpriteUrl == this.shinySpriteUrl);
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
          ..write('shinySpriteUrl: $shinySpriteUrl')
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    power,
    accuracy,
    pp,
    damageClass,
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
  const Move({
    required this.id,
    required this.name,
    required this.type,
    this.power,
    this.accuracy,
    required this.pp,
    required this.damageClass,
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
  }) => Move(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    power: power.present ? power.value : this.power,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
    pp: pp ?? this.pp,
    damageClass: damageClass ?? this.damageClass,
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
          ..write('damageClass: $damageClass')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, power, accuracy, pp, damageClass);
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
          other.damageClass == this.damageClass);
}

class MoveTableCompanion extends UpdateCompanion<Move> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<int?> power;
  final Value<int?> accuracy;
  final Value<int> pp;
  final Value<String> damageClass;
  const MoveTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.power = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.pp = const Value.absent(),
    this.damageClass = const Value.absent(),
  });
  MoveTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    this.power = const Value.absent(),
    this.accuracy = const Value.absent(),
    required int pp,
    required String damageClass,
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
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (power != null) 'power': power,
      if (accuracy != null) 'accuracy': accuracy,
      if (pp != null) 'pp': pp,
      if (damageClass != null) 'damage_class': damageClass,
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
  }) {
    return MoveTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      power: power ?? this.power,
      accuracy: accuracy ?? this.accuracy,
      pp: pp ?? this.pp,
      damageClass: damageClass ?? this.damageClass,
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
          ..write('damageClass: $damageClass')
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
  @override
  List<GeneratedColumn> get $columns => [id, name, description];
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
  const Ability({
    required this.id,
    required this.name,
    required this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    return map;
  }

  AbilityTableCompanion toCompanion(bool nullToAbsent) {
    return AbilityTableCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
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
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
    };
  }

  Ability copyWith({int? id, String? name, String? description}) => Ability(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
  );
  Ability copyWithCompanion(AbilityTableCompanion data) {
    return Ability(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ability(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ability &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description);
}

class AbilityTableCompanion extends UpdateCompanion<Ability> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> description;
  const AbilityTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
  });
  AbilityTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String description,
  }) : name = Value(name),
       description = Value(description);
  static Insertable<Ability> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
    });
  }

  AbilityTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? description,
  }) {
    return AbilityTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AbilityTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description')
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
              }) => MoveTableCompanion(
                id: id,
                name: name,
                type: type,
                power: power,
                accuracy: accuracy,
                pp: pp,
                damageClass: damageClass,
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
              }) => MoveTableCompanion.insert(
                id: id,
                name: name,
                type: type,
                power: power,
                accuracy: accuracy,
                pp: pp,
                damageClass: damageClass,
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
    });
typedef $$AbilityTableTableUpdateCompanionBuilder =
    AbilityTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> description,
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
              }) => AbilityTableCompanion(
                id: id,
                name: name,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String description,
              }) => AbilityTableCompanion.insert(
                id: id,
                name: name,
                description: description,
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
