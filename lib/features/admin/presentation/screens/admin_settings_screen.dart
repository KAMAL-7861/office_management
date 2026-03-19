import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
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
      final result = await sl<GetOrganizationUseCase>().call(authState.user.organizationId);
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
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${failure.message}')),
      ),
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
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${failure.message}')),
      ),
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
      appBar: AppBar(title: const Text('Organization Settings')),
      body: _isLoading && _organization == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Security Settings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Restrict Concurrent Manager Logins'),
                      subtitle: const Text(
                          'When enabled, only one administrator/manager can be logged in at a time for this organization.'),
                      value: _organization?.restrictConcurrentLogins ?? false,
                      onChanged: _isLoading ? null : _toggleConcurrentLogins,
                    ),
                    const Divider(height: 32),
                    SwitchListTile(
                      title: const Text('Lock Organization Registration'),
                      subtitle: const Text(
                          'When enabled, no new employees can be registered in this organization.'),
                      value: _organization?.isLocked ?? false,
                      onChanged: _isLoading ? null : _toggleOrganizationLock,
                    ),
                    if (_organization?.isLocked == false) ...[
                      const Divider(height: 32),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Theme.of(context).dividerColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.share_outlined, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Organization Invite Code',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Share this 6-digit code with your employees so they can join your organization.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    _organization?.inviteCode ?? '------',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 8,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
    );
  }
}
