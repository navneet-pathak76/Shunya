import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SunyaAccount {
  const SunyaAccount({required this.id, required this.email, this.name, this.photoUrl, this.idToken});
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? idToken;
}

class SunyaAuthService {
  final GoogleSignIn _google = GoogleSignIn.instance;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    const clientId = String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');
    const serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID', defaultValue: '');
    await _google.initialize(
      clientId: clientId.isEmpty ? null : clientId,
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
    _initialized = true;
  }

  Future<SunyaAccount?> restore() async {
    await initialize();
    try {
      final user = await _google.attemptLightweightAuthentication();
      return _map(user);
    } catch (_) {
      return null;
    }
  }

  Future<SunyaAccount?> signIn() async {
    await initialize();
    if (!_google.supportsAuthenticate()) return null;
    final user = await _google.authenticate();
    final account = _map(user);
    if (account != null) {
      final p = await SharedPreferences.getInstance();
      await p.setString('sunya.account.id', account.id);
      await p.setString('sunya.account.email', account.email);
      if (account.name != null) await p.setString('sunya.account.name', account.name!);
    }
    return account;
  }

  Future<void> signOut() async {
    await initialize();
    await _google.signOut();
    final p = await SharedPreferences.getInstance();
    await p.remove('sunya.account.id');
    await p.remove('sunya.account.email');
    await p.remove('sunya.account.name');
  }

  SunyaAccount? _map(GoogleSignInAccount? user) {
    if (user == null) return null;
    return SunyaAccount(
      id: user.id,
      email: user.email,
      name: user.displayName,
      photoUrl: user.photoUrl,
      idToken: user.authentication.idToken,
    );
  }
}
