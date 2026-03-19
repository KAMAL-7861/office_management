import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../attendance/domain/usecases/attendance_usecases.dart';
import 'employee_detail_event.dart';
import 'employee_detail_state.dart';

class EmployeeDetailBloc
    extends Bloc<EmployeeDetailEvent, EmployeeDetailState> {
  final GetAttendanceHistoryUseCase getAttendanceHistoryUseCase;

  EmployeeDetailBloc({
    required this.getAttendanceHistoryUseCase,
  }) : super(EmployeeDetailInitial()) {
    on<FetchEmployeeAttendance>(_onFetchEmployeeAttendance);
  }

  Future<void> _onFetchEmployeeAttendance(
      FetchEmployeeAttendance event, Emitter<EmployeeDetailState> emit) async {
    emit(EmployeeDetailLoading());
    final result = await getAttendanceHistoryUseCase.call(event.employeeId);
    result.fold(
      (failure) => emit(EmployeeDetailError(failure.message)),
      (history) => emit(EmployeeDetailLoaded(history)),
    );
  }
}
