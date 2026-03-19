import 'package:flutter/material.dart';
import '../../../attendance/domain/entities/attendance_entity.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';

/// Bottom info card that shows employee name, status, and attendance details.
class EmployeeBottomInfoCard extends StatelessWidget {
  final UserEntity employee;
  final AttendanceEntity latestRecord;
  final bool isCheckedIn;
  final Animation<double> pulseAnimation;
  final VoidCallback onNavigatePressed;
  final String Function(DateTime dateTime) formatTime;

  const EmployeeBottomInfoCard({
    super.key,
    required this.employee,
    required this.latestRecord,
    required this.isCheckedIn,
    required this.pulseAnimation,
    required this.onNavigatePressed,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        isCheckedIn ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final statusBgColor =
        isCheckedIn ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Employee info row
              Row(
                children: [
                  // Avatar with gradient
                  _buildAvatar(statusColor),
                  const SizedBox(width: 14),

                  // Name & status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildStatusRow(statusColor, statusBgColor),
                      ],
                    ),
                  ),

                  // Navigate button
                  _buildNavigateButton(),
                ],
              ),
              const SizedBox(height: 16),

              // Details grid
              _buildDetailsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Color statusColor) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCheckedIn
              ? [const Color(0xFF43A047), const Color(0xFF66BB6A)]
              : [const Color(0xFFE53935), const Color(0xFFEF5350)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(Color statusColor, Color statusBgColor) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withOpacity(
                  isCheckedIn ? pulseAnimation.value : 1.0,
                ),
                boxShadow: isCheckedIn
                    ? [
                        BoxShadow(
                          color: statusColor
                              .withOpacity(pulseAnimation.value * 0.5),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: statusBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isCheckedIn ? 'Checked In' : 'Checked Out',
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigateButton() {
    return Material(
      color: const Color(0xFF1565C0),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onNavigatePressed,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.near_me,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsGrid() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFF1565C0),
            label: 'Check In',
            value: formatTime(latestRecord.checkIn),
          ),
          if (latestRecord.checkOut != null) ...[
            const Divider(height: 16),
            _buildInfoRow(
              icon: Icons.logout_rounded,
              iconColor: const Color(0xFFE53935),
              label: 'Check Out',
              value: formatTime(latestRecord.checkOut!),
            ),
          ],
          const Divider(height: 16),
          _buildInfoRow(
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFF43A047),
            label: 'Coordinates',
            value:
                '${latestRecord.latitude.toStringAsFixed(6)}, ${latestRecord.longitude.toStringAsFixed(6)}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
