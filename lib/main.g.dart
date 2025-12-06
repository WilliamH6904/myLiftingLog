// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgramAdapter extends TypeAdapter<Program> {
  @override
  final int typeId = 0;

  @override
  Program read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Program(
      notes: fields[3] as String?,
      weeks: (fields[0] as List).cast<Week>(),
      date: fields[1] as DateTime,
      name: fields[2] as String,
    )..isCurrentProgram = fields[4] as bool;
  }

  @override
  void write(BinaryWriter writer, Program obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.weeks)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.isCurrentProgram);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MovementLogAdapter extends TypeAdapter<MovementLog> {
  @override
  final int typeId = 1;

  @override
  MovementLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovementLog(
      secondaryMuscleGroups: (fields[7] as List?)?.cast<String>(),
      primaryMuscleGroups: (fields[6] as List?)?.cast<String>(),
      date: fields[3] as DateTime,
      name: fields[0] as String,
      resultSetBlocks: (fields[2] as List).cast<ResultSetBlock>(),
      favorited: fields[1] as bool,
      notes: fields[8] as String,
    )
      ..prHistory = (fields[4] as List).cast<ResultSetBlock>()
      ..goal = fields[5] as Goal;
  }

  @override
  void write(BinaryWriter writer, MovementLog obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.favorited)
      ..writeByte(2)
      ..write(obj.resultSetBlocks)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.prHistory)
      ..writeByte(5)
      ..write(obj.goal)
      ..writeByte(6)
      ..write(obj.primaryMuscleGroups)
      ..writeByte(7)
      ..write(obj.secondaryMuscleGroups)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovementLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeekAdapter extends TypeAdapter<Week> {
  @override
  final int typeId = 2;

  @override
  Week read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Week(
      name: fields[0] as String,
      days: (fields[1] as List).cast<day>(),
    );
  }

  @override
  void write(BinaryWriter writer, Week obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.days);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeekAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DayAdapter extends TypeAdapter<day> {
  @override
  final int typeId = 3;

  @override
  day read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return day(
      muscleGroups: (fields[4] as List?)?.cast<String>(),
      checked: fields[3] as bool,
      id: fields[0] as int,
      name: fields[1] as String,
      movements: (fields[2] as List).cast<Movement>(),
    );
  }

  @override
  void write(BinaryWriter writer, day obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.movements)
      ..writeByte(3)
      ..write(obj.checked)
      ..writeByte(4)
      ..write(obj.muscleGroups);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ResultSetAdapter extends TypeAdapter<ResultSet> {
  @override
  final int typeId = 4;

  @override
  ResultSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResultSet(
      setType: fields[5] as String?,
      reps: fields[1] as int,
      setNumber: fields[3] as int,
      rir: fields[2] as int,
      weight: fields[4] as double,
      idForKey: fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ResultSet obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.idForKey)
      ..writeByte(1)
      ..write(obj.reps)
      ..writeByte(2)
      ..write(obj.rir)
      ..writeByte(3)
      ..write(obj.setNumber)
      ..writeByte(4)
      ..write(obj.weight)
      ..writeByte(5)
      ..write(obj.setType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ResultSetBlockAdapter extends TypeAdapter<ResultSetBlock> {
  @override
  final int typeId = 5;

  @override
  ResultSetBlock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResultSetBlock(
      dayIdForNavigation: fields[2] as int,
      date: fields[1] as DateTime,
      resultSets: (fields[3] as List).cast<ResultSet>(),
    )..oneRepMax = fields[0] as double;
  }

  @override
  void write(BinaryWriter writer, ResultSetBlock obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.oneRepMax)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.dayIdForNavigation)
      ..writeByte(3)
      ..write(obj.resultSets);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultSetBlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MovementAdapter extends TypeAdapter<Movement> {
  @override
  final int typeId = 6;

  @override
  Movement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movement(
      secondaryMuscleGroups: (fields[13] as List?)?.cast<String>(),
      primaryMuscleGroups: (fields[12] as List?)?.cast<String>(),
      hasBeenLogged: fields[0] as bool,
      timerActive: fields[1] as bool,
      superset: fields[10] as bool,
      resultSets: (fields[11] as List).cast<ResultSet>(),
      notes: fields[9] as String,
      name: fields[2] as String,
      sets: fields[3] as int,
      reps: fields[4] as String,
      rir: fields[5] as String,
      weight: fields[6] as double,
      rest: Duration(milliseconds: fields[7] as int),
      remainingRestTime: Duration(milliseconds: fields[8] as int),
    );
  }

  @override
  void write(BinaryWriter writer, Movement obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.hasBeenLogged)
      ..writeByte(1)
      ..write(obj.timerActive)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.sets)
      ..writeByte(4)
      ..write(obj.reps)
      ..writeByte(5)
      ..write(obj.rir)
      ..writeByte(6)
      ..write(obj.weight)
      ..writeByte(7)
      ..write(obj.rest.inMilliseconds)
      ..writeByte(8)
      ..write(obj.remainingRestTime.inMilliseconds)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.superset)
      ..writeByte(11)
      ..write(obj.resultSets)
      ..writeByte(12)
      ..write(obj.primaryMuscleGroups)
      ..writeByte(13)
      ..write(obj.secondaryMuscleGroups);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 7;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      startDate: fields[0] as DateTime?,
      endDate: fields[1] as DateTime?,
      startWeight: fields[2] as double?,
      targetWeight: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.endDate)
      ..writeByte(2)
      ..write(obj.startWeight)
      ..writeByte(3)
      ..write(obj.targetWeight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
