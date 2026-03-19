import 'package:equatable/equatable.dart';

abstract class EmployeeDetailEvent extends Equatable {
  const EmployeeDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchEmployeeAttendance extends EmployeeDetailEvent {
  final String employeeId;
  const FetchEmployeeAttendance(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}
