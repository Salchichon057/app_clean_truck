import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:comaslimpio/features/auth/domain/models/app_user.dart';
import 'package:comaslimpio/features/auth/infrastructure/mappers/app_user_mapper.dart';
import 'package:comaslimpio/core/exceptions/auth_exception.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthFirebaseDatasource implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    } catch (e) {
      throw AuthException.generic('Error inesperado al iniciar sesión');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  @override
  Future<String?> register(
    String email,
    String password,
    AppUser appUserData,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user?.uid;

      if (uid != null) {
        final userMap = AppUserMapper.toJson(appUserData.copyWith(uid: uid));
        print('Mapa a guardar en Firestore: $userMap');
        await _firestore.collection('app_users').doc(uid).set(userMap);
        return uid;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    } catch (e) {
      throw AuthException.generic('Error inesperado al registrar usuario');
    }
  }

  @override
  Future<void> updateUserProfile(AppUser user) async {
    try {
      final userMap = AppUserMapper.toJson(user);
      await _firestore.collection('app_users').doc(user.uid).update(userMap);
    } catch (e) {
      rethrow;
    }
  }
}
