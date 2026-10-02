import 'package:google_sign_in/google_sign_in.dart';

class SunyaGoogleAccount {
  const SunyaGoogleAccount({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.idToken,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? idToken;
}

class SunyaGoogleAuthService {
  final GoogleSignIn _signIn = GoogleSignIn.instance;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;
    final clientId = const String.fromEnvironment(
      'GOOGLE_CLIENT_ID',
      defaultValue: '',
    );
    final serverClientId = const String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
      defaultValue: '',
    );
    await _signIn.initialize(
      clientId: clientId.isEmpty ? null : clientId,
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
    _initialized = true;
  }

  Future<SunyaGoogleAccount> signIn() async {
    await _initialize();
    final account = await _signIn.authenticate();
    return SunyaGoogleAccount(
      id: account.id,
      email: account.email,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
      idToken: account.authentication.idToken,
    );
  }

  Future<void> signOut() async {
    await _initialize();
    await _signIn.signOut();
  }
}
