import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/organization_entity.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  OrganizationEntity? _organization;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final result = await sl<GetOrganizationUseCase>()
          .call(authState.user.organizationId);
      result.fold(
        (failure) => setState(() {
          _error = failure.message;
          _isLoading = false;
        }),
        (org) => setState(() {
          _organization = org;
          _isLoading = false;
        }),
      );
    }
  }

  Future<void> _toggleConcurrentLogins(bool value) async {
    if (_organization == null) return;
    setState(() => _isLoading = true);
    final result = await sl<UpdateOrganizationSettingsUseCase>().call(
      _organization!.id,
      restrictConcurrentLogins: value,
    );
    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${failure.message}'))),
      (_) {
        setState(() {
          _organization = OrganizationEntity(
            id: _organization!.id,
            name: _organization!.name,
            adminId: _organization!.adminId,
            createdAt: _organization!.createdAt,
            logoUrl: _organization!.logoUrl,
            address: _organization!.address,
            restrictConcurrentLogins: value,
            activeAdminId: _organization!.activeAdminId,
          );
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings updated successfully')),
        );
      },
    );
  }

  Future<void> _toggleOrganizationLock(bool value) async {
    if (_organization == null) return;
    setState(() => _isLoading = true);
    final result = await sl<UpdateOrganizationSettingsUseCase>().call(
      _organization!.id,
      isLocked: value,
    );
    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${failure.message}'))),
      (_) {
        setState(() {
          _organization = OrganizationEntity(
            id: _organization!.id,
            name: _organization!.name,
            adminId: _organization!.adminId,
            createdAt: _organization!.createdAt,
            logoUrl: _organization!.logoUrl,
            address: _organization!.address,
            restrictConcurrentLogins: _organization!.restrictConcurrentLogins,
            activeAdminId: _organization!.activeAdminId,
            isLocked: value,
            inviteCode: _organization!.inviteCode,
            failedLoginThreshold: _organization!.failedLoginThreshold,
          );
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organization lock updated')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: themedAppBar(title: 'Organization Settings'),
      body: AppBackground(
        child: _isLoading && _organization == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.teal))
            : _error != null
                ? Center(
                    child: Text('Error: $_error',
                        style:
                            const TextStyle(color: AppColors.subtitleGrey)))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                    children: [
                      // ── Security header ─────────────────────
                      const Text(
                        'Security Settings',
                        style: TextStyle(
                          color: AppColors.teal,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // ── Concurrent logins toggle ────────────
                      GlassCard(
                        padding: EdgeInsets.zero,
                        child: SwitchListTile(
                          title: const Text(
                            'Restrict Concurrent Manager Logins',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                          subtitle: const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'Only one admin/manager can be logged in at a time.',
                              style: TextStyle(
                                  color: AppColors.subtitleGrey,
                                  fontSize: 12),
                            ),
                          ),
                          value: _organization?.restrictConcurrentLogins ??
                              false,
                          onChanged:
                              _isLoading ? null : _toggleConcurrentLogins,
                          activeColor: AppColors.teal,
                          inactiveTrackColor:
                              AppColors.fieldLine.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // ── Lock toggle ─────────────────────────
                      GlassCard(
                        padding: EdgeInsets.zero,
                        child: SwitchListTile(
                          title: const Text(
                            'Lock Organization Registration',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                          subtitle: const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'No new employees can be registered when locked.',
                              style: TextStyle(
                                  color: AppColors.subtitleGrey,
                                  fontSize: 12),
                            ),
                          ),
                          value: _organization?.isLocked ?? false,
                          onChanged:
                              _isLoading ? null : _toggleOrganizationLock,
                          activeColor: AppColors.statusRejected,
                          inactiveTrackColor:
                              AppColors.fieldLine.withOpacity(0.5),
                        ),
                      ),
                      // ── Invite code ─────────────────────────
                      if (_organization?.isLocked == false) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Invite Code',
                          style: TextStyle(
                            color: AppColors.teal,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.share_outlined,
                                      color: AppColors.teal, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Organization Invite Code',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Share this 6-digit code with your employees so they can join your organization.',
                                style: TextStyle(
                                    color: AppColors.subtitleGrey,
                                    fontSize: 13,
                                    height: 1.4),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  color: AppColors.teal.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.teal.withOpacity(0.3),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _organization?.inviteCode ?? '------',
                                    style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 10,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.teal)),
                        ),
                    ],
                  ),
      ),
    );
  }
}
