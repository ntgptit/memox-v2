// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(
      StringExpressionOperators(name).trim().length,
    ).isBiggerOrEqualValue(1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentModeMeta = const VerificationMeta(
    'contentMode',
  );
  @override
  late final GeneratedColumn<String> contentMode = GeneratedColumn<String>(
    'content_mode',
    aliasedName,
    false,
    check: () => contentMode.isIn(DatabaseEnumValues.folderContentModes),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    check: () => ComparableExpr(sortOrder).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    parentId,
    name,
    contentMode,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('content_mode')) {
      context.handle(
        _contentModeMeta,
        contentMode.isAcceptableOrUnknown(
          data['content_mode']!,
          _contentModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentModeMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contentMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_mode'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final String id;
  final String? parentId;
  final String name;
  final String contentMode;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;
  const Folder({
    required this.id,
    this.parentId,
    required this.name,
    required this.contentMode,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['name'] = Variable<String>(name);
    map['content_mode'] = Variable<String>(contentMode);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      name: Value(name),
      contentMode: Value(contentMode),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<String>(json['id']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      name: serializer.fromJson<String>(json['name']),
      contentMode: serializer.fromJson<String>(json['contentMode']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'parentId': serializer.toJson<String?>(parentId),
      'name': serializer.toJson<String>(name),
      'contentMode': serializer.toJson<String>(contentMode),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Folder copyWith({
    String? id,
    Value<String?> parentId = const Value.absent(),
    String? name,
    String? contentMode,
    int? sortOrder,
    int? createdAt,
    int? updatedAt,
  }) => Folder(
    id: id ?? this.id,
    parentId: parentId.present ? parentId.value : this.parentId,
    name: name ?? this.name,
    contentMode: contentMode ?? this.contentMode,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      name: data.name.present ? data.name.value : this.name,
      contentMode: data.contentMode.present
          ? data.contentMode.value
          : this.contentMode,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('contentMode: $contentMode, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    parentId,
    name,
    contentMode,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.name == this.name &&
          other.contentMode == this.contentMode &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<String> id;
  final Value<String?> parentId;
  final Value<String> name;
  final Value<String> contentMode;
  final Value<int> sortOrder;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.name = const Value.absent(),
    this.contentMode = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoldersCompanion.insert({
    required String id,
    this.parentId = const Value.absent(),
    required String name,
    required String contentMode,
    required int sortOrder,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       contentMode = Value(contentMode),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Folder> custom({
    Expression<String>? id,
    Expression<String>? parentId,
    Expression<String>? name,
    Expression<String>? contentMode,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (name != null) 'name': name,
      if (contentMode != null) 'content_mode': contentMode,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoldersCompanion copyWith({
    Value<String>? id,
    Value<String?>? parentId,
    Value<String>? name,
    Value<String>? contentMode,
    Value<int>? sortOrder,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      contentMode: contentMode ?? this.contentMode,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contentMode.present) {
      map['content_mode'] = Variable<String>(contentMode.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('contentMode: $contentMode, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecksTable extends Decks with TableInfo<$DecksTable, Deck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(
      StringExpressionOperators(name).trim().length,
    ).isBiggerOrEqualValue(1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    check: () => ComparableExpr(sortOrder).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    folderId,
    name,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Deck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Deck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Deck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DecksTable createAlias(String alias) {
    return $DecksTable(attachedDatabase, alias);
  }
}

class Deck extends DataClass implements Insertable<Deck> {
  final String id;
  final String folderId;
  final String name;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;
  const Deck({
    required this.id,
    required this.folderId,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['folder_id'] = Variable<String>(folderId);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  DecksCompanion toCompanion(bool nullToAbsent) {
    return DecksCompanion(
      id: Value(id),
      folderId: Value(folderId),
      name: Value(name),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Deck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Deck(
      id: serializer.fromJson<String>(json['id']),
      folderId: serializer.fromJson<String>(json['folderId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'folderId': serializer.toJson<String>(folderId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Deck copyWith({
    String? id,
    String? folderId,
    String? name,
    int? sortOrder,
    int? createdAt,
    int? updatedAt,
  }) => Deck(
    id: id ?? this.id,
    folderId: folderId ?? this.folderId,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Deck copyWithCompanion(DecksCompanion data) {
    return Deck(
      id: data.id.present ? data.id.value : this.id,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Deck(')
          ..write('id: $id, ')
          ..write('folderId: $folderId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, folderId, name, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deck &&
          other.id == this.id &&
          other.folderId == this.folderId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DecksCompanion extends UpdateCompanion<Deck> {
  final Value<String> id;
  final Value<String> folderId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const DecksCompanion({
    this.id = const Value.absent(),
    this.folderId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecksCompanion.insert({
    required String id,
    required String folderId,
    required String name,
    required int sortOrder,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       folderId = Value(folderId),
       name = Value(name),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Deck> custom({
    Expression<String>? id,
    Expression<String>? folderId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (folderId != null) 'folder_id': folderId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecksCompanion copyWith({
    Value<String>? id,
    Value<String>? folderId,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return DecksCompanion(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecksCompanion(')
          ..write('id: $id, ')
          ..write('folderId: $folderId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlashcardsTable extends Flashcards
    with TableInfo<$FlashcardsTable, Flashcard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _frontMeta = const VerificationMeta('front');
  @override
  late final GeneratedColumn<String> front = GeneratedColumn<String>(
    'front',
    aliasedName,
    false,
    check: () => ComparableExpr(
      StringExpressionOperators(front).trim().length,
    ).isBiggerOrEqualValue(1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backMeta = const VerificationMeta('back');
  @override
  late final GeneratedColumn<String> back = GeneratedColumn<String>(
    'back',
    aliasedName,
    false,
    check: () => ComparableExpr(
      StringExpressionOperators(back).trim().length,
    ).isBiggerOrEqualValue(1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    check: () => ComparableExpr(sortOrder).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    front,
    back,
    note,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Flashcard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('front')) {
      context.handle(
        _frontMeta,
        front.isAcceptableOrUnknown(data['front']!, _frontMeta),
      );
    } else if (isInserting) {
      context.missing(_frontMeta);
    }
    if (data.containsKey('back')) {
      context.handle(
        _backMeta,
        back.isAcceptableOrUnknown(data['back']!, _backMeta),
      );
    } else if (isInserting) {
      context.missing(_backMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Flashcard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Flashcard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
      front: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}front'],
      )!,
      back: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}back'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FlashcardsTable createAlias(String alias) {
    return $FlashcardsTable(attachedDatabase, alias);
  }
}

class Flashcard extends DataClass implements Insertable<Flashcard> {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final String? note;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;
  const Flashcard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.note,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deck_id'] = Variable<String>(deckId);
    map['front'] = Variable<String>(front);
    map['back'] = Variable<String>(back);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  FlashcardsCompanion toCompanion(bool nullToAbsent) {
    return FlashcardsCompanion(
      id: Value(id),
      deckId: Value(deckId),
      front: Value(front),
      back: Value(back),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Flashcard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Flashcard(
      id: serializer.fromJson<String>(json['id']),
      deckId: serializer.fromJson<String>(json['deckId']),
      front: serializer.fromJson<String>(json['front']),
      back: serializer.fromJson<String>(json['back']),
      note: serializer.fromJson<String?>(json['note']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deckId': serializer.toJson<String>(deckId),
      'front': serializer.toJson<String>(front),
      'back': serializer.toJson<String>(back),
      'note': serializer.toJson<String?>(note),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Flashcard copyWith({
    String? id,
    String? deckId,
    String? front,
    String? back,
    Value<String?> note = const Value.absent(),
    int? sortOrder,
    int? createdAt,
    int? updatedAt,
  }) => Flashcard(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    front: front ?? this.front,
    back: back ?? this.back,
    note: note.present ? note.value : this.note,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Flashcard copyWithCompanion(FlashcardsCompanion data) {
    return Flashcard(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      front: data.front.present ? data.front.value : this.front,
      back: data.back.present ? data.back.value : this.back,
      note: data.note.present ? data.note.value : this.note,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Flashcard(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('note: $note, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deckId,
    front,
    back,
    note,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Flashcard &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.front == this.front &&
          other.back == this.back &&
          other.note == this.note &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FlashcardsCompanion extends UpdateCompanion<Flashcard> {
  final Value<String> id;
  final Value<String> deckId;
  final Value<String> front;
  final Value<String> back;
  final Value<String?> note;
  final Value<int> sortOrder;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const FlashcardsCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.front = const Value.absent(),
    this.back = const Value.absent(),
    this.note = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlashcardsCompanion.insert({
    required String id,
    required String deckId,
    required String front,
    required String back,
    this.note = const Value.absent(),
    required int sortOrder,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deckId = Value(deckId),
       front = Value(front),
       back = Value(back),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Flashcard> custom({
    Expression<String>? id,
    Expression<String>? deckId,
    Expression<String>? front,
    Expression<String>? back,
    Expression<String>? note,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (front != null) 'front': front,
      if (back != null) 'back': back,
      if (note != null) 'note': note,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlashcardsCompanion copyWith({
    Value<String>? id,
    Value<String>? deckId,
    Value<String>? front,
    Value<String>? back,
    Value<String?>? note,
    Value<int>? sortOrder,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return FlashcardsCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      note: note ?? this.note,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (front.present) {
      map['front'] = Variable<String>(front.value);
    }
    if (back.present) {
      map['back'] = Variable<String>(back.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardsCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('note: $note, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlashcardProgressTable extends FlashcardProgress
    with TableInfo<$FlashcardProgressTable, FlashcardProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _flashcardIdMeta = const VerificationMeta(
    'flashcardId',
  );
  @override
  late final GeneratedColumn<String> flashcardId = GeneratedColumn<String>(
    'flashcard_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES flashcards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _currentBoxMeta = const VerificationMeta(
    'currentBox',
  );
  @override
  late final GeneratedColumn<int> currentBox = GeneratedColumn<int>(
    'current_box',
    aliasedName,
    false,
    check: () => ComparableExpr(currentBox).isBetweenValues(1, 8),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewCountMeta = const VerificationMeta(
    'reviewCount',
  );
  @override
  late final GeneratedColumn<int> reviewCount = GeneratedColumn<int>(
    'review_count',
    aliasedName,
    false,
    check: () => ComparableExpr(reviewCount).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lapseCountMeta = const VerificationMeta(
    'lapseCount',
  );
  @override
  late final GeneratedColumn<int> lapseCount = GeneratedColumn<int>(
    'lapse_count',
    aliasedName,
    false,
    check: () => ComparableExpr(lapseCount).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastResultMeta = const VerificationMeta(
    'lastResult',
  );
  @override
  late final GeneratedColumn<String> lastResult = GeneratedColumn<String>(
    'last_result',
    aliasedName,
    true,
    check: () =>
        lastResult.isNull() | lastResult.isIn(DatabaseEnumValues.reviewResults),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastStudiedAtMeta = const VerificationMeta(
    'lastStudiedAt',
  );
  @override
  late final GeneratedColumn<int> lastStudiedAt = GeneratedColumn<int>(
    'last_studied_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<int> dueAt = GeneratedColumn<int>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    flashcardId,
    currentBox,
    reviewCount,
    lapseCount,
    lastResult,
    lastStudiedAt,
    dueAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcard_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<FlashcardProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('flashcard_id')) {
      context.handle(
        _flashcardIdMeta,
        flashcardId.isAcceptableOrUnknown(
          data['flashcard_id']!,
          _flashcardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_flashcardIdMeta);
    }
    if (data.containsKey('current_box')) {
      context.handle(
        _currentBoxMeta,
        currentBox.isAcceptableOrUnknown(data['current_box']!, _currentBoxMeta),
      );
    } else if (isInserting) {
      context.missing(_currentBoxMeta);
    }
    if (data.containsKey('review_count')) {
      context.handle(
        _reviewCountMeta,
        reviewCount.isAcceptableOrUnknown(
          data['review_count']!,
          _reviewCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewCountMeta);
    }
    if (data.containsKey('lapse_count')) {
      context.handle(
        _lapseCountMeta,
        lapseCount.isAcceptableOrUnknown(data['lapse_count']!, _lapseCountMeta),
      );
    } else if (isInserting) {
      context.missing(_lapseCountMeta);
    }
    if (data.containsKey('last_result')) {
      context.handle(
        _lastResultMeta,
        lastResult.isAcceptableOrUnknown(data['last_result']!, _lastResultMeta),
      );
    }
    if (data.containsKey('last_studied_at')) {
      context.handle(
        _lastStudiedAtMeta,
        lastStudiedAt.isAcceptableOrUnknown(
          data['last_studied_at']!,
          _lastStudiedAtMeta,
        ),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {flashcardId};
  @override
  FlashcardProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlashcardProgressData(
      flashcardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flashcard_id'],
      )!,
      currentBox: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_box'],
      )!,
      reviewCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_count'],
      )!,
      lapseCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapse_count'],
      )!,
      lastResult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_result'],
      ),
      lastStudiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_studied_at'],
      ),
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FlashcardProgressTable createAlias(String alias) {
    return $FlashcardProgressTable(attachedDatabase, alias);
  }
}

class FlashcardProgressData extends DataClass
    implements Insertable<FlashcardProgressData> {
  final String flashcardId;
  final int currentBox;
  final int reviewCount;
  final int lapseCount;
  final String? lastResult;
  final int? lastStudiedAt;
  final int? dueAt;
  final int createdAt;
  final int updatedAt;
  const FlashcardProgressData({
    required this.flashcardId,
    required this.currentBox,
    required this.reviewCount,
    required this.lapseCount,
    this.lastResult,
    this.lastStudiedAt,
    this.dueAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['flashcard_id'] = Variable<String>(flashcardId);
    map['current_box'] = Variable<int>(currentBox);
    map['review_count'] = Variable<int>(reviewCount);
    map['lapse_count'] = Variable<int>(lapseCount);
    if (!nullToAbsent || lastResult != null) {
      map['last_result'] = Variable<String>(lastResult);
    }
    if (!nullToAbsent || lastStudiedAt != null) {
      map['last_studied_at'] = Variable<int>(lastStudiedAt);
    }
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<int>(dueAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  FlashcardProgressCompanion toCompanion(bool nullToAbsent) {
    return FlashcardProgressCompanion(
      flashcardId: Value(flashcardId),
      currentBox: Value(currentBox),
      reviewCount: Value(reviewCount),
      lapseCount: Value(lapseCount),
      lastResult: lastResult == null && nullToAbsent
          ? const Value.absent()
          : Value(lastResult),
      lastStudiedAt: lastStudiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStudiedAt),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FlashcardProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlashcardProgressData(
      flashcardId: serializer.fromJson<String>(json['flashcardId']),
      currentBox: serializer.fromJson<int>(json['currentBox']),
      reviewCount: serializer.fromJson<int>(json['reviewCount']),
      lapseCount: serializer.fromJson<int>(json['lapseCount']),
      lastResult: serializer.fromJson<String?>(json['lastResult']),
      lastStudiedAt: serializer.fromJson<int?>(json['lastStudiedAt']),
      dueAt: serializer.fromJson<int?>(json['dueAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'flashcardId': serializer.toJson<String>(flashcardId),
      'currentBox': serializer.toJson<int>(currentBox),
      'reviewCount': serializer.toJson<int>(reviewCount),
      'lapseCount': serializer.toJson<int>(lapseCount),
      'lastResult': serializer.toJson<String?>(lastResult),
      'lastStudiedAt': serializer.toJson<int?>(lastStudiedAt),
      'dueAt': serializer.toJson<int?>(dueAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  FlashcardProgressData copyWith({
    String? flashcardId,
    int? currentBox,
    int? reviewCount,
    int? lapseCount,
    Value<String?> lastResult = const Value.absent(),
    Value<int?> lastStudiedAt = const Value.absent(),
    Value<int?> dueAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => FlashcardProgressData(
    flashcardId: flashcardId ?? this.flashcardId,
    currentBox: currentBox ?? this.currentBox,
    reviewCount: reviewCount ?? this.reviewCount,
    lapseCount: lapseCount ?? this.lapseCount,
    lastResult: lastResult.present ? lastResult.value : this.lastResult,
    lastStudiedAt: lastStudiedAt.present
        ? lastStudiedAt.value
        : this.lastStudiedAt,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FlashcardProgressData copyWithCompanion(FlashcardProgressCompanion data) {
    return FlashcardProgressData(
      flashcardId: data.flashcardId.present
          ? data.flashcardId.value
          : this.flashcardId,
      currentBox: data.currentBox.present
          ? data.currentBox.value
          : this.currentBox,
      reviewCount: data.reviewCount.present
          ? data.reviewCount.value
          : this.reviewCount,
      lapseCount: data.lapseCount.present
          ? data.lapseCount.value
          : this.lapseCount,
      lastResult: data.lastResult.present
          ? data.lastResult.value
          : this.lastResult,
      lastStudiedAt: data.lastStudiedAt.present
          ? data.lastStudiedAt.value
          : this.lastStudiedAt,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardProgressData(')
          ..write('flashcardId: $flashcardId, ')
          ..write('currentBox: $currentBox, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('lapseCount: $lapseCount, ')
          ..write('lastResult: $lastResult, ')
          ..write('lastStudiedAt: $lastStudiedAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    flashcardId,
    currentBox,
    reviewCount,
    lapseCount,
    lastResult,
    lastStudiedAt,
    dueAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlashcardProgressData &&
          other.flashcardId == this.flashcardId &&
          other.currentBox == this.currentBox &&
          other.reviewCount == this.reviewCount &&
          other.lapseCount == this.lapseCount &&
          other.lastResult == this.lastResult &&
          other.lastStudiedAt == this.lastStudiedAt &&
          other.dueAt == this.dueAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FlashcardProgressCompanion
    extends UpdateCompanion<FlashcardProgressData> {
  final Value<String> flashcardId;
  final Value<int> currentBox;
  final Value<int> reviewCount;
  final Value<int> lapseCount;
  final Value<String?> lastResult;
  final Value<int?> lastStudiedAt;
  final Value<int?> dueAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const FlashcardProgressCompanion({
    this.flashcardId = const Value.absent(),
    this.currentBox = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.lapseCount = const Value.absent(),
    this.lastResult = const Value.absent(),
    this.lastStudiedAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlashcardProgressCompanion.insert({
    required String flashcardId,
    required int currentBox,
    required int reviewCount,
    required int lapseCount,
    this.lastResult = const Value.absent(),
    this.lastStudiedAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : flashcardId = Value(flashcardId),
       currentBox = Value(currentBox),
       reviewCount = Value(reviewCount),
       lapseCount = Value(lapseCount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FlashcardProgressData> custom({
    Expression<String>? flashcardId,
    Expression<int>? currentBox,
    Expression<int>? reviewCount,
    Expression<int>? lapseCount,
    Expression<String>? lastResult,
    Expression<int>? lastStudiedAt,
    Expression<int>? dueAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (flashcardId != null) 'flashcard_id': flashcardId,
      if (currentBox != null) 'current_box': currentBox,
      if (reviewCount != null) 'review_count': reviewCount,
      if (lapseCount != null) 'lapse_count': lapseCount,
      if (lastResult != null) 'last_result': lastResult,
      if (lastStudiedAt != null) 'last_studied_at': lastStudiedAt,
      if (dueAt != null) 'due_at': dueAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlashcardProgressCompanion copyWith({
    Value<String>? flashcardId,
    Value<int>? currentBox,
    Value<int>? reviewCount,
    Value<int>? lapseCount,
    Value<String?>? lastResult,
    Value<int?>? lastStudiedAt,
    Value<int?>? dueAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return FlashcardProgressCompanion(
      flashcardId: flashcardId ?? this.flashcardId,
      currentBox: currentBox ?? this.currentBox,
      reviewCount: reviewCount ?? this.reviewCount,
      lapseCount: lapseCount ?? this.lapseCount,
      lastResult: lastResult ?? this.lastResult,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (flashcardId.present) {
      map['flashcard_id'] = Variable<String>(flashcardId.value);
    }
    if (currentBox.present) {
      map['current_box'] = Variable<int>(currentBox.value);
    }
    if (reviewCount.present) {
      map['review_count'] = Variable<int>(reviewCount.value);
    }
    if (lapseCount.present) {
      map['lapse_count'] = Variable<int>(lapseCount.value);
    }
    if (lastResult.present) {
      map['last_result'] = Variable<String>(lastResult.value);
    }
    if (lastStudiedAt.present) {
      map['last_studied_at'] = Variable<int>(lastStudiedAt.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<int>(dueAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardProgressCompanion(')
          ..write('flashcardId: $flashcardId, ')
          ..write('currentBox: $currentBox, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('lapseCount: $lapseCount, ')
          ..write('lastResult: $lastResult, ')
          ..write('lastStudiedAt: $lastStudiedAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudySessionsTable extends StudySessions
    with TableInfo<$StudySessionsTable, StudySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta(
    'entryType',
  );
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
    'entry_type',
    aliasedName,
    false,
    check: () => entryType.isIn(DatabaseEnumValues.studyEntryTypes),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryRefIdMeta = const VerificationMeta(
    'entryRefId',
  );
  @override
  late final GeneratedColumn<String> entryRefId = GeneratedColumn<String>(
    'entry_ref_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studyTypeMeta = const VerificationMeta(
    'studyType',
  );
  @override
  late final GeneratedColumn<String> studyType = GeneratedColumn<String>(
    'study_type',
    aliasedName,
    false,
    check: () => studyType.isIn(DatabaseEnumValues.studyTypes),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studyFlowMeta = const VerificationMeta(
    'studyFlow',
  );
  @override
  late final GeneratedColumn<String> studyFlow = GeneratedColumn<String>(
    'study_flow',
    aliasedName,
    false,
    check: () => studyFlow.isIn(DatabaseEnumValues.studyFlows),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchSizeMeta = const VerificationMeta(
    'batchSize',
  );
  @override
  late final GeneratedColumn<int> batchSize = GeneratedColumn<int>(
    'batch_size',
    aliasedName,
    false,
    check: () => ComparableExpr(batchSize).isBiggerOrEqualValue(1),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shuffleFlashcardsMeta = const VerificationMeta(
    'shuffleFlashcards',
  );
  @override
  late final GeneratedColumn<int> shuffleFlashcards = GeneratedColumn<int>(
    'shuffle_flashcards',
    aliasedName,
    false,
    check: () => shuffleFlashcards.isIn(const <int>[0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shuffleAnswersMeta = const VerificationMeta(
    'shuffleAnswers',
  );
  @override
  late final GeneratedColumn<int> shuffleAnswers = GeneratedColumn<int>(
    'shuffle_answers',
    aliasedName,
    false,
    check: () => shuffleAnswers.isIn(const <int>[0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prioritizeOverdueMeta = const VerificationMeta(
    'prioritizeOverdue',
  );
  @override
  late final GeneratedColumn<int> prioritizeOverdue = GeneratedColumn<int>(
    'prioritize_overdue',
    aliasedName,
    false,
    check: () => prioritizeOverdue.isIn(const <int>[0, 1]),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(DatabaseEnumValues.sessionStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restartedFromSessionIdMeta =
      const VerificationMeta('restartedFromSessionId');
  @override
  late final GeneratedColumn<String> restartedFromSessionId =
      GeneratedColumn<String>(
        'restarted_from_session_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES study_sessions (id)',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryType,
    entryRefId,
    studyType,
    studyFlow,
    batchSize,
    shuffleFlashcards,
    shuffleAnswers,
    prioritizeOverdue,
    status,
    startedAt,
    endedAt,
    restartedFromSessionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudySession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(
        _entryTypeMeta,
        entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('entry_ref_id')) {
      context.handle(
        _entryRefIdMeta,
        entryRefId.isAcceptableOrUnknown(
          data['entry_ref_id']!,
          _entryRefIdMeta,
        ),
      );
    }
    if (data.containsKey('study_type')) {
      context.handle(
        _studyTypeMeta,
        studyType.isAcceptableOrUnknown(data['study_type']!, _studyTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_studyTypeMeta);
    }
    if (data.containsKey('study_flow')) {
      context.handle(
        _studyFlowMeta,
        studyFlow.isAcceptableOrUnknown(data['study_flow']!, _studyFlowMeta),
      );
    } else if (isInserting) {
      context.missing(_studyFlowMeta);
    }
    if (data.containsKey('batch_size')) {
      context.handle(
        _batchSizeMeta,
        batchSize.isAcceptableOrUnknown(data['batch_size']!, _batchSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_batchSizeMeta);
    }
    if (data.containsKey('shuffle_flashcards')) {
      context.handle(
        _shuffleFlashcardsMeta,
        shuffleFlashcards.isAcceptableOrUnknown(
          data['shuffle_flashcards']!,
          _shuffleFlashcardsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shuffleFlashcardsMeta);
    }
    if (data.containsKey('shuffle_answers')) {
      context.handle(
        _shuffleAnswersMeta,
        shuffleAnswers.isAcceptableOrUnknown(
          data['shuffle_answers']!,
          _shuffleAnswersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shuffleAnswersMeta);
    }
    if (data.containsKey('prioritize_overdue')) {
      context.handle(
        _prioritizeOverdueMeta,
        prioritizeOverdue.isAcceptableOrUnknown(
          data['prioritize_overdue']!,
          _prioritizeOverdueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_prioritizeOverdueMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('restarted_from_session_id')) {
      context.handle(
        _restartedFromSessionIdMeta,
        restartedFromSessionId.isAcceptableOrUnknown(
          data['restarted_from_session_id']!,
          _restartedFromSessionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_type'],
      )!,
      entryRefId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_ref_id'],
      ),
      studyType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}study_type'],
      )!,
      studyFlow: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}study_flow'],
      )!,
      batchSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_size'],
      )!,
      shuffleFlashcards: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shuffle_flashcards'],
      )!,
      shuffleAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shuffle_answers'],
      )!,
      prioritizeOverdue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prioritize_overdue'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
      restartedFromSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restarted_from_session_id'],
      ),
    );
  }

  @override
  $StudySessionsTable createAlias(String alias) {
    return $StudySessionsTable(attachedDatabase, alias);
  }
}

class StudySession extends DataClass implements Insertable<StudySession> {
  final String id;
  final String entryType;
  final String? entryRefId;
  final String studyType;
  final String studyFlow;
  final int batchSize;
  final int shuffleFlashcards;
  final int shuffleAnswers;
  final int prioritizeOverdue;
  final String status;
  final int startedAt;
  final int? endedAt;
  final String? restartedFromSessionId;
  const StudySession({
    required this.id,
    required this.entryType,
    this.entryRefId,
    required this.studyType,
    required this.studyFlow,
    required this.batchSize,
    required this.shuffleFlashcards,
    required this.shuffleAnswers,
    required this.prioritizeOverdue,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.restartedFromSessionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_type'] = Variable<String>(entryType);
    if (!nullToAbsent || entryRefId != null) {
      map['entry_ref_id'] = Variable<String>(entryRefId);
    }
    map['study_type'] = Variable<String>(studyType);
    map['study_flow'] = Variable<String>(studyFlow);
    map['batch_size'] = Variable<int>(batchSize);
    map['shuffle_flashcards'] = Variable<int>(shuffleFlashcards);
    map['shuffle_answers'] = Variable<int>(shuffleAnswers);
    map['prioritize_overdue'] = Variable<int>(prioritizeOverdue);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    if (!nullToAbsent || restartedFromSessionId != null) {
      map['restarted_from_session_id'] = Variable<String>(
        restartedFromSessionId,
      );
    }
    return map;
  }

  StudySessionsCompanion toCompanion(bool nullToAbsent) {
    return StudySessionsCompanion(
      id: Value(id),
      entryType: Value(entryType),
      entryRefId: entryRefId == null && nullToAbsent
          ? const Value.absent()
          : Value(entryRefId),
      studyType: Value(studyType),
      studyFlow: Value(studyFlow),
      batchSize: Value(batchSize),
      shuffleFlashcards: Value(shuffleFlashcards),
      shuffleAnswers: Value(shuffleAnswers),
      prioritizeOverdue: Value(prioritizeOverdue),
      status: Value(status),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      restartedFromSessionId: restartedFromSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(restartedFromSessionId),
    );
  }

  factory StudySession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySession(
      id: serializer.fromJson<String>(json['id']),
      entryType: serializer.fromJson<String>(json['entryType']),
      entryRefId: serializer.fromJson<String?>(json['entryRefId']),
      studyType: serializer.fromJson<String>(json['studyType']),
      studyFlow: serializer.fromJson<String>(json['studyFlow']),
      batchSize: serializer.fromJson<int>(json['batchSize']),
      shuffleFlashcards: serializer.fromJson<int>(json['shuffleFlashcards']),
      shuffleAnswers: serializer.fromJson<int>(json['shuffleAnswers']),
      prioritizeOverdue: serializer.fromJson<int>(json['prioritizeOverdue']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      restartedFromSessionId: serializer.fromJson<String?>(
        json['restartedFromSessionId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryType': serializer.toJson<String>(entryType),
      'entryRefId': serializer.toJson<String?>(entryRefId),
      'studyType': serializer.toJson<String>(studyType),
      'studyFlow': serializer.toJson<String>(studyFlow),
      'batchSize': serializer.toJson<int>(batchSize),
      'shuffleFlashcards': serializer.toJson<int>(shuffleFlashcards),
      'shuffleAnswers': serializer.toJson<int>(shuffleAnswers),
      'prioritizeOverdue': serializer.toJson<int>(prioritizeOverdue),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int?>(endedAt),
      'restartedFromSessionId': serializer.toJson<String?>(
        restartedFromSessionId,
      ),
    };
  }

  StudySession copyWith({
    String? id,
    String? entryType,
    Value<String?> entryRefId = const Value.absent(),
    String? studyType,
    String? studyFlow,
    int? batchSize,
    int? shuffleFlashcards,
    int? shuffleAnswers,
    int? prioritizeOverdue,
    String? status,
    int? startedAt,
    Value<int?> endedAt = const Value.absent(),
    Value<String?> restartedFromSessionId = const Value.absent(),
  }) => StudySession(
    id: id ?? this.id,
    entryType: entryType ?? this.entryType,
    entryRefId: entryRefId.present ? entryRefId.value : this.entryRefId,
    studyType: studyType ?? this.studyType,
    studyFlow: studyFlow ?? this.studyFlow,
    batchSize: batchSize ?? this.batchSize,
    shuffleFlashcards: shuffleFlashcards ?? this.shuffleFlashcards,
    shuffleAnswers: shuffleAnswers ?? this.shuffleAnswers,
    prioritizeOverdue: prioritizeOverdue ?? this.prioritizeOverdue,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    restartedFromSessionId: restartedFromSessionId.present
        ? restartedFromSessionId.value
        : this.restartedFromSessionId,
  );
  StudySession copyWithCompanion(StudySessionsCompanion data) {
    return StudySession(
      id: data.id.present ? data.id.value : this.id,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      entryRefId: data.entryRefId.present
          ? data.entryRefId.value
          : this.entryRefId,
      studyType: data.studyType.present ? data.studyType.value : this.studyType,
      studyFlow: data.studyFlow.present ? data.studyFlow.value : this.studyFlow,
      batchSize: data.batchSize.present ? data.batchSize.value : this.batchSize,
      shuffleFlashcards: data.shuffleFlashcards.present
          ? data.shuffleFlashcards.value
          : this.shuffleFlashcards,
      shuffleAnswers: data.shuffleAnswers.present
          ? data.shuffleAnswers.value
          : this.shuffleAnswers,
      prioritizeOverdue: data.prioritizeOverdue.present
          ? data.prioritizeOverdue.value
          : this.prioritizeOverdue,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      restartedFromSessionId: data.restartedFromSessionId.present
          ? data.restartedFromSessionId.value
          : this.restartedFromSessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySession(')
          ..write('id: $id, ')
          ..write('entryType: $entryType, ')
          ..write('entryRefId: $entryRefId, ')
          ..write('studyType: $studyType, ')
          ..write('studyFlow: $studyFlow, ')
          ..write('batchSize: $batchSize, ')
          ..write('shuffleFlashcards: $shuffleFlashcards, ')
          ..write('shuffleAnswers: $shuffleAnswers, ')
          ..write('prioritizeOverdue: $prioritizeOverdue, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('restartedFromSessionId: $restartedFromSessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entryType,
    entryRefId,
    studyType,
    studyFlow,
    batchSize,
    shuffleFlashcards,
    shuffleAnswers,
    prioritizeOverdue,
    status,
    startedAt,
    endedAt,
    restartedFromSessionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySession &&
          other.id == this.id &&
          other.entryType == this.entryType &&
          other.entryRefId == this.entryRefId &&
          other.studyType == this.studyType &&
          other.studyFlow == this.studyFlow &&
          other.batchSize == this.batchSize &&
          other.shuffleFlashcards == this.shuffleFlashcards &&
          other.shuffleAnswers == this.shuffleAnswers &&
          other.prioritizeOverdue == this.prioritizeOverdue &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.restartedFromSessionId == this.restartedFromSessionId);
}

class StudySessionsCompanion extends UpdateCompanion<StudySession> {
  final Value<String> id;
  final Value<String> entryType;
  final Value<String?> entryRefId;
  final Value<String> studyType;
  final Value<String> studyFlow;
  final Value<int> batchSize;
  final Value<int> shuffleFlashcards;
  final Value<int> shuffleAnswers;
  final Value<int> prioritizeOverdue;
  final Value<String> status;
  final Value<int> startedAt;
  final Value<int?> endedAt;
  final Value<String?> restartedFromSessionId;
  final Value<int> rowid;
  const StudySessionsCompanion({
    this.id = const Value.absent(),
    this.entryType = const Value.absent(),
    this.entryRefId = const Value.absent(),
    this.studyType = const Value.absent(),
    this.studyFlow = const Value.absent(),
    this.batchSize = const Value.absent(),
    this.shuffleFlashcards = const Value.absent(),
    this.shuffleAnswers = const Value.absent(),
    this.prioritizeOverdue = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.restartedFromSessionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudySessionsCompanion.insert({
    required String id,
    required String entryType,
    this.entryRefId = const Value.absent(),
    required String studyType,
    required String studyFlow,
    required int batchSize,
    required int shuffleFlashcards,
    required int shuffleAnswers,
    required int prioritizeOverdue,
    required String status,
    required int startedAt,
    this.endedAt = const Value.absent(),
    this.restartedFromSessionId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entryType = Value(entryType),
       studyType = Value(studyType),
       studyFlow = Value(studyFlow),
       batchSize = Value(batchSize),
       shuffleFlashcards = Value(shuffleFlashcards),
       shuffleAnswers = Value(shuffleAnswers),
       prioritizeOverdue = Value(prioritizeOverdue),
       status = Value(status),
       startedAt = Value(startedAt);
  static Insertable<StudySession> custom({
    Expression<String>? id,
    Expression<String>? entryType,
    Expression<String>? entryRefId,
    Expression<String>? studyType,
    Expression<String>? studyFlow,
    Expression<int>? batchSize,
    Expression<int>? shuffleFlashcards,
    Expression<int>? shuffleAnswers,
    Expression<int>? prioritizeOverdue,
    Expression<String>? status,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<String>? restartedFromSessionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryType != null) 'entry_type': entryType,
      if (entryRefId != null) 'entry_ref_id': entryRefId,
      if (studyType != null) 'study_type': studyType,
      if (studyFlow != null) 'study_flow': studyFlow,
      if (batchSize != null) 'batch_size': batchSize,
      if (shuffleFlashcards != null) 'shuffle_flashcards': shuffleFlashcards,
      if (shuffleAnswers != null) 'shuffle_answers': shuffleAnswers,
      if (prioritizeOverdue != null) 'prioritize_overdue': prioritizeOverdue,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (restartedFromSessionId != null)
        'restarted_from_session_id': restartedFromSessionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudySessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? entryType,
    Value<String?>? entryRefId,
    Value<String>? studyType,
    Value<String>? studyFlow,
    Value<int>? batchSize,
    Value<int>? shuffleFlashcards,
    Value<int>? shuffleAnswers,
    Value<int>? prioritizeOverdue,
    Value<String>? status,
    Value<int>? startedAt,
    Value<int?>? endedAt,
    Value<String?>? restartedFromSessionId,
    Value<int>? rowid,
  }) {
    return StudySessionsCompanion(
      id: id ?? this.id,
      entryType: entryType ?? this.entryType,
      entryRefId: entryRefId ?? this.entryRefId,
      studyType: studyType ?? this.studyType,
      studyFlow: studyFlow ?? this.studyFlow,
      batchSize: batchSize ?? this.batchSize,
      shuffleFlashcards: shuffleFlashcards ?? this.shuffleFlashcards,
      shuffleAnswers: shuffleAnswers ?? this.shuffleAnswers,
      prioritizeOverdue: prioritizeOverdue ?? this.prioritizeOverdue,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      restartedFromSessionId:
          restartedFromSessionId ?? this.restartedFromSessionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (entryRefId.present) {
      map['entry_ref_id'] = Variable<String>(entryRefId.value);
    }
    if (studyType.present) {
      map['study_type'] = Variable<String>(studyType.value);
    }
    if (studyFlow.present) {
      map['study_flow'] = Variable<String>(studyFlow.value);
    }
    if (batchSize.present) {
      map['batch_size'] = Variable<int>(batchSize.value);
    }
    if (shuffleFlashcards.present) {
      map['shuffle_flashcards'] = Variable<int>(shuffleFlashcards.value);
    }
    if (shuffleAnswers.present) {
      map['shuffle_answers'] = Variable<int>(shuffleAnswers.value);
    }
    if (prioritizeOverdue.present) {
      map['prioritize_overdue'] = Variable<int>(prioritizeOverdue.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (restartedFromSessionId.present) {
      map['restarted_from_session_id'] = Variable<String>(
        restartedFromSessionId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionsCompanion(')
          ..write('id: $id, ')
          ..write('entryType: $entryType, ')
          ..write('entryRefId: $entryRefId, ')
          ..write('studyType: $studyType, ')
          ..write('studyFlow: $studyFlow, ')
          ..write('batchSize: $batchSize, ')
          ..write('shuffleFlashcards: $shuffleFlashcards, ')
          ..write('shuffleAnswers: $shuffleAnswers, ')
          ..write('prioritizeOverdue: $prioritizeOverdue, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('restartedFromSessionId: $restartedFromSessionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudySessionItemsTable extends StudySessionItems
    with TableInfo<$StudySessionItemsTable, StudySessionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES study_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _flashcardIdMeta = const VerificationMeta(
    'flashcardId',
  );
  @override
  late final GeneratedColumn<String> flashcardId = GeneratedColumn<String>(
    'flashcard_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES flashcards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _studyModeMeta = const VerificationMeta(
    'studyMode',
  );
  @override
  late final GeneratedColumn<String> studyMode = GeneratedColumn<String>(
    'study_mode',
    aliasedName,
    false,
    check: () => studyMode.isIn(DatabaseEnumValues.studyModes),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeOrderMeta = const VerificationMeta(
    'modeOrder',
  );
  @override
  late final GeneratedColumn<int> modeOrder = GeneratedColumn<int>(
    'mode_order',
    aliasedName,
    false,
    check: () => ComparableExpr(modeOrder).isBiggerOrEqualValue(1),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundIndexMeta = const VerificationMeta(
    'roundIndex',
  );
  @override
  late final GeneratedColumn<int> roundIndex = GeneratedColumn<int>(
    'round_index',
    aliasedName,
    false,
    check: () => ComparableExpr(roundIndex).isBiggerOrEqualValue(1),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queuePositionMeta = const VerificationMeta(
    'queuePosition',
  );
  @override
  late final GeneratedColumn<int> queuePosition = GeneratedColumn<int>(
    'queue_position',
    aliasedName,
    false,
    check: () => ComparableExpr(queuePosition).isBiggerOrEqualValue(1),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourcePoolMeta = const VerificationMeta(
    'sourcePool',
  );
  @override
  late final GeneratedColumn<String> sourcePool = GeneratedColumn<String>(
    'source_pool',
    aliasedName,
    false,
    check: () => sourcePool.isIn(DatabaseEnumValues.sessionItemSourcePools),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(DatabaseEnumValues.sessionItemStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    flashcardId,
    studyMode,
    modeOrder,
    roundIndex,
    queuePosition,
    sourcePool,
    status,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_session_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudySessionItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('flashcard_id')) {
      context.handle(
        _flashcardIdMeta,
        flashcardId.isAcceptableOrUnknown(
          data['flashcard_id']!,
          _flashcardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_flashcardIdMeta);
    }
    if (data.containsKey('study_mode')) {
      context.handle(
        _studyModeMeta,
        studyMode.isAcceptableOrUnknown(data['study_mode']!, _studyModeMeta),
      );
    } else if (isInserting) {
      context.missing(_studyModeMeta);
    }
    if (data.containsKey('mode_order')) {
      context.handle(
        _modeOrderMeta,
        modeOrder.isAcceptableOrUnknown(data['mode_order']!, _modeOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_modeOrderMeta);
    }
    if (data.containsKey('round_index')) {
      context.handle(
        _roundIndexMeta,
        roundIndex.isAcceptableOrUnknown(data['round_index']!, _roundIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_roundIndexMeta);
    }
    if (data.containsKey('queue_position')) {
      context.handle(
        _queuePositionMeta,
        queuePosition.isAcceptableOrUnknown(
          data['queue_position']!,
          _queuePositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_queuePositionMeta);
    }
    if (data.containsKey('source_pool')) {
      context.handle(
        _sourcePoolMeta,
        sourcePool.isAcceptableOrUnknown(data['source_pool']!, _sourcePoolMeta),
      );
    } else if (isInserting) {
      context.missing(_sourcePoolMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudySessionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySessionItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      flashcardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flashcard_id'],
      )!,
      studyMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}study_mode'],
      )!,
      modeOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mode_order'],
      )!,
      roundIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round_index'],
      )!,
      queuePosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queue_position'],
      )!,
      sourcePool: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_pool'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $StudySessionItemsTable createAlias(String alias) {
    return $StudySessionItemsTable(attachedDatabase, alias);
  }
}

class StudySessionItem extends DataClass
    implements Insertable<StudySessionItem> {
  final String id;
  final String sessionId;
  final String flashcardId;
  final String studyMode;
  final int modeOrder;
  final int roundIndex;
  final int queuePosition;
  final String sourcePool;
  final String status;
  final int? completedAt;
  const StudySessionItem({
    required this.id,
    required this.sessionId,
    required this.flashcardId,
    required this.studyMode,
    required this.modeOrder,
    required this.roundIndex,
    required this.queuePosition,
    required this.sourcePool,
    required this.status,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['flashcard_id'] = Variable<String>(flashcardId);
    map['study_mode'] = Variable<String>(studyMode);
    map['mode_order'] = Variable<int>(modeOrder);
    map['round_index'] = Variable<int>(roundIndex);
    map['queue_position'] = Variable<int>(queuePosition);
    map['source_pool'] = Variable<String>(sourcePool);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    return map;
  }

  StudySessionItemsCompanion toCompanion(bool nullToAbsent) {
    return StudySessionItemsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      flashcardId: Value(flashcardId),
      studyMode: Value(studyMode),
      modeOrder: Value(modeOrder),
      roundIndex: Value(roundIndex),
      queuePosition: Value(queuePosition),
      sourcePool: Value(sourcePool),
      status: Value(status),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory StudySessionItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySessionItem(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      flashcardId: serializer.fromJson<String>(json['flashcardId']),
      studyMode: serializer.fromJson<String>(json['studyMode']),
      modeOrder: serializer.fromJson<int>(json['modeOrder']),
      roundIndex: serializer.fromJson<int>(json['roundIndex']),
      queuePosition: serializer.fromJson<int>(json['queuePosition']),
      sourcePool: serializer.fromJson<String>(json['sourcePool']),
      status: serializer.fromJson<String>(json['status']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'flashcardId': serializer.toJson<String>(flashcardId),
      'studyMode': serializer.toJson<String>(studyMode),
      'modeOrder': serializer.toJson<int>(modeOrder),
      'roundIndex': serializer.toJson<int>(roundIndex),
      'queuePosition': serializer.toJson<int>(queuePosition),
      'sourcePool': serializer.toJson<String>(sourcePool),
      'status': serializer.toJson<String>(status),
      'completedAt': serializer.toJson<int?>(completedAt),
    };
  }

  StudySessionItem copyWith({
    String? id,
    String? sessionId,
    String? flashcardId,
    String? studyMode,
    int? modeOrder,
    int? roundIndex,
    int? queuePosition,
    String? sourcePool,
    String? status,
    Value<int?> completedAt = const Value.absent(),
  }) => StudySessionItem(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    flashcardId: flashcardId ?? this.flashcardId,
    studyMode: studyMode ?? this.studyMode,
    modeOrder: modeOrder ?? this.modeOrder,
    roundIndex: roundIndex ?? this.roundIndex,
    queuePosition: queuePosition ?? this.queuePosition,
    sourcePool: sourcePool ?? this.sourcePool,
    status: status ?? this.status,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  StudySessionItem copyWithCompanion(StudySessionItemsCompanion data) {
    return StudySessionItem(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      flashcardId: data.flashcardId.present
          ? data.flashcardId.value
          : this.flashcardId,
      studyMode: data.studyMode.present ? data.studyMode.value : this.studyMode,
      modeOrder: data.modeOrder.present ? data.modeOrder.value : this.modeOrder,
      roundIndex: data.roundIndex.present
          ? data.roundIndex.value
          : this.roundIndex,
      queuePosition: data.queuePosition.present
          ? data.queuePosition.value
          : this.queuePosition,
      sourcePool: data.sourcePool.present
          ? data.sourcePool.value
          : this.sourcePool,
      status: data.status.present ? data.status.value : this.status,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionItem(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('flashcardId: $flashcardId, ')
          ..write('studyMode: $studyMode, ')
          ..write('modeOrder: $modeOrder, ')
          ..write('roundIndex: $roundIndex, ')
          ..write('queuePosition: $queuePosition, ')
          ..write('sourcePool: $sourcePool, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    flashcardId,
    studyMode,
    modeOrder,
    roundIndex,
    queuePosition,
    sourcePool,
    status,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySessionItem &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.flashcardId == this.flashcardId &&
          other.studyMode == this.studyMode &&
          other.modeOrder == this.modeOrder &&
          other.roundIndex == this.roundIndex &&
          other.queuePosition == this.queuePosition &&
          other.sourcePool == this.sourcePool &&
          other.status == this.status &&
          other.completedAt == this.completedAt);
}

class StudySessionItemsCompanion extends UpdateCompanion<StudySessionItem> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> flashcardId;
  final Value<String> studyMode;
  final Value<int> modeOrder;
  final Value<int> roundIndex;
  final Value<int> queuePosition;
  final Value<String> sourcePool;
  final Value<String> status;
  final Value<int?> completedAt;
  final Value<int> rowid;
  const StudySessionItemsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.flashcardId = const Value.absent(),
    this.studyMode = const Value.absent(),
    this.modeOrder = const Value.absent(),
    this.roundIndex = const Value.absent(),
    this.queuePosition = const Value.absent(),
    this.sourcePool = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudySessionItemsCompanion.insert({
    required String id,
    required String sessionId,
    required String flashcardId,
    required String studyMode,
    required int modeOrder,
    required int roundIndex,
    required int queuePosition,
    required String sourcePool,
    required String status,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       flashcardId = Value(flashcardId),
       studyMode = Value(studyMode),
       modeOrder = Value(modeOrder),
       roundIndex = Value(roundIndex),
       queuePosition = Value(queuePosition),
       sourcePool = Value(sourcePool),
       status = Value(status);
  static Insertable<StudySessionItem> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? flashcardId,
    Expression<String>? studyMode,
    Expression<int>? modeOrder,
    Expression<int>? roundIndex,
    Expression<int>? queuePosition,
    Expression<String>? sourcePool,
    Expression<String>? status,
    Expression<int>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (flashcardId != null) 'flashcard_id': flashcardId,
      if (studyMode != null) 'study_mode': studyMode,
      if (modeOrder != null) 'mode_order': modeOrder,
      if (roundIndex != null) 'round_index': roundIndex,
      if (queuePosition != null) 'queue_position': queuePosition,
      if (sourcePool != null) 'source_pool': sourcePool,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudySessionItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? flashcardId,
    Value<String>? studyMode,
    Value<int>? modeOrder,
    Value<int>? roundIndex,
    Value<int>? queuePosition,
    Value<String>? sourcePool,
    Value<String>? status,
    Value<int?>? completedAt,
    Value<int>? rowid,
  }) {
    return StudySessionItemsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      flashcardId: flashcardId ?? this.flashcardId,
      studyMode: studyMode ?? this.studyMode,
      modeOrder: modeOrder ?? this.modeOrder,
      roundIndex: roundIndex ?? this.roundIndex,
      queuePosition: queuePosition ?? this.queuePosition,
      sourcePool: sourcePool ?? this.sourcePool,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (flashcardId.present) {
      map['flashcard_id'] = Variable<String>(flashcardId.value);
    }
    if (studyMode.present) {
      map['study_mode'] = Variable<String>(studyMode.value);
    }
    if (modeOrder.present) {
      map['mode_order'] = Variable<int>(modeOrder.value);
    }
    if (roundIndex.present) {
      map['round_index'] = Variable<int>(roundIndex.value);
    }
    if (queuePosition.present) {
      map['queue_position'] = Variable<int>(queuePosition.value);
    }
    if (sourcePool.present) {
      map['source_pool'] = Variable<String>(sourcePool.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionItemsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('flashcardId: $flashcardId, ')
          ..write('studyMode: $studyMode, ')
          ..write('modeOrder: $modeOrder, ')
          ..write('roundIndex: $roundIndex, ')
          ..write('queuePosition: $queuePosition, ')
          ..write('sourcePool: $sourcePool, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyAttemptsTable extends StudyAttempts
    with TableInfo<$StudyAttemptsTable, StudyAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES study_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sessionItemIdMeta = const VerificationMeta(
    'sessionItemId',
  );
  @override
  late final GeneratedColumn<String> sessionItemId = GeneratedColumn<String>(
    'session_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES study_session_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _flashcardIdMeta = const VerificationMeta(
    'flashcardId',
  );
  @override
  late final GeneratedColumn<String> flashcardId = GeneratedColumn<String>(
    'flashcard_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES flashcards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _attemptNumberMeta = const VerificationMeta(
    'attemptNumber',
  );
  @override
  late final GeneratedColumn<int> attemptNumber = GeneratedColumn<int>(
    'attempt_number',
    aliasedName,
    false,
    check: () => ComparableExpr(attemptNumber).isBiggerOrEqualValue(1),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    check: () => result.isIn(DatabaseEnumValues.rawStudyResults),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oldBoxMeta = const VerificationMeta('oldBox');
  @override
  late final GeneratedColumn<int> oldBox = GeneratedColumn<int>(
    'old_box',
    aliasedName,
    true,
    check: () => oldBox.isNull() | ComparableExpr(oldBox).isBetweenValues(1, 8),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newBoxMeta = const VerificationMeta('newBox');
  @override
  late final GeneratedColumn<int> newBox = GeneratedColumn<int>(
    'new_box',
    aliasedName,
    true,
    check: () => newBox.isNull() | ComparableExpr(newBox).isBetweenValues(1, 8),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextDueAtMeta = const VerificationMeta(
    'nextDueAt',
  );
  @override
  late final GeneratedColumn<int> nextDueAt = GeneratedColumn<int>(
    'next_due_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<int> answeredAt = GeneratedColumn<int>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    sessionItemId,
    flashcardId,
    attemptNumber,
    result,
    oldBox,
    newBox,
    nextDueAt,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('session_item_id')) {
      context.handle(
        _sessionItemIdMeta,
        sessionItemId.isAcceptableOrUnknown(
          data['session_item_id']!,
          _sessionItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionItemIdMeta);
    }
    if (data.containsKey('flashcard_id')) {
      context.handle(
        _flashcardIdMeta,
        flashcardId.isAcceptableOrUnknown(
          data['flashcard_id']!,
          _flashcardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_flashcardIdMeta);
    }
    if (data.containsKey('attempt_number')) {
      context.handle(
        _attemptNumberMeta,
        attemptNumber.isAcceptableOrUnknown(
          data['attempt_number']!,
          _attemptNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attemptNumberMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('old_box')) {
      context.handle(
        _oldBoxMeta,
        oldBox.isAcceptableOrUnknown(data['old_box']!, _oldBoxMeta),
      );
    }
    if (data.containsKey('new_box')) {
      context.handle(
        _newBoxMeta,
        newBox.isAcceptableOrUnknown(data['new_box']!, _newBoxMeta),
      );
    }
    if (data.containsKey('next_due_at')) {
      context.handle(
        _nextDueAtMeta,
        nextDueAt.isAcceptableOrUnknown(data['next_due_at']!, _nextDueAtMeta),
      );
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudyAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyAttempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      sessionItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_item_id'],
      )!,
      flashcardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flashcard_id'],
      )!,
      attemptNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_number'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      oldBox: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}old_box'],
      ),
      newBox: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_box'],
      ),
      nextDueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_due_at'],
      ),
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_at'],
      )!,
    );
  }

  @override
  $StudyAttemptsTable createAlias(String alias) {
    return $StudyAttemptsTable(attachedDatabase, alias);
  }
}

class StudyAttempt extends DataClass implements Insertable<StudyAttempt> {
  final String id;
  final String sessionId;
  final String sessionItemId;
  final String flashcardId;
  final int attemptNumber;
  final String result;
  final int? oldBox;
  final int? newBox;
  final int? nextDueAt;
  final int answeredAt;
  const StudyAttempt({
    required this.id,
    required this.sessionId,
    required this.sessionItemId,
    required this.flashcardId,
    required this.attemptNumber,
    required this.result,
    this.oldBox,
    this.newBox,
    this.nextDueAt,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['session_item_id'] = Variable<String>(sessionItemId);
    map['flashcard_id'] = Variable<String>(flashcardId);
    map['attempt_number'] = Variable<int>(attemptNumber);
    map['result'] = Variable<String>(result);
    if (!nullToAbsent || oldBox != null) {
      map['old_box'] = Variable<int>(oldBox);
    }
    if (!nullToAbsent || newBox != null) {
      map['new_box'] = Variable<int>(newBox);
    }
    if (!nullToAbsent || nextDueAt != null) {
      map['next_due_at'] = Variable<int>(nextDueAt);
    }
    map['answered_at'] = Variable<int>(answeredAt);
    return map;
  }

  StudyAttemptsCompanion toCompanion(bool nullToAbsent) {
    return StudyAttemptsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      sessionItemId: Value(sessionItemId),
      flashcardId: Value(flashcardId),
      attemptNumber: Value(attemptNumber),
      result: Value(result),
      oldBox: oldBox == null && nullToAbsent
          ? const Value.absent()
          : Value(oldBox),
      newBox: newBox == null && nullToAbsent
          ? const Value.absent()
          : Value(newBox),
      nextDueAt: nextDueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueAt),
      answeredAt: Value(answeredAt),
    );
  }

  factory StudyAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyAttempt(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      sessionItemId: serializer.fromJson<String>(json['sessionItemId']),
      flashcardId: serializer.fromJson<String>(json['flashcardId']),
      attemptNumber: serializer.fromJson<int>(json['attemptNumber']),
      result: serializer.fromJson<String>(json['result']),
      oldBox: serializer.fromJson<int?>(json['oldBox']),
      newBox: serializer.fromJson<int?>(json['newBox']),
      nextDueAt: serializer.fromJson<int?>(json['nextDueAt']),
      answeredAt: serializer.fromJson<int>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'sessionItemId': serializer.toJson<String>(sessionItemId),
      'flashcardId': serializer.toJson<String>(flashcardId),
      'attemptNumber': serializer.toJson<int>(attemptNumber),
      'result': serializer.toJson<String>(result),
      'oldBox': serializer.toJson<int?>(oldBox),
      'newBox': serializer.toJson<int?>(newBox),
      'nextDueAt': serializer.toJson<int?>(nextDueAt),
      'answeredAt': serializer.toJson<int>(answeredAt),
    };
  }

  StudyAttempt copyWith({
    String? id,
    String? sessionId,
    String? sessionItemId,
    String? flashcardId,
    int? attemptNumber,
    String? result,
    Value<int?> oldBox = const Value.absent(),
    Value<int?> newBox = const Value.absent(),
    Value<int?> nextDueAt = const Value.absent(),
    int? answeredAt,
  }) => StudyAttempt(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    sessionItemId: sessionItemId ?? this.sessionItemId,
    flashcardId: flashcardId ?? this.flashcardId,
    attemptNumber: attemptNumber ?? this.attemptNumber,
    result: result ?? this.result,
    oldBox: oldBox.present ? oldBox.value : this.oldBox,
    newBox: newBox.present ? newBox.value : this.newBox,
    nextDueAt: nextDueAt.present ? nextDueAt.value : this.nextDueAt,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  StudyAttempt copyWithCompanion(StudyAttemptsCompanion data) {
    return StudyAttempt(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      sessionItemId: data.sessionItemId.present
          ? data.sessionItemId.value
          : this.sessionItemId,
      flashcardId: data.flashcardId.present
          ? data.flashcardId.value
          : this.flashcardId,
      attemptNumber: data.attemptNumber.present
          ? data.attemptNumber.value
          : this.attemptNumber,
      result: data.result.present ? data.result.value : this.result,
      oldBox: data.oldBox.present ? data.oldBox.value : this.oldBox,
      newBox: data.newBox.present ? data.newBox.value : this.newBox,
      nextDueAt: data.nextDueAt.present ? data.nextDueAt.value : this.nextDueAt,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyAttempt(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('sessionItemId: $sessionItemId, ')
          ..write('flashcardId: $flashcardId, ')
          ..write('attemptNumber: $attemptNumber, ')
          ..write('result: $result, ')
          ..write('oldBox: $oldBox, ')
          ..write('newBox: $newBox, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    sessionItemId,
    flashcardId,
    attemptNumber,
    result,
    oldBox,
    newBox,
    nextDueAt,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyAttempt &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.sessionItemId == this.sessionItemId &&
          other.flashcardId == this.flashcardId &&
          other.attemptNumber == this.attemptNumber &&
          other.result == this.result &&
          other.oldBox == this.oldBox &&
          other.newBox == this.newBox &&
          other.nextDueAt == this.nextDueAt &&
          other.answeredAt == this.answeredAt);
}

class StudyAttemptsCompanion extends UpdateCompanion<StudyAttempt> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> sessionItemId;
  final Value<String> flashcardId;
  final Value<int> attemptNumber;
  final Value<String> result;
  final Value<int?> oldBox;
  final Value<int?> newBox;
  final Value<int?> nextDueAt;
  final Value<int> answeredAt;
  final Value<int> rowid;
  const StudyAttemptsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.sessionItemId = const Value.absent(),
    this.flashcardId = const Value.absent(),
    this.attemptNumber = const Value.absent(),
    this.result = const Value.absent(),
    this.oldBox = const Value.absent(),
    this.newBox = const Value.absent(),
    this.nextDueAt = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyAttemptsCompanion.insert({
    required String id,
    required String sessionId,
    required String sessionItemId,
    required String flashcardId,
    required int attemptNumber,
    required String result,
    this.oldBox = const Value.absent(),
    this.newBox = const Value.absent(),
    this.nextDueAt = const Value.absent(),
    required int answeredAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       sessionItemId = Value(sessionItemId),
       flashcardId = Value(flashcardId),
       attemptNumber = Value(attemptNumber),
       result = Value(result),
       answeredAt = Value(answeredAt);
  static Insertable<StudyAttempt> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? sessionItemId,
    Expression<String>? flashcardId,
    Expression<int>? attemptNumber,
    Expression<String>? result,
    Expression<int>? oldBox,
    Expression<int>? newBox,
    Expression<int>? nextDueAt,
    Expression<int>? answeredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (sessionItemId != null) 'session_item_id': sessionItemId,
      if (flashcardId != null) 'flashcard_id': flashcardId,
      if (attemptNumber != null) 'attempt_number': attemptNumber,
      if (result != null) 'result': result,
      if (oldBox != null) 'old_box': oldBox,
      if (newBox != null) 'new_box': newBox,
      if (nextDueAt != null) 'next_due_at': nextDueAt,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyAttemptsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? sessionItemId,
    Value<String>? flashcardId,
    Value<int>? attemptNumber,
    Value<String>? result,
    Value<int?>? oldBox,
    Value<int?>? newBox,
    Value<int?>? nextDueAt,
    Value<int>? answeredAt,
    Value<int>? rowid,
  }) {
    return StudyAttemptsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      sessionItemId: sessionItemId ?? this.sessionItemId,
      flashcardId: flashcardId ?? this.flashcardId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      result: result ?? this.result,
      oldBox: oldBox ?? this.oldBox,
      newBox: newBox ?? this.newBox,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      answeredAt: answeredAt ?? this.answeredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (sessionItemId.present) {
      map['session_item_id'] = Variable<String>(sessionItemId.value);
    }
    if (flashcardId.present) {
      map['flashcard_id'] = Variable<String>(flashcardId.value);
    }
    if (attemptNumber.present) {
      map['attempt_number'] = Variable<int>(attemptNumber.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (oldBox.present) {
      map['old_box'] = Variable<int>(oldBox.value);
    }
    if (newBox.present) {
      map['new_box'] = Variable<int>(newBox.value);
    }
    if (nextDueAt.present) {
      map['next_due_at'] = Variable<int>(nextDueAt.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<int>(answeredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('sessionItemId: $sessionItemId, ')
          ..write('flashcardId: $flashcardId, ')
          ..write('attemptNumber: $attemptNumber, ')
          ..write('result: $result, ')
          ..write('oldBox: $oldBox, ')
          ..write('newBox: $newBox, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $DecksTable decks = $DecksTable(this);
  late final $FlashcardsTable flashcards = $FlashcardsTable(this);
  late final $FlashcardProgressTable flashcardProgress =
      $FlashcardProgressTable(this);
  late final $StudySessionsTable studySessions = $StudySessionsTable(this);
  late final $StudySessionItemsTable studySessionItems =
      $StudySessionItemsTable(this);
  late final $StudyAttemptsTable studyAttempts = $StudyAttemptsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    folders,
    decks,
    flashcards,
    flashcardProgress,
    studySessions,
    studySessionItems,
    studyAttempts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'folders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('folders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'folders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('decks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'decks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('flashcards', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'flashcards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('flashcard_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'study_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('study_session_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'flashcards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('study_session_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'study_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('study_attempts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'study_session_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('study_attempts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'flashcards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('study_attempts', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$FoldersTableCreateCompanionBuilder =
    FoldersCompanion Function({
      required String id,
      Value<String?> parentId,
      required String name,
      required String contentMode,
      required int sortOrder,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$FoldersTableUpdateCompanionBuilder =
    FoldersCompanion Function({
      Value<String> id,
      Value<String?> parentId,
      Value<String> name,
      Value<String> contentMode,
      Value<int> sortOrder,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$FoldersTableReferences
    extends BaseReferences<_$AppDatabase, $FoldersTable, Folder> {
  $$FoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _parentIdTable(_$AppDatabase db) => db.folders
      .createAlias($_aliasNameGenerator(db.folders.parentId, db.folders.id));

  $$FoldersTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DecksTable, List<Deck>> _decksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.decks,
    aliasName: $_aliasNameGenerator(db.folders.id, db.decks.folderId),
  );

  $$DecksTableProcessedTableManager get decksRefs {
    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_decksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentMode => $composableBuilder(
    column: $table.contentMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FoldersTableFilterComposer get parentId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> decksRefs(
    Expression<bool> Function($$DecksTableFilterComposer f) f,
  ) {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentMode => $composableBuilder(
    column: $table.contentMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoldersTableOrderingComposer get parentId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contentMode => $composableBuilder(
    column: $table.contentMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FoldersTableAnnotationComposer get parentId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> decksRefs<T extends Object>(
    Expression<T> Function($$DecksTableAnnotationComposer a) f,
  ) {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, $$FoldersTableReferences),
          Folder,
          PrefetchHooks Function({bool parentId, bool decksRefs})
        > {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> contentMode = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                parentId: parentId,
                name: name,
                contentMode: contentMode,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> parentId = const Value.absent(),
                required String name,
                required String contentMode,
                required int sortOrder,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion.insert(
                id: id,
                parentId: parentId,
                name: name,
                contentMode: contentMode,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({parentId = false, decksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (decksRefs) db.decks],
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
                    if (parentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.parentId,
                                referencedTable: $$FoldersTableReferences
                                    ._parentIdTable(db),
                                referencedColumn: $$FoldersTableReferences
                                    ._parentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (decksRefs)
                    await $_getPrefetchedData<Folder, $FoldersTable, Deck>(
                      currentTable: table,
                      referencedTable: $$FoldersTableReferences._decksRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$FoldersTableReferences(db, table, p0).decksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, $$FoldersTableReferences),
      Folder,
      PrefetchHooks Function({bool parentId, bool decksRefs})
    >;
typedef $$DecksTableCreateCompanionBuilder =
    DecksCompanion Function({
      required String id,
      required String folderId,
      required String name,
      required int sortOrder,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$DecksTableUpdateCompanionBuilder =
    DecksCompanion Function({
      Value<String> id,
      Value<String> folderId,
      Value<String> name,
      Value<int> sortOrder,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$DecksTableReferences
    extends BaseReferences<_$AppDatabase, $DecksTable, Deck> {
  $$DecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$AppDatabase db) => db.folders
      .createAlias($_aliasNameGenerator(db.decks.folderId, db.folders.id));

  $$FoldersTableProcessedTableManager get folderId {
    final $_column = $_itemColumn<String>('folder_id')!;

    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FlashcardsTable, List<Flashcard>>
  _flashcardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.flashcards,
    aliasName: $_aliasNameGenerator(db.decks.id, db.flashcards.deckId),
  );

  $$FlashcardsTableProcessedTableManager get flashcardsRefs {
    final manager = $$FlashcardsTableTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_flashcardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DecksTableFilterComposer extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> flashcardsRefs(
    Expression<bool> Function($$FlashcardsTableFilterComposer f) f,
  ) {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableOrderingComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FoldersTableAnnotationComposer get folderId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> flashcardsRefs<T extends Object>(
    Expression<T> Function($$FlashcardsTableAnnotationComposer a) f,
  ) {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DecksTable,
          Deck,
          $$DecksTableFilterComposer,
          $$DecksTableOrderingComposer,
          $$DecksTableAnnotationComposer,
          $$DecksTableCreateCompanionBuilder,
          $$DecksTableUpdateCompanionBuilder,
          (Deck, $$DecksTableReferences),
          Deck,
          PrefetchHooks Function({bool folderId, bool flashcardsRefs})
        > {
  $$DecksTableTableManager(_$AppDatabase db, $DecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> folderId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion(
                id: id,
                folderId: folderId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String folderId,
                required String name,
                required int sortOrder,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion.insert(
                id: id,
                folderId: folderId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$DecksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false, flashcardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (flashcardsRefs) db.flashcards],
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
                    if (folderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.folderId,
                                referencedTable: $$DecksTableReferences
                                    ._folderIdTable(db),
                                referencedColumn: $$DecksTableReferences
                                    ._folderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (flashcardsRefs)
                    await $_getPrefetchedData<Deck, $DecksTable, Flashcard>(
                      currentTable: table,
                      referencedTable: $$DecksTableReferences
                          ._flashcardsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DecksTableReferences(db, table, p0).flashcardsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.deckId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DecksTable,
      Deck,
      $$DecksTableFilterComposer,
      $$DecksTableOrderingComposer,
      $$DecksTableAnnotationComposer,
      $$DecksTableCreateCompanionBuilder,
      $$DecksTableUpdateCompanionBuilder,
      (Deck, $$DecksTableReferences),
      Deck,
      PrefetchHooks Function({bool folderId, bool flashcardsRefs})
    >;
typedef $$FlashcardsTableCreateCompanionBuilder =
    FlashcardsCompanion Function({
      required String id,
      required String deckId,
      required String front,
      required String back,
      Value<String?> note,
      required int sortOrder,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$FlashcardsTableUpdateCompanionBuilder =
    FlashcardsCompanion Function({
      Value<String> id,
      Value<String> deckId,
      Value<String> front,
      Value<String> back,
      Value<String?> note,
      Value<int> sortOrder,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$FlashcardsTableReferences
    extends BaseReferences<_$AppDatabase, $FlashcardsTable, Flashcard> {
  $$FlashcardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DecksTable _deckIdTable(_$AppDatabase db) => db.decks.createAlias(
    $_aliasNameGenerator(db.flashcards.deckId, db.decks.id),
  );

  $$DecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<String>('deck_id')!;

    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $FlashcardProgressTable,
    List<FlashcardProgressData>
  >
  _flashcardProgressRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.flashcardProgress,
        aliasName: $_aliasNameGenerator(
          db.flashcards.id,
          db.flashcardProgress.flashcardId,
        ),
      );

  $$FlashcardProgressTableProcessedTableManager get flashcardProgressRefs {
    final manager = $$FlashcardProgressTableTableManager(
      $_db,
      $_db.flashcardProgress,
    ).filter((f) => f.flashcardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _flashcardProgressRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StudySessionItemsTable, List<StudySessionItem>>
  _studySessionItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.studySessionItems,
        aliasName: $_aliasNameGenerator(
          db.flashcards.id,
          db.studySessionItems.flashcardId,
        ),
      );

  $$StudySessionItemsTableProcessedTableManager get studySessionItemsRefs {
    final manager = $$StudySessionItemsTableTableManager(
      $_db,
      $_db.studySessionItems,
    ).filter((f) => f.flashcardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _studySessionItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StudyAttemptsTable, List<StudyAttempt>>
  _studyAttemptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.studyAttempts,
    aliasName: $_aliasNameGenerator(
      db.flashcards.id,
      db.studyAttempts.flashcardId,
    ),
  );

  $$StudyAttemptsTableProcessedTableManager get studyAttemptsRefs {
    final manager = $$StudyAttemptsTableTableManager(
      $_db,
      $_db.studyAttempts,
    ).filter((f) => f.flashcardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_studyAttemptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FlashcardsTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get front => $composableBuilder(
    column: $table.front,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get back => $composableBuilder(
    column: $table.back,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DecksTableFilterComposer get deckId {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> flashcardProgressRefs(
    Expression<bool> Function($$FlashcardProgressTableFilterComposer f) f,
  ) {
    final $$FlashcardProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcardProgress,
      getReferencedColumn: (t) => t.flashcardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardProgressTableFilterComposer(
            $db: $db,
            $table: $db.flashcardProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> studySessionItemsRefs(
    Expression<bool> Function($$StudySessionItemsTableFilterComposer f) f,
  ) {
    final $$StudySessionItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studySessionItems,
      getReferencedColumn: (t) => t.flashcardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionItemsTableFilterComposer(
            $db: $db,
            $table: $db.studySessionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> studyAttemptsRefs(
    Expression<bool> Function($$StudyAttemptsTableFilterComposer f) f,
  ) {
    final $$StudyAttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyAttempts,
      getReferencedColumn: (t) => t.flashcardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyAttemptsTableFilterComposer(
            $db: $db,
            $table: $db.studyAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FlashcardsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get front => $composableBuilder(
    column: $table.front,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get back => $composableBuilder(
    column: $table.back,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DecksTableOrderingComposer get deckId {
    final $$DecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableOrderingComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlashcardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get front =>
      $composableBuilder(column: $table.front, builder: (column) => column);

  GeneratedColumn<String> get back =>
      $composableBuilder(column: $table.back, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DecksTableAnnotationComposer get deckId {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> flashcardProgressRefs<T extends Object>(
    Expression<T> Function($$FlashcardProgressTableAnnotationComposer a) f,
  ) {
    final $$FlashcardProgressTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.flashcardProgress,
          getReferencedColumn: (t) => t.flashcardId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FlashcardProgressTableAnnotationComposer(
                $db: $db,
                $table: $db.flashcardProgress,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> studySessionItemsRefs<T extends Object>(
    Expression<T> Function($$StudySessionItemsTableAnnotationComposer a) f,
  ) {
    final $$StudySessionItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.studySessionItems,
          getReferencedColumn: (t) => t.flashcardId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StudySessionItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.studySessionItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> studyAttemptsRefs<T extends Object>(
    Expression<T> Function($$StudyAttemptsTableAnnotationComposer a) f,
  ) {
    final $$StudyAttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyAttempts,
      getReferencedColumn: (t) => t.flashcardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyAttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.studyAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FlashcardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlashcardsTable,
          Flashcard,
          $$FlashcardsTableFilterComposer,
          $$FlashcardsTableOrderingComposer,
          $$FlashcardsTableAnnotationComposer,
          $$FlashcardsTableCreateCompanionBuilder,
          $$FlashcardsTableUpdateCompanionBuilder,
          (Flashcard, $$FlashcardsTableReferences),
          Flashcard,
          PrefetchHooks Function({
            bool deckId,
            bool flashcardProgressRefs,
            bool studySessionItemsRefs,
            bool studyAttemptsRefs,
          })
        > {
  $$FlashcardsTableTableManager(_$AppDatabase db, $FlashcardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deckId = const Value.absent(),
                Value<String> front = const Value.absent(),
                Value<String> back = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlashcardsCompanion(
                id: id,
                deckId: deckId,
                front: front,
                back: back,
                note: note,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deckId,
                required String front,
                required String back,
                Value<String?> note = const Value.absent(),
                required int sortOrder,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FlashcardsCompanion.insert(
                id: id,
                deckId: deckId,
                front: front,
                back: back,
                note: note,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FlashcardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                deckId = false,
                flashcardProgressRefs = false,
                studySessionItemsRefs = false,
                studyAttemptsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (flashcardProgressRefs) db.flashcardProgress,
                    if (studySessionItemsRefs) db.studySessionItems,
                    if (studyAttemptsRefs) db.studyAttempts,
                  ],
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
                        if (deckId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.deckId,
                                    referencedTable: $$FlashcardsTableReferences
                                        ._deckIdTable(db),
                                    referencedColumn:
                                        $$FlashcardsTableReferences
                                            ._deckIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (flashcardProgressRefs)
                        await $_getPrefetchedData<
                          Flashcard,
                          $FlashcardsTable,
                          FlashcardProgressData
                        >(
                          currentTable: table,
                          referencedTable: $$FlashcardsTableReferences
                              ._flashcardProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FlashcardsTableReferences(
                                db,
                                table,
                                p0,
                              ).flashcardProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.flashcardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (studySessionItemsRefs)
                        await $_getPrefetchedData<
                          Flashcard,
                          $FlashcardsTable,
                          StudySessionItem
                        >(
                          currentTable: table,
                          referencedTable: $$FlashcardsTableReferences
                              ._studySessionItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FlashcardsTableReferences(
                                db,
                                table,
                                p0,
                              ).studySessionItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.flashcardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (studyAttemptsRefs)
                        await $_getPrefetchedData<
                          Flashcard,
                          $FlashcardsTable,
                          StudyAttempt
                        >(
                          currentTable: table,
                          referencedTable: $$FlashcardsTableReferences
                              ._studyAttemptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FlashcardsTableReferences(
                                db,
                                table,
                                p0,
                              ).studyAttemptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.flashcardId == item.id,
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

typedef $$FlashcardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlashcardsTable,
      Flashcard,
      $$FlashcardsTableFilterComposer,
      $$FlashcardsTableOrderingComposer,
      $$FlashcardsTableAnnotationComposer,
      $$FlashcardsTableCreateCompanionBuilder,
      $$FlashcardsTableUpdateCompanionBuilder,
      (Flashcard, $$FlashcardsTableReferences),
      Flashcard,
      PrefetchHooks Function({
        bool deckId,
        bool flashcardProgressRefs,
        bool studySessionItemsRefs,
        bool studyAttemptsRefs,
      })
    >;
typedef $$FlashcardProgressTableCreateCompanionBuilder =
    FlashcardProgressCompanion Function({
      required String flashcardId,
      required int currentBox,
      required int reviewCount,
      required int lapseCount,
      Value<String?> lastResult,
      Value<int?> lastStudiedAt,
      Value<int?> dueAt,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$FlashcardProgressTableUpdateCompanionBuilder =
    FlashcardProgressCompanion Function({
      Value<String> flashcardId,
      Value<int> currentBox,
      Value<int> reviewCount,
      Value<int> lapseCount,
      Value<String?> lastResult,
      Value<int?> lastStudiedAt,
      Value<int?> dueAt,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$FlashcardProgressTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FlashcardProgressTable,
          FlashcardProgressData
        > {
  $$FlashcardProgressTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FlashcardsTable _flashcardIdTable(_$AppDatabase db) =>
      db.flashcards.createAlias(
        $_aliasNameGenerator(
          db.flashcardProgress.flashcardId,
          db.flashcards.id,
        ),
      );

  $$FlashcardsTableProcessedTableManager get flashcardId {
    final $_column = $_itemColumn<String>('flashcard_id')!;

    final manager = $$FlashcardsTableTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_flashcardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FlashcardProgressTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardProgressTable> {
  $$FlashcardProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get currentBox => $composableBuilder(
    column: $table.currentBox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapseCount => $composableBuilder(
    column: $table.lapseCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastResult => $composableBuilder(
    column: $table.lastResult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastStudiedAt => $composableBuilder(
    column: $table.lastStudiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FlashcardsTableFilterComposer get flashcardId {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlashcardProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardProgressTable> {
  $$FlashcardProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get currentBox => $composableBuilder(
    column: $table.currentBox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapseCount => $composableBuilder(
    column: $table.lapseCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastResult => $composableBuilder(
    column: $table.lastResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastStudiedAt => $composableBuilder(
    column: $table.lastStudiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FlashcardsTableOrderingComposer get flashcardId {
    final $$FlashcardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableOrderingComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlashcardProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardProgressTable> {
  $$FlashcardProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get currentBox => $composableBuilder(
    column: $table.currentBox,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lapseCount => $composableBuilder(
    column: $table.lapseCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastResult => $composableBuilder(
    column: $table.lastResult,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastStudiedAt => $composableBuilder(
    column: $table.lastStudiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FlashcardsTableAnnotationComposer get flashcardId {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlashcardProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlashcardProgressTable,
          FlashcardProgressData,
          $$FlashcardProgressTableFilterComposer,
          $$FlashcardProgressTableOrderingComposer,
          $$FlashcardProgressTableAnnotationComposer,
          $$FlashcardProgressTableCreateCompanionBuilder,
          $$FlashcardProgressTableUpdateCompanionBuilder,
          (FlashcardProgressData, $$FlashcardProgressTableReferences),
          FlashcardProgressData,
          PrefetchHooks Function({bool flashcardId})
        > {
  $$FlashcardProgressTableTableManager(
    _$AppDatabase db,
    $FlashcardProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardProgressTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> flashcardId = const Value.absent(),
                Value<int> currentBox = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
                Value<int> lapseCount = const Value.absent(),
                Value<String?> lastResult = const Value.absent(),
                Value<int?> lastStudiedAt = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlashcardProgressCompanion(
                flashcardId: flashcardId,
                currentBox: currentBox,
                reviewCount: reviewCount,
                lapseCount: lapseCount,
                lastResult: lastResult,
                lastStudiedAt: lastStudiedAt,
                dueAt: dueAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String flashcardId,
                required int currentBox,
                required int reviewCount,
                required int lapseCount,
                Value<String?> lastResult = const Value.absent(),
                Value<int?> lastStudiedAt = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FlashcardProgressCompanion.insert(
                flashcardId: flashcardId,
                currentBox: currentBox,
                reviewCount: reviewCount,
                lapseCount: lapseCount,
                lastResult: lastResult,
                lastStudiedAt: lastStudiedAt,
                dueAt: dueAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FlashcardProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({flashcardId = false}) {
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
                    if (flashcardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.flashcardId,
                                referencedTable:
                                    $$FlashcardProgressTableReferences
                                        ._flashcardIdTable(db),
                                referencedColumn:
                                    $$FlashcardProgressTableReferences
                                        ._flashcardIdTable(db)
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

typedef $$FlashcardProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlashcardProgressTable,
      FlashcardProgressData,
      $$FlashcardProgressTableFilterComposer,
      $$FlashcardProgressTableOrderingComposer,
      $$FlashcardProgressTableAnnotationComposer,
      $$FlashcardProgressTableCreateCompanionBuilder,
      $$FlashcardProgressTableUpdateCompanionBuilder,
      (FlashcardProgressData, $$FlashcardProgressTableReferences),
      FlashcardProgressData,
      PrefetchHooks Function({bool flashcardId})
    >;
typedef $$StudySessionsTableCreateCompanionBuilder =
    StudySessionsCompanion Function({
      required String id,
      required String entryType,
      Value<String?> entryRefId,
      required String studyType,
      required String studyFlow,
      required int batchSize,
      required int shuffleFlashcards,
      required int shuffleAnswers,
      required int prioritizeOverdue,
      required String status,
      required int startedAt,
      Value<int?> endedAt,
      Value<String?> restartedFromSessionId,
      Value<int> rowid,
    });
typedef $$StudySessionsTableUpdateCompanionBuilder =
    StudySessionsCompanion Function({
      Value<String> id,
      Value<String> entryType,
      Value<String?> entryRefId,
      Value<String> studyType,
      Value<String> studyFlow,
      Value<int> batchSize,
      Value<int> shuffleFlashcards,
      Value<int> shuffleAnswers,
      Value<int> prioritizeOverdue,
      Value<String> status,
      Value<int> startedAt,
      Value<int?> endedAt,
      Value<String?> restartedFromSessionId,
      Value<int> rowid,
    });

final class $$StudySessionsTableReferences
    extends BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession> {
  $$StudySessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudySessionsTable _restartedFromSessionIdTable(_$AppDatabase db) =>
      db.studySessions.createAlias(
        $_aliasNameGenerator(
          db.studySessions.restartedFromSessionId,
          db.studySessions.id,
        ),
      );

  $$StudySessionsTableProcessedTableManager? get restartedFromSessionId {
    final $_column = $_itemColumn<String>('restarted_from_session_id');
    if ($_column == null) return null;
    final manager = $$StudySessionsTableTableManager(
      $_db,
      $_db.studySessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _restartedFromSessionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StudySessionItemsTable, List<StudySessionItem>>
  _studySessionItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.studySessionItems,
        aliasName: $_aliasNameGenerator(
          db.studySessions.id,
          db.studySessionItems.sessionId,
        ),
      );

  $$StudySessionItemsTableProcessedTableManager get studySessionItemsRefs {
    final manager = $$StudySessionItemsTableTableManager(
      $_db,
      $_db.studySessionItems,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _studySessionItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StudyAttemptsTable, List<StudyAttempt>>
  _studyAttemptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.studyAttempts,
    aliasName: $_aliasNameGenerator(
      db.studySessions.id,
      db.studyAttempts.sessionId,
    ),
  );

  $$StudyAttemptsTableProcessedTableManager get studyAttemptsRefs {
    final manager = $$StudyAttemptsTableTableManager(
      $_db,
      $_db.studyAttempts,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_studyAttemptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryRefId => $composableBuilder(
    column: $table.entryRefId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studyType => $composableBuilder(
    column: $table.studyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studyFlow => $composableBuilder(
    column: $table.studyFlow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batchSize => $composableBuilder(
    column: $table.batchSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shuffleFlashcards => $composableBuilder(
    column: $table.shuffleFlashcards,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shuffleAnswers => $composableBuilder(
    column: $table.shuffleAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prioritizeOverdue => $composableBuilder(
    column: $table.prioritizeOverdue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StudySessionsTableFilterComposer get restartedFromSessionId {
    final $$StudySessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restartedFromSessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableFilterComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> studySessionItemsRefs(
    Expression<bool> Function($$StudySessionItemsTableFilterComposer f) f,
  ) {
    final $$StudySessionItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studySessionItems,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionItemsTableFilterComposer(
            $db: $db,
            $table: $db.studySessionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> studyAttemptsRefs(
    Expression<bool> Function($$StudyAttemptsTableFilterComposer f) f,
  ) {
    final $$StudyAttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyAttempts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyAttemptsTableFilterComposer(
            $db: $db,
            $table: $db.studyAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryRefId => $composableBuilder(
    column: $table.entryRefId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studyType => $composableBuilder(
    column: $table.studyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studyFlow => $composableBuilder(
    column: $table.studyFlow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batchSize => $composableBuilder(
    column: $table.batchSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shuffleFlashcards => $composableBuilder(
    column: $table.shuffleFlashcards,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shuffleAnswers => $composableBuilder(
    column: $table.shuffleAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prioritizeOverdue => $composableBuilder(
    column: $table.prioritizeOverdue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudySessionsTableOrderingComposer get restartedFromSessionId {
    final $$StudySessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restartedFromSessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableOrderingComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<String> get entryRefId => $composableBuilder(
    column: $table.entryRefId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get studyType =>
      $composableBuilder(column: $table.studyType, builder: (column) => column);

  GeneratedColumn<String> get studyFlow =>
      $composableBuilder(column: $table.studyFlow, builder: (column) => column);

  GeneratedColumn<int> get batchSize =>
      $composableBuilder(column: $table.batchSize, builder: (column) => column);

  GeneratedColumn<int> get shuffleFlashcards => $composableBuilder(
    column: $table.shuffleFlashcards,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shuffleAnswers => $composableBuilder(
    column: $table.shuffleAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get prioritizeOverdue => $composableBuilder(
    column: $table.prioritizeOverdue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  $$StudySessionsTableAnnotationComposer get restartedFromSessionId {
    final $$StudySessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restartedFromSessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> studySessionItemsRefs<T extends Object>(
    Expression<T> Function($$StudySessionItemsTableAnnotationComposer a) f,
  ) {
    final $$StudySessionItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.studySessionItems,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StudySessionItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.studySessionItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> studyAttemptsRefs<T extends Object>(
    Expression<T> Function($$StudyAttemptsTableAnnotationComposer a) f,
  ) {
    final $$StudyAttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyAttempts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyAttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.studyAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudySessionsTable,
          StudySession,
          $$StudySessionsTableFilterComposer,
          $$StudySessionsTableOrderingComposer,
          $$StudySessionsTableAnnotationComposer,
          $$StudySessionsTableCreateCompanionBuilder,
          $$StudySessionsTableUpdateCompanionBuilder,
          (StudySession, $$StudySessionsTableReferences),
          StudySession,
          PrefetchHooks Function({
            bool restartedFromSessionId,
            bool studySessionItemsRefs,
            bool studyAttemptsRefs,
          })
        > {
  $$StudySessionsTableTableManager(_$AppDatabase db, $StudySessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entryType = const Value.absent(),
                Value<String?> entryRefId = const Value.absent(),
                Value<String> studyType = const Value.absent(),
                Value<String> studyFlow = const Value.absent(),
                Value<int> batchSize = const Value.absent(),
                Value<int> shuffleFlashcards = const Value.absent(),
                Value<int> shuffleAnswers = const Value.absent(),
                Value<int> prioritizeOverdue = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<String?> restartedFromSessionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudySessionsCompanion(
                id: id,
                entryType: entryType,
                entryRefId: entryRefId,
                studyType: studyType,
                studyFlow: studyFlow,
                batchSize: batchSize,
                shuffleFlashcards: shuffleFlashcards,
                shuffleAnswers: shuffleAnswers,
                prioritizeOverdue: prioritizeOverdue,
                status: status,
                startedAt: startedAt,
                endedAt: endedAt,
                restartedFromSessionId: restartedFromSessionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entryType,
                Value<String?> entryRefId = const Value.absent(),
                required String studyType,
                required String studyFlow,
                required int batchSize,
                required int shuffleFlashcards,
                required int shuffleAnswers,
                required int prioritizeOverdue,
                required String status,
                required int startedAt,
                Value<int?> endedAt = const Value.absent(),
                Value<String?> restartedFromSessionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudySessionsCompanion.insert(
                id: id,
                entryType: entryType,
                entryRefId: entryRefId,
                studyType: studyType,
                studyFlow: studyFlow,
                batchSize: batchSize,
                shuffleFlashcards: shuffleFlashcards,
                shuffleAnswers: shuffleAnswers,
                prioritizeOverdue: prioritizeOverdue,
                status: status,
                startedAt: startedAt,
                endedAt: endedAt,
                restartedFromSessionId: restartedFromSessionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudySessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                restartedFromSessionId = false,
                studySessionItemsRefs = false,
                studyAttemptsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (studySessionItemsRefs) db.studySessionItems,
                    if (studyAttemptsRefs) db.studyAttempts,
                  ],
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
                        if (restartedFromSessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.restartedFromSessionId,
                                    referencedTable:
                                        $$StudySessionsTableReferences
                                            ._restartedFromSessionIdTable(db),
                                    referencedColumn:
                                        $$StudySessionsTableReferences
                                            ._restartedFromSessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (studySessionItemsRefs)
                        await $_getPrefetchedData<
                          StudySession,
                          $StudySessionsTable,
                          StudySessionItem
                        >(
                          currentTable: table,
                          referencedTable: $$StudySessionsTableReferences
                              ._studySessionItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudySessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).studySessionItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (studyAttemptsRefs)
                        await $_getPrefetchedData<
                          StudySession,
                          $StudySessionsTable,
                          StudyAttempt
                        >(
                          currentTable: table,
                          referencedTable: $$StudySessionsTableReferences
                              ._studyAttemptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudySessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).studyAttemptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
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

typedef $$StudySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudySessionsTable,
      StudySession,
      $$StudySessionsTableFilterComposer,
      $$StudySessionsTableOrderingComposer,
      $$StudySessionsTableAnnotationComposer,
      $$StudySessionsTableCreateCompanionBuilder,
      $$StudySessionsTableUpdateCompanionBuilder,
      (StudySession, $$StudySessionsTableReferences),
      StudySession,
      PrefetchHooks Function({
        bool restartedFromSessionId,
        bool studySessionItemsRefs,
        bool studyAttemptsRefs,
      })
    >;
typedef $$StudySessionItemsTableCreateCompanionBuilder =
    StudySessionItemsCompanion Function({
      required String id,
      required String sessionId,
      required String flashcardId,
      required String studyMode,
      required int modeOrder,
      required int roundIndex,
      required int queuePosition,
      required String sourcePool,
      required String status,
      Value<int?> completedAt,
      Value<int> rowid,
    });
typedef $$StudySessionItemsTableUpdateCompanionBuilder =
    StudySessionItemsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> flashcardId,
      Value<String> studyMode,
      Value<int> modeOrder,
      Value<int> roundIndex,
      Value<int> queuePosition,
      Value<String> sourcePool,
      Value<String> status,
      Value<int?> completedAt,
      Value<int> rowid,
    });

final class $$StudySessionItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StudySessionItemsTable,
          StudySessionItem
        > {
  $$StudySessionItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudySessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.studySessions.createAlias(
        $_aliasNameGenerator(
          db.studySessionItems.sessionId,
          db.studySessions.id,
        ),
      );

  $$StudySessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$StudySessionsTableTableManager(
      $_db,
      $_db.studySessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FlashcardsTable _flashcardIdTable(_$AppDatabase db) =>
      db.flashcards.createAlias(
        $_aliasNameGenerator(
          db.studySessionItems.flashcardId,
          db.flashcards.id,
        ),
      );

  $$FlashcardsTableProcessedTableManager get flashcardId {
    final $_column = $_itemColumn<String>('flashcard_id')!;

    final manager = $$FlashcardsTableTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_flashcardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StudyAttemptsTable, List<StudyAttempt>>
  _studyAttemptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.studyAttempts,
    aliasName: $_aliasNameGenerator(
      db.studySessionItems.id,
      db.studyAttempts.sessionItemId,
    ),
  );

  $$StudyAttemptsTableProcessedTableManager get studyAttemptsRefs {
    final manager = $$StudyAttemptsTableTableManager(
      $_db,
      $_db.studyAttempts,
    ).filter((f) => f.sessionItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_studyAttemptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudySessionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $StudySessionItemsTable> {
  $$StudySessionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studyMode => $composableBuilder(
    column: $table.studyMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get modeOrder => $composableBuilder(
    column: $table.modeOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get queuePosition => $composableBuilder(
    column: $table.queuePosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourcePool => $composableBuilder(
    column: $table.sourcePool,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StudySessionsTableFilterComposer get sessionId {
    final $$StudySessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableFilterComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FlashcardsTableFilterComposer get flashcardId {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> studyAttemptsRefs(
    Expression<bool> Function($$StudyAttemptsTableFilterComposer f) f,
  ) {
    final $$StudyAttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyAttempts,
      getReferencedColumn: (t) => t.sessionItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyAttemptsTableFilterComposer(
            $db: $db,
            $table: $db.studyAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudySessionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudySessionItemsTable> {
  $$StudySessionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studyMode => $composableBuilder(
    column: $table.studyMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get modeOrder => $composableBuilder(
    column: $table.modeOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get queuePosition => $composableBuilder(
    column: $table.queuePosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourcePool => $composableBuilder(
    column: $table.sourcePool,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudySessionsTableOrderingComposer get sessionId {
    final $$StudySessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableOrderingComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FlashcardsTableOrderingComposer get flashcardId {
    final $$FlashcardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableOrderingComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudySessionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudySessionItemsTable> {
  $$StudySessionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studyMode =>
      $composableBuilder(column: $table.studyMode, builder: (column) => column);

  GeneratedColumn<int> get modeOrder =>
      $composableBuilder(column: $table.modeOrder, builder: (column) => column);

  GeneratedColumn<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get queuePosition => $composableBuilder(
    column: $table.queuePosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourcePool => $composableBuilder(
    column: $table.sourcePool,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$StudySessionsTableAnnotationComposer get sessionId {
    final $$StudySessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FlashcardsTableAnnotationComposer get flashcardId {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> studyAttemptsRefs<T extends Object>(
    Expression<T> Function($$StudyAttemptsTableAnnotationComposer a) f,
  ) {
    final $$StudyAttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyAttempts,
      getReferencedColumn: (t) => t.sessionItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyAttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.studyAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudySessionItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudySessionItemsTable,
          StudySessionItem,
          $$StudySessionItemsTableFilterComposer,
          $$StudySessionItemsTableOrderingComposer,
          $$StudySessionItemsTableAnnotationComposer,
          $$StudySessionItemsTableCreateCompanionBuilder,
          $$StudySessionItemsTableUpdateCompanionBuilder,
          (StudySessionItem, $$StudySessionItemsTableReferences),
          StudySessionItem,
          PrefetchHooks Function({
            bool sessionId,
            bool flashcardId,
            bool studyAttemptsRefs,
          })
        > {
  $$StudySessionItemsTableTableManager(
    _$AppDatabase db,
    $StudySessionItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudySessionItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudySessionItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudySessionItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> flashcardId = const Value.absent(),
                Value<String> studyMode = const Value.absent(),
                Value<int> modeOrder = const Value.absent(),
                Value<int> roundIndex = const Value.absent(),
                Value<int> queuePosition = const Value.absent(),
                Value<String> sourcePool = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudySessionItemsCompanion(
                id: id,
                sessionId: sessionId,
                flashcardId: flashcardId,
                studyMode: studyMode,
                modeOrder: modeOrder,
                roundIndex: roundIndex,
                queuePosition: queuePosition,
                sourcePool: sourcePool,
                status: status,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String flashcardId,
                required String studyMode,
                required int modeOrder,
                required int roundIndex,
                required int queuePosition,
                required String sourcePool,
                required String status,
                Value<int?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudySessionItemsCompanion.insert(
                id: id,
                sessionId: sessionId,
                flashcardId: flashcardId,
                studyMode: studyMode,
                modeOrder: modeOrder,
                roundIndex: roundIndex,
                queuePosition: queuePosition,
                sourcePool: sourcePool,
                status: status,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudySessionItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sessionId = false,
                flashcardId = false,
                studyAttemptsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (studyAttemptsRefs) db.studyAttempts,
                  ],
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
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$StudySessionItemsTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$StudySessionItemsTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (flashcardId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.flashcardId,
                                    referencedTable:
                                        $$StudySessionItemsTableReferences
                                            ._flashcardIdTable(db),
                                    referencedColumn:
                                        $$StudySessionItemsTableReferences
                                            ._flashcardIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (studyAttemptsRefs)
                        await $_getPrefetchedData<
                          StudySessionItem,
                          $StudySessionItemsTable,
                          StudyAttempt
                        >(
                          currentTable: table,
                          referencedTable: $$StudySessionItemsTableReferences
                              ._studyAttemptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudySessionItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).studyAttemptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionItemId == item.id,
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

typedef $$StudySessionItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudySessionItemsTable,
      StudySessionItem,
      $$StudySessionItemsTableFilterComposer,
      $$StudySessionItemsTableOrderingComposer,
      $$StudySessionItemsTableAnnotationComposer,
      $$StudySessionItemsTableCreateCompanionBuilder,
      $$StudySessionItemsTableUpdateCompanionBuilder,
      (StudySessionItem, $$StudySessionItemsTableReferences),
      StudySessionItem,
      PrefetchHooks Function({
        bool sessionId,
        bool flashcardId,
        bool studyAttemptsRefs,
      })
    >;
typedef $$StudyAttemptsTableCreateCompanionBuilder =
    StudyAttemptsCompanion Function({
      required String id,
      required String sessionId,
      required String sessionItemId,
      required String flashcardId,
      required int attemptNumber,
      required String result,
      Value<int?> oldBox,
      Value<int?> newBox,
      Value<int?> nextDueAt,
      required int answeredAt,
      Value<int> rowid,
    });
typedef $$StudyAttemptsTableUpdateCompanionBuilder =
    StudyAttemptsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> sessionItemId,
      Value<String> flashcardId,
      Value<int> attemptNumber,
      Value<String> result,
      Value<int?> oldBox,
      Value<int?> newBox,
      Value<int?> nextDueAt,
      Value<int> answeredAt,
      Value<int> rowid,
    });

final class $$StudyAttemptsTableReferences
    extends BaseReferences<_$AppDatabase, $StudyAttemptsTable, StudyAttempt> {
  $$StudyAttemptsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudySessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.studySessions.createAlias(
        $_aliasNameGenerator(db.studyAttempts.sessionId, db.studySessions.id),
      );

  $$StudySessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$StudySessionsTableTableManager(
      $_db,
      $_db.studySessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudySessionItemsTable _sessionItemIdTable(_$AppDatabase db) =>
      db.studySessionItems.createAlias(
        $_aliasNameGenerator(
          db.studyAttempts.sessionItemId,
          db.studySessionItems.id,
        ),
      );

  $$StudySessionItemsTableProcessedTableManager get sessionItemId {
    final $_column = $_itemColumn<String>('session_item_id')!;

    final manager = $$StudySessionItemsTableTableManager(
      $_db,
      $_db.studySessionItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FlashcardsTable _flashcardIdTable(_$AppDatabase db) =>
      db.flashcards.createAlias(
        $_aliasNameGenerator(db.studyAttempts.flashcardId, db.flashcards.id),
      );

  $$FlashcardsTableProcessedTableManager get flashcardId {
    final $_column = $_itemColumn<String>('flashcard_id')!;

    final manager = $$FlashcardsTableTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_flashcardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StudyAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $StudyAttemptsTable> {
  $$StudyAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptNumber => $composableBuilder(
    column: $table.attemptNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oldBox => $composableBuilder(
    column: $table.oldBox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newBox => $composableBuilder(
    column: $table.newBox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StudySessionsTableFilterComposer get sessionId {
    final $$StudySessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableFilterComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudySessionItemsTableFilterComposer get sessionItemId {
    final $$StudySessionItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionItemId,
      referencedTable: $db.studySessionItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionItemsTableFilterComposer(
            $db: $db,
            $table: $db.studySessionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FlashcardsTableFilterComposer get flashcardId {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudyAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyAttemptsTable> {
  $$StudyAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptNumber => $composableBuilder(
    column: $table.attemptNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oldBox => $composableBuilder(
    column: $table.oldBox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newBox => $composableBuilder(
    column: $table.newBox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudySessionsTableOrderingComposer get sessionId {
    final $$StudySessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableOrderingComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudySessionItemsTableOrderingComposer get sessionItemId {
    final $$StudySessionItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionItemId,
      referencedTable: $db.studySessionItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionItemsTableOrderingComposer(
            $db: $db,
            $table: $db.studySessionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FlashcardsTableOrderingComposer get flashcardId {
    final $$FlashcardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableOrderingComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudyAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyAttemptsTable> {
  $$StudyAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get attemptNumber => $composableBuilder(
    column: $table.attemptNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<int> get oldBox =>
      $composableBuilder(column: $table.oldBox, builder: (column) => column);

  GeneratedColumn<int> get newBox =>
      $composableBuilder(column: $table.newBox, builder: (column) => column);

  GeneratedColumn<int> get nextDueAt =>
      $composableBuilder(column: $table.nextDueAt, builder: (column) => column);

  GeneratedColumn<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  $$StudySessionsTableAnnotationComposer get sessionId {
    final $$StudySessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudySessionItemsTableAnnotationComposer get sessionItemId {
    final $$StudySessionItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionItemId,
          referencedTable: $db.studySessionItems,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StudySessionItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.studySessionItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$FlashcardsTableAnnotationComposer get flashcardId {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudyAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudyAttemptsTable,
          StudyAttempt,
          $$StudyAttemptsTableFilterComposer,
          $$StudyAttemptsTableOrderingComposer,
          $$StudyAttemptsTableAnnotationComposer,
          $$StudyAttemptsTableCreateCompanionBuilder,
          $$StudyAttemptsTableUpdateCompanionBuilder,
          (StudyAttempt, $$StudyAttemptsTableReferences),
          StudyAttempt,
          PrefetchHooks Function({
            bool sessionId,
            bool sessionItemId,
            bool flashcardId,
          })
        > {
  $$StudyAttemptsTableTableManager(_$AppDatabase db, $StudyAttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> sessionItemId = const Value.absent(),
                Value<String> flashcardId = const Value.absent(),
                Value<int> attemptNumber = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<int?> oldBox = const Value.absent(),
                Value<int?> newBox = const Value.absent(),
                Value<int?> nextDueAt = const Value.absent(),
                Value<int> answeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyAttemptsCompanion(
                id: id,
                sessionId: sessionId,
                sessionItemId: sessionItemId,
                flashcardId: flashcardId,
                attemptNumber: attemptNumber,
                result: result,
                oldBox: oldBox,
                newBox: newBox,
                nextDueAt: nextDueAt,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String sessionItemId,
                required String flashcardId,
                required int attemptNumber,
                required String result,
                Value<int?> oldBox = const Value.absent(),
                Value<int?> newBox = const Value.absent(),
                Value<int?> nextDueAt = const Value.absent(),
                required int answeredAt,
                Value<int> rowid = const Value.absent(),
              }) => StudyAttemptsCompanion.insert(
                id: id,
                sessionId: sessionId,
                sessionItemId: sessionItemId,
                flashcardId: flashcardId,
                attemptNumber: attemptNumber,
                result: result,
                oldBox: oldBox,
                newBox: newBox,
                nextDueAt: nextDueAt,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudyAttemptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sessionId = false,
                sessionItemId = false,
                flashcardId = false,
              }) {
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
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$StudyAttemptsTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$StudyAttemptsTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sessionItemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionItemId,
                                    referencedTable:
                                        $$StudyAttemptsTableReferences
                                            ._sessionItemIdTable(db),
                                    referencedColumn:
                                        $$StudyAttemptsTableReferences
                                            ._sessionItemIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (flashcardId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.flashcardId,
                                    referencedTable:
                                        $$StudyAttemptsTableReferences
                                            ._flashcardIdTable(db),
                                    referencedColumn:
                                        $$StudyAttemptsTableReferences
                                            ._flashcardIdTable(db)
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

typedef $$StudyAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudyAttemptsTable,
      StudyAttempt,
      $$StudyAttemptsTableFilterComposer,
      $$StudyAttemptsTableOrderingComposer,
      $$StudyAttemptsTableAnnotationComposer,
      $$StudyAttemptsTableCreateCompanionBuilder,
      $$StudyAttemptsTableUpdateCompanionBuilder,
      (StudyAttempt, $$StudyAttemptsTableReferences),
      StudyAttempt,
      PrefetchHooks Function({
        bool sessionId,
        bool sessionItemId,
        bool flashcardId,
      })
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db, _db.decks);
  $$FlashcardsTableTableManager get flashcards =>
      $$FlashcardsTableTableManager(_db, _db.flashcards);
  $$FlashcardProgressTableTableManager get flashcardProgress =>
      $$FlashcardProgressTableTableManager(_db, _db.flashcardProgress);
  $$StudySessionsTableTableManager get studySessions =>
      $$StudySessionsTableTableManager(_db, _db.studySessions);
  $$StudySessionItemsTableTableManager get studySessionItems =>
      $$StudySessionItemsTableTableManager(_db, _db.studySessionItems);
  $$StudyAttemptsTableTableManager get studyAttempts =>
      $$StudyAttemptsTableTableManager(_db, _db.studyAttempts);
}
