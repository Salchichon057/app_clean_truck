import 'package:firebase_auth/firebase_auth.dart';
import 'package:comaslimpio/features/auth/domain/models/app_user.dart';

abstract class AuthRepository {
  Future<String?> signIn(String email, String password);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
  Future<User?> getCurrentUser();
  Future<String?> register(String email, String password, AppUser appUserData);
}
