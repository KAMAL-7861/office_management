import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/employee_detail_bloc.dart';
import '../bloc/employee_detail_event.dart';
import '../bloc/employee_detail_state.dart';
import '../widgets/employee_map_marker.dart';
import '../widgets/employee_bottom_info_card.dart';
import '../widgets/map_control_buttons.dart';
import '../widgets/employee_detail_state_views.dart';

class AdminEmployeeDetailScreen extends StatelessWidget {
  final UserEntity employee;

  const AdminEmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<EmployeeDetailBloc>()..add(FetchEmployeeAttendance(employee.id)),
      child: _AdminEmployeeDetailView(employee: employee),
    );
  }
}

class _AdminEmployeeDetailView extends StatefulWidget {
  final UserEntity employee;

  const _AdminEmployeeDetailView({required this.employee});

  @override
  State<_AdminEmployeeDetailView> createState() =>
      _AdminEmployeeDetailViewState();
}

class _AdminEmployeeDetailViewState extends State<_AdminEmployeeDetailView>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isSatelliteView = false;

  // Tile URLs
  static const String _normalTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String _satelliteTileUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _toggleMapType() {
    setState(() {
      _isSatelliteView = !_isSatelliteView;
    });
  }

  void _centerOnPosition(LatLng position) {
    _mapController.move(position, 17.0);
  }

  void _refresh() {
    context
        .read<EmployeeDetailBloc>()
        .add(FetchEmployeeAttendance(widget.employee.id));
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour =
        local.hour == 0 ? 12 : (local.hour > 12 ? local.hour - 12 : local.hour);
    final period = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period — ${local.day}/${local.month}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<EmployeeDetailBloc, EmployeeDetailState>(
        builder: (context, state) {
          if (state is EmployeeDetailLoading ||
              state is EmployeeDetailInitial) {
            return EmployeeDetailLoadingView(
              employeeName: widget.employee.name,
            );
          } else if (state is EmployeeDetailError) {
            return EmployeeDetailErrorView(
              employeeName: widget.employee.name,
              error: state.message,
              onRetry: _refresh,
            );
          } else if (state is EmployeeDetailLoaded) {
            final history = state.attendanceHistory;
            if (history.isEmpty) {
              return EmployeeDetailEmptyView(
                employeeName: widget.employee.name,
                message: 'No attendance records found.',
                onRefresh: _refresh,
              );
            }

            final now = DateTime.now();
            final todayAttendance = history
                .where((e) =>
                    e.checkIn.year == now.year &&
                    e.checkIn.month == now.month &&
                    e.checkIn.day == now.day)
                .toList();

            if (todayAttendance.isEmpty) {
              return EmployeeDetailEmptyView(
                employeeName: widget.employee.name,
                message: '${widget.employee.name} has not checked in today.',
                onRefresh: _refresh,
              );
            }

            final latestRecord = todayAttendance.first;
            final position =
                LatLng(latestRecord.latitude, latestRecord.longitude);
            final isCheckedIn = latestRecord.checkOut == null;

            return _buildMapView(
              position: position,
              isCheckedIn: isCheckedIn,
              latestRecord: latestRecord,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMapView({
    required LatLng position,
    required bool isCheckedIn,
    required dynamic latestRecord,
  }) {
    return Stack(
      children: [
        // Full-screen OpenStreetMap
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: position,
            initialZoom: 16.0,
          ),
          children: [
            // Map tiles
            TileLayer(
              urlTemplate:
                  _isSatelliteView ? _satelliteTileUrl : _normalTileUrl,
              userAgentPackageName: 'com.example.office_management_system',
              maxZoom: 19,
            ),

            // Radius circle around marker
            CircleLayer(
              circles: [
                CircleMarker(
                  point: position,
                  radius: 80,
                  useRadiusInMeter: true,
                  color: (isCheckedIn
                          ? const Color(0xFF43A047)
                          : const Color(0xFFE53935))
                      .withOpacity(0.12),
                  borderColor: (isCheckedIn
                          ? const Color(0xFF43A047)
                          : const Color(0xFFE53935))
                      .withOpacity(0.4),
                  borderStrokeWidth: 2,
                ),
              ],
            ),

            // Location marker
            MarkerLayer(
              markers: [
                Marker(
                  point: position,
                  width: 60,
                  height: 60,
                  child: EmployeeMapMarker(
                    isCheckedIn: isCheckedIn,
                    pulseAnimation: _pulseAnimation,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Top gradient overlay for readability
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: MediaQuery.of(context).padding.top + 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Custom App Bar
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 12,
          right: 12,
          child: Row(
            children: [
              MapCircleButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${widget.employee.name}\'s Location',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(blurRadius: 8, color: Colors.black54),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              MapCircleButton(
                icon: Icons.refresh,
                onTap: _refresh,
              ),
            ],
          ),
        ),

        // Map control buttons (right side)
        Positioned(
          right: 14,
          top: MediaQuery.of(context).padding.top + 80,
          child: Column(
            children: [
              MapControlButton(
                icon:
                    _isSatelliteView ? Icons.map_outlined : Icons.satellite_alt,
                onTap: _toggleMapType,
              ),
              const SizedBox(height: 8),
              MapControlButton(
                icon: Icons.my_location,
                onTap: () => _centerOnPosition(position),
              ),
              const SizedBox(height: 8),
              MapControlButton(
                icon: Icons.add,
                onTap: () {
                  final zoom = _mapController.camera.zoom + 1;
                  _mapController.move(_mapController.camera.center, zoom);
                },
              ),
              const SizedBox(height: 8),
              MapControlButton(
                icon: Icons.remove,
                onTap: () {
                  final zoom = _mapController.camera.zoom - 1;
                  _mapController.move(_mapController.camera.center, zoom);
                },
              ),
            ],
          ),
        ),

        // Bottom info card
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: EmployeeBottomInfoCard(
            employee: widget.employee,
            latestRecord: latestRecord,
            isCheckedIn: isCheckedIn,
            pulseAnimation: _pulseAnimation,
            onNavigatePressed: () => _centerOnPosition(position),
            formatTime: _formatTime,
          ),
        ),
      ],
    );
  }
}
