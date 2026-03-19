import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool _isLocating = false;

  Future<void> _handleCheckIn() async {
    setState(() => _isLocating = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition();

        // Anti-fake GPS detection
        if (position.isMocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fake GPS detected! Access denied.')),
          );
          return;
        }

        final user = (context.read<AuthBloc>().state as Authenticated).user;

        final attendance = AttendanceEntity(
          id: const Uuid().v4(),
          userId: user.id,
          organizationId: user.organizationId,
          checkIn: DateTime.now(),
          latitude: position.latitude,
          longitude: position.longitude,
          status: AttendanceStatus.onTime,
        );

        context.read<AttendanceBloc>().add(CheckInRequested(attendance));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-In')),
      body: Center(
        child: BlocConsumer<AttendanceBloc, AttendanceState>(
          listener: (context, state) {
            if (state is AttendanceSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Check-in successful!')),
              );
            } else if (state is AttendanceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  if (_isLocating || state is AttendanceLoading)
                    const CircularProgressIndicator()
                  else ...[
                    const Icon(Icons.location_on, size: 50, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text('Confirm your location to check-in'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleCheckIn,
                      child: const Text('Check-In Now'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 16),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
