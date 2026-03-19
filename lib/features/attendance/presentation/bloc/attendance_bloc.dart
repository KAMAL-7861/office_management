import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/attendance_usecases.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final CheckInUseCase checkInUseCase;
  final CheckOutUseCase checkOutUseCase;
  final GetAttendanceHistoryUseCase getHistoryUseCase;
  final SyncOfflineAttendanceUseCase syncUseCase;

  AttendanceBloc({
    required this.checkInUseCase,
    required this.checkOutUseCase,
    required this.getHistoryUseCase,
    required this.syncUseCase,
  }) : super(AttendanceInitial()) {
    on<CheckInRequested>(_onCheckInRequested);
    on<CheckOutRequested>(_onCheckOutRequested);
    on<FetchAttendanceHistory>(_onFetchAttendanceHistory);
    on<SyncOfflineAttendance>(_onSyncOfflineAttendance);
  }

  Future<void> _onCheckInRequested(
      CheckInRequested event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    final result = await checkInUseCase(event.attendance);
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (attendance) => emit(AttendanceSuccess(attendance)),
    );
  }

  Future<void> _onCheckOutRequested(
      CheckOutRequested event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    final result =
        await checkOutUseCase(event.attendanceId, event.checkOutTime);
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (attendance) => emit(AttendanceSuccess(attendance)),
    );
  }

  Future<void> _onFetchAttendanceHistory(
      FetchAttendanceHistory event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    final result = await getHistoryUseCase(event.userId);
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (history) => emit(AttendanceHistoryLoaded(history)),
    );
  }

  Future<void> _onSyncOfflineAttendance(
      SyncOfflineAttendance event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    final result = await syncUseCase();
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (_) => emit(SyncSuccess()),
    );
  }
}
