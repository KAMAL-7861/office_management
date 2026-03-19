import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceModel> checkIn(AttendanceModel attendance);
  Future<AttendanceModel> checkOut(String attendanceId, DateTime checkOutTime);
  Future<List<AttendanceModel>> getAttendanceHistory(String userId);
  Future<List<AttendanceModel>> getAllAttendanceForDate(DateTime date, String organizationId);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final FirebaseFirestore firestore;

  AttendanceRemoteDataSourceImpl({required this.firestore});

  @override
  Future<AttendanceModel> checkIn(AttendanceModel attendance) async {
    try {
      await firestore
          .collection('attendance')
          .doc(attendance.id)
          .set(attendance.toJson());
      return attendance;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AttendanceModel> checkOut(
      String attendanceId, DateTime checkOutTime) async {
    try {
      final docRef = firestore.collection('attendance').doc(attendanceId);
      await docRef.update({
        'checkOut': Timestamp.fromDate(checkOutTime),
      });
      final doc = await docRef.get();
      return AttendanceModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AttendanceModel>> getAttendanceHistory(String userId) async {
    try {
      final query = await firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .get();

      final list = query.docs
          .map((doc) => AttendanceModel.fromJson(doc.data()))
          .toList();

      list.sort((a, b) => b.checkIn.compareTo(a.checkIn));
      return list;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AttendanceModel>> getAllAttendanceForDate(DateTime date, String organizationId) async {
    try {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));

      final query = await firestore
          .collection('attendance')
          .where('organizationId', isEqualTo: organizationId)
          .where('checkIn', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('checkIn', isLessThan: Timestamp.fromDate(end))
          .get();
      return query.docs
          .map((doc) => AttendanceModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
