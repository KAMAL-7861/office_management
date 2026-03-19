import 'package:equatable/equatable.dart';
import '../../../attendance/domain/entities/attendance_entity.dart';

abstract class EmployeeDetailState extends Equatable {
  const EmployeeDetailState();

  @override
  List<Object?> get props => [];
}

class EmployeeDetailInitial extends EmployeeDetailState {}

class EmployeeDetailLoading extends EmployeeDetailState {}

class EmployeeDetailLoaded extends EmployeeDetailState {
  final List<AttendanceEntity> attendanceHistory;
  const EmployeeDetailLoaded(this.attendanceHistory);

  @override
  List<Object?> get props => [attendanceHistory];
}

class EmployeeDetailError extends EmployeeDetailState {
  final String message;
  const EmployeeDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
