import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../database/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '106292251398-s8dl9m4o5jvppd0669m8r6tu4qrpm3j6.apps.googleusercontent.com' : null,
    serverClientId: '106292251398-s8dl9m4o5jvppd0669m8r6tu4qrpm3j6.apps.googleusercontent.com',
  );
  final FirestoreService _firestoreService = FirestoreService();

  // Obter o usuário atual
  User? get currentUser => _auth.currentUser;

  // Armazenar o último erro para exibição
  String? lastError;

  // Stream de mudança de estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login Anônimo (Visitante)
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print("Erro no Login Anônimo: $e");
      return null;
    }
  }

  // Login com Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(authProvider);
        if (userCredential.user != null) {
          await _firestoreService.createUserProfile(userCredential.user!);
        }
        return userCredential;
      }

      // Inicia o fluxo de autenticação do Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // O usuário cancelou o login

      // Obtém os detalhes de autenticação do pedido (tokens)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Cria a credencial para o Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Autentica no Firebase com a credencial
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Cria/verifica o perfil no Firestore
      if (userCredential.user != null) {
        await _firestoreService.createUserProfile(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      lastError = e.toString();
      print("Erro no Login com Google: $e");
      return null;
    }
  }

  // Login com Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
      if (kIsWeb) {
        FacebookAuthProvider authProvider = FacebookAuthProvider();
        final userCredential = await _auth.signInWithPopup(authProvider);
        if (userCredential.user != null) {
          await _firestoreService.createUserProfile(userCredential.user!);
        }
        return userCredential;
      }

      // Inicia o fluxo de autenticação do Facebook
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // Cria a credencial para o Firebase usando o token de acesso do Facebook
        final credential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);

        // Autentica no Firebase com a credencial
        final userCredential = await _auth.signInWithCredential(credential);
        
        // Cria/verifica o perfil no Firestore
        if (userCredential.user != null) {
          await _firestoreService.createUserProfile(userCredential.user!);
        }
        
        return userCredential;
      } else {
        print("Login com Facebook falhou ou foi cancelado: ${result.status}");
        lastError = "Status: ${result.status}";
        return null;
      }
    } catch (e) {
      lastError = e.toString();
      print("Erro no Login com Facebook: $e");
      return null;
    }
  }

  // Logout (Deslogar de todos os provedores)
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
      await _auth.signOut();
    } catch (e) {
      print("Erro ao deslogar: $e");
    }
  }
}
