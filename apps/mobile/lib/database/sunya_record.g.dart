// GENERATED CODE - DO NOT MODIFY BY HAND
// Isar 3.1.8 schema for SunyaRecord. Regenerate with build_runner when the model changes.

part of 'sunya_record.dart';

extension GetSunyaRecordCollection on Isar {
  IsarCollection<SunyaRecord> get sunyaRecords => this.collection();
}

const SunyaRecordSchema = CollectionSchema(
  name: r'SunyaRecord',
  id: -2743658124751029301,
  properties: {
    r'createdAt': PropertySchema(id: 0, name: r'createdAt', type: IsarType.dateTime),
    r'deleted': PropertySchema(id: 1, name: r'deleted', type: IsarType.bool),
    r'domain': PropertySchema(id: 2, name: r'domain', type: IsarType.string),
    r'key': PropertySchema(id: 3, name: r'key', type: IsarType.string),
    r'payload': PropertySchema(id: 4, name: r'payload', type: IsarType.string),
    r'recordDate': PropertySchema(id: 5, name: r'recordDate', type: IsarType.dateTime),
    r'updatedAt': PropertySchema(id: 6, name: r'updatedAt', type: IsarType.dateTime),
    r'version': PropertySchema(id: 7, name: r'version', type: IsarType.long),
  },
  estimateSize: _sunyaRecordEstimateSize,
  serialize: _sunyaRecordSerialize,
  deserialize: _sunyaRecordDeserialize,
  deserializeProp: _sunyaRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _sunyaRecordGetId,
  getLinks: _sunyaRecordGetLinks,
  attach: _sunyaRecordAttach,
  version: '3.1.8',
);

int _sunyaRecordEstimateSize(
  SunyaRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.domain.length * 3;
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.payload.length * 3;
  return bytesCount;
}

void _sunyaRecordSerialize(
  SunyaRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.deleted);
  writer.writeString(offsets[2], object.domain);
  writer.writeString(offsets[3], object.key);
  writer.writeString(offsets[4], object.payload);
  writer.writeDateTime(offsets[5], object.recordDate);
  writer.writeDateTime(offsets[6], object.updatedAt);
  writer.writeLong(offsets[7], object.version);
}

SunyaRecord _sunyaRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SunyaRecord();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.deleted = reader.readBool(offsets[1]);
  object.domain = reader.readString(offsets[2]);
  object.id = id;
  object.key = reader.readString(offsets[3]);
  object.payload = reader.readString(offsets[4]);
  object.recordDate = reader.readDateTimeOrNull(offsets[5]);
  object.updatedAt = reader.readDateTime(offsets[6]);
  object.version = reader.readLong(offsets[7]);
  return object;
}

P _sunyaRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return reader.readDateTime(offset) as P;
    case 1:
      return reader.readBool(offset) as P;
    case 2:
      return reader.readString(offset) as P;
    case 3:
      return reader.readString(offset) as P;
    case 4:
      return reader.readString(offset) as P;
    case 5:
      return reader.readDateTimeOrNull(offset) as P;
    case 6:
      return reader.readDateTime(offset) as P;
    case 7:
      return reader.readLong(offset) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sunyaRecordGetId(SunyaRecord object) => object.id;

List<IsarLinkBase<dynamic>> _sunyaRecordGetLinks(SunyaRecord object) => [];

void _sunyaRecordAttach(IsarCollection<dynamic> col, Id id, SunyaRecord object) {
  object.id = id;
}
