import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../database/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  // Obter o usuário atual
  User? get currentUser => _auth.currentUser;

  // Stream de mudança de estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login com Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
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
      print("Erro no Login com Google: $e");
      return null;
    }
  }

  // Login com Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
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
        return null;
      }
    } catch (e) {
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
