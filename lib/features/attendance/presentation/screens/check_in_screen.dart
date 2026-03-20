import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
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
        if (position.isMocked) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fake GPS detected! Access denied.')),
            );
          }
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
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: themedAppBar(title: 'Check-In'),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: BlocConsumer<AttendanceBloc, AttendanceState>(
              listener: (context, state) {
                if (state is AttendanceSuccess) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Check-in successful!')),
                  );
                } else if (state is AttendanceError) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                final isLoading = _isLocating || state is AttendanceLoading;
                return Padding(
                  padding: const EdgeInsets.all(28),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Confirm Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your GPS location will be recorded\nfor attendance verification.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.subtitleGrey,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 36),
                        if (isLoading)
                          Column(
                            children: [
                              const SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.teal,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Getting location...',
                                style: TextStyle(color: AppColors.subtitleGrey),
                              ),
                            ],
                          )
                        else
                          TealButton(
                            label: 'Check-In Now',
                            onTap: _handleCheckIn,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
