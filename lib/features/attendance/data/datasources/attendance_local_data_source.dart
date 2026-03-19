import 'package:hive/hive.dart';
import '../models/attendance_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AttendanceLocalDataSource {
  Future<void> cacheAttendance(AttendanceModel attendance);
  Future<List<AttendanceModel>> getCachedAttendance();
  Future<void> clearCache();
}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  static const String boxName = 'attendance_box';

  @override
  Future<void> cacheAttendance(AttendanceModel attendance) async {
    try {
      final box = await Hive.openBox(boxName);
      await box.put(attendance.id, attendance.toJson());
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<AttendanceModel>> getCachedAttendance() async {
    try {
      final box = await Hive.openBox(boxName);
      return box.values
          .map((data) =>
              AttendanceModel.fromJson(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = await Hive.openBox(boxName);
      await box.clear();
    } catch (e) {
      throw CacheException();
    }
  }
}
