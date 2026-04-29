import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/trek_repository.dart';

const _kLoggedIn = 'td_logged_in';
const _kName     = 'td_name';
const _kEmail    = 'td_email';
const _kPin      = 'td_pin';

class AuthState {
  final bool isLoggedIn;
  final String name;
  final String email;
  final bool hasPin;

  const AuthState({
    this.isLoggedIn = false,
    this.name       = '',
    this.email      = '',
    this.hasPin     = false,
  });

  AuthState copyWith({bool? isLoggedIn, String? name, String? email, bool? hasPin}) =>
      AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        name:       name       ?? this.name,
        email:      email      ?? this.email,
        hasPin:     hasPin     ?? this.hasPin,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SharedPreferences _prefs;

  AuthNotifier(this._prefs) : super(AuthState(
    isLoggedIn: _prefs.getBool(_kLoggedIn) ?? false,
    name:       _prefs.getString(_kName)   ?? '',
    email:      _prefs.getString(_kEmail)  ?? '',
    hasPin:     (_prefs.getString(_kPin)   ?? '').isNotEmpty,
  ));

  Future<void> completeAuth({required String name, required String email}) async {
    await _prefs.setBool(_kLoggedIn, true);
    await _prefs.setString(_kName, name);
    await _prefs.setString(_kEmail, email);
    state = state.copyWith(isLoggedIn: true, name: name, email: email);
  }

  Future<void> savePin(String pin) async {
    await _prefs.setString(_kPin, pin);
    state = state.copyWith(hasPin: true);
  }

  bool checkPin(String pin) => _prefs.getString(_kPin) == pin;

  Future<void> continueAsGuest() async {
    await _prefs.setBool(_kLoggedIn, true);
    await _prefs.setString(_kName, 'Explorer');
    state = state.copyWith(isLoggedIn: true, name: 'Explorer');
  }

  Future<void> signOut() async {
    await _prefs.setBool(_kLoggedIn, false);
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(sharedPrefsProvider));
});

// Temporary form data passed between email → pin screens.
// Cleared once auth completes.
final authFormProvider = StateProvider<({String name, String email})?>((_) => null);

// Session-only guest flag — not persisted to SharedPreferences.
// Set when user taps X on the landing screen; resets on app restart.
final sessionGuestProvider = StateProvider<bool>((_) => false);
