import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import '../models/organization_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> registerEmployee(UserModel user, String password);
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? organizationName,
    String? inviteCode,
  });
  Future<List<UserModel>> getAllEmployees();
  Future<OrganizationModel> getOrganization(String organizationId);
  Future<void> updateOrganizationSettings(String organizationId, {bool? restrictConcurrentLogins, bool? isLocked});
  Future<void> approveEmployee(String userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });


  //login
  @override
  Future<UserModel> login(String email, String password) async {
    try {
      // Find user by email first to check security status
      final userQuery = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      UserModel? user;
      if (userQuery.docs.isNotEmpty) {
        user = UserModel.fromJson(userQuery.docs.first.data());
        
        // Check if account is locked
        if (user.isAccountLocked) {
          final lastAttempt = user.lastFailedAttempt;
          if (lastAttempt != null) {
            final lockDuration = DateTime.now().difference(lastAttempt);
            if (lockDuration.inMinutes < 15) {
              throw AuthException('Account is locked due to multiple failed login attempts. Please try again in ${15 - lockDuration.inMinutes} minutes.');
            } else {
              // Unlock account after 15 mins
              await firestore.collection('users').doc(user.id).update({
                'isAccountLocked': false,
                'failedLoginAttempts': 0,
              });
            }
          }
        }
      }

      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Login failed');
      }

      final uid = credential.user!.uid;
      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw AuthException('User data not found');
      }

      final authenticatedUser = UserModel.fromJson(doc.data()!);

      // Check account status
      if (authenticatedUser.status == UserStatus.pending) {
        await firebaseAuth.signOut();
        throw AuthException('Your account is pending approval by an administrator.');
      } else if (authenticatedUser.status == UserStatus.deactivated) {
        await firebaseAuth.signOut();
        throw AuthException('Your account has been deactivated. Please contact support.');
      }

      // Reset failed attempts on success
      if (authenticatedUser.failedLoginAttempts > 0) {
        await firestore.collection('users').doc(uid).update({
          'failedLoginAttempts': 0,
          'isAccountLocked': false,
        });
      }

      // Check organization settings for administrative roles
      if (authenticatedUser.role == UserRole.manager || authenticatedUser.role == UserRole.admin || authenticatedUser.role == UserRole.hr) {
        final orgDoc = await firestore.collection('organizations').doc(authenticatedUser.organizationId).get();
        if (orgDoc.exists) {
          final org = OrganizationModel.fromJson(orgDoc.data()!);
          
          // Check if concurrent logins are restricted
          if (org.restrictConcurrentLogins && org.activeAdminId != null && org.activeAdminId != uid) {
            await firebaseAuth.signOut();
            throw AuthException('Another administrator/manager is already logged in for this organization.');
          }

          // Update active admin if restricted
          if (org.restrictConcurrentLogins) {
            await firestore.collection('organizations').doc(authenticatedUser.organizationId).update({
              'activeAdminId': uid,
            });
          }
        }
      }

      return authenticatedUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        // Track failed attempt
        final userQuery = await firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
            
        if (userQuery.docs.isNotEmpty) {
          final userDoc = userQuery.docs.first;
          final user = UserModel.fromJson(userDoc.data());
          final newAttempts = user.failedLoginAttempts + 1;
          
          final updates = <String, dynamic>{
            'failedLoginAttempts': newAttempts,
            'lastFailedAttempt': DateTime.now().toIso8601String(),
          };

          if (newAttempts >= 5) {
            updates['isAccountLocked'] = true;
            // Simulated Notification to owner/manager
            print('SECURITY ALERT: User ${user.email} from Organization ${user.organizationId} has reached failed login threshold. Account locked.');
            // In a real app, you would send a FCM notification or Email here
          }
          
          await firestore.collection('users').doc(user.id).update(updates);
        }
      }
      throw AuthException(e.message ?? 'Authentication failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  
  //logout
  @override
  Future<void> logout() async {
    try {
      final user = await getCurrentUser();
      if (user != null && (user.role == UserRole.manager || user.role == UserRole.admin || user.role == UserRole.hr)) {
        // Clear active manager on logout
        final orgDoc = await firestore.collection('organizations').doc(user.organizationId).get();
        if (orgDoc.exists) {
          final org = OrganizationModel.fromJson(orgDoc.data()!);
          if (org.activeAdminId == user.id) {
            await firestore.collection('organizations').doc(user.organizationId).update({
              'activeAdminId': null,
            });
          }
        }
      }
      await firebaseAuth.signOut();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  //get current user
  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;

    final doc = await firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromJson(doc.data()!);
  }

  @override
  Future<OrganizationModel> getOrganization(String organizationId) async {
    try {
      final doc = await firestore.collection('organizations').doc(organizationId).get();
      if (!doc.exists) throw AuthException('Organization not found');
      return OrganizationModel.fromJson(doc.data()!);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> updateOrganizationSettings(String organizationId,
      {bool? restrictConcurrentLogins, bool? isLocked}) async {
    try {
      final data = <String, dynamic>{};
      if (restrictConcurrentLogins != null) {
        data['restrictConcurrentLogins'] = restrictConcurrentLogins;
      }
      if (isLocked != null) {
        data['isLocked'] = isLocked;
      }
      await firestore.collection('organizations').doc(organizationId).update(data);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }


  //register employee
  @override
  Future<void> registerEmployee(UserModel user, String password) async {
    try {
      final authenticatedUser = await getCurrentUser();
      if (authenticatedUser == null) throw AuthException('No admin logged in');

      // Check if organization is locked
      final orgDoc = await firestore.collection('organizations').doc(authenticatedUser.organizationId).get();
      if (orgDoc.exists) {
        final org = OrganizationModel.fromJson(orgDoc.data()!);
        if (org.isLocked) {
          throw AuthException('Organization is currently locked. New registrations are not allowed.');
        }
      }

      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      final newUser = UserModel(
        id: credential.user!.uid,
        name: user.name,
        email: user.email,
        role: user.role,
        department: user.department,
        profileImageUrl: user.profileImageUrl,
        organizationId: authenticatedUser.organizationId,
        organizationName: authenticatedUser.organizationName,
        failedLoginAttempts: 0,
        isAccountLocked: false,
      );

      await firestore.collection('users').doc(newUser.id).set(newUser.toJson());
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }


  Future<String> _generateUniqueInviteCode() async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No O, 0, I, 1 for clarity
    final rnd = Random();
    String code;
    bool isUnique = false;

    do {
      code = String.fromCharCodes(Iterable.generate(
          8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
      
      final doc = await firestore
          .collection('organizations')
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();
      
      if (doc.docs.isEmpty) isUnique = true;
    } while (!isUnique);

    return code;
  }

  //sign up
  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? organizationName,
    String? inviteCode,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      OrganizationModel? organization;

      if (role == UserRole.manager || role == UserRole.admin || role == UserRole.hr) {
        // Create new organization with uniqueness guarantee
        final orgInviteCode = await _generateUniqueInviteCode();
        final organizationRef = firestore.collection('organizations').doc();
        organization = OrganizationModel(
          id: organizationRef.id,
          name: organizationName ?? 'New Organization',
          adminId: uid,
          createdAt: DateTime.now(),
          inviteCode: orgInviteCode,
          isLocked: false,
          restrictConcurrentLogins: false,
          failedLoginThreshold: 5,
        );
        await organizationRef.set(organization.toJson());
      } else {
        // Join existing organization via invite code
        if (inviteCode == null) throw AuthException('Invite code is required to join an organization');
        
        final orgQuery = await firestore
            .collection('organizations')
            .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
            .limit(1)
            .get();
            
        if (orgQuery.docs.isEmpty) {
          await credential.user?.delete();
          throw AuthException('Invalid or expired invite code');
        }
        
        organization = OrganizationModel.fromJson(orgQuery.docs.first.data());
        
        if (organization.isLocked) {
          await credential.user?.delete();
          throw AuthException('This organization is currently locked for new members');
        }
      }

      final newUser = UserModel(
        id: uid,
        name: name,
        email: email,
        role: role,
        status: (role == UserRole.manager || role == UserRole.admin || role == UserRole.hr) 
            ? UserStatus.active 
            : UserStatus.pending,
        department: 'General',
        profileImageUrl: '',
        organizationId: organization.id,
        organizationName: organization.name,
        failedLoginAttempts: 0,
        isAccountLocked: false,
      );

      await firestore.collection('users').doc(newUser.id).set(newUser.toJson());
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }


  //get all employees 
  @override
  Future<List<UserModel>> getAllEmployees() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) throw AuthException('Not authenticated');

      final querySnapshot = await firestore
          .collection('users')
          .where('organizationId', isEqualTo: currentUser.organizationId)
          .get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> approveEmployee(String userId) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null || (currentUser.role != UserRole.manager && currentUser.role != UserRole.admin && currentUser.role != UserRole.hr)) {
        throw AuthException('Only administrators can approve employees');
      }

      await firestore.collection('users').doc(userId).update({
        'status': UserStatus.active.toString().split('.').last,
      });
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}
