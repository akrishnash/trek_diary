import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/trek_repository.dart';

const _kLoggedIn        = 'td_logged_in';
const _kName            = 'td_name';
const _kEmail           = 'td_email';
const _kPin             = 'td_pin';
const _kAge             = 'td_age';
const _kPhone           = 'td_phone';
const _kProfileComplete = 'td_profile_complete';
const _kBio             = 'td_bio';
const _kLocation        = 'td_location';
const _kExperience      = 'td_experience';
const _kUsername        = 'td_username';

class AuthState {
  final bool isLoggedIn;
  final String name;
  final String email;
  final String phone;
  final bool hasPin;
  final int age;
  final bool profileComplete;
  final String bio;
  final String location;
  final String experience;
  final String username;

  const AuthState({
    this.isLoggedIn      = false,
    this.name            = '',
    this.email           = '',
    this.phone           = '',
    this.hasPin          = false,
    this.age             = 0,
    this.profileComplete = false,
    this.bio             = '',
    this.location        = '',
    this.experience      = '',
    this.username        = '',
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? name,
    String? email,
    String? phone,
    bool? hasPin,
    int? age,
    bool? profileComplete,
    String? bio,
    String? location,
    String? experience,
    String? username,
  }) => AuthState(
    isLoggedIn:      isLoggedIn      ?? this.isLoggedIn,
    name:            name            ?? this.name,
    email:           email           ?? this.email,
    phone:           phone           ?? this.phone,
    hasPin:          hasPin          ?? this.hasPin,
    age:             age             ?? this.age,
    profileComplete: profileComplete ?? this.profileComplete,
    bio:             bio             ?? this.bio,
    location:        location        ?? this.location,
    experience:      experience      ?? this.experience,
    username:        username        ?? this.username,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SharedPreferences _prefs;

  AuthNotifier(this._prefs) : super(AuthState(
    isLoggedIn:      _prefs.getBool(_kLoggedIn)        ?? false,
    name:            _prefs.getString(_kName)           ?? '',
    email:           _prefs.getString(_kEmail)          ?? '',
    phone:           _prefs.getString(_kPhone)          ?? '',
    hasPin:          (_prefs.getString(_kPin)           ?? '').isNotEmpty,
    age:             _prefs.getInt(_kAge)               ?? 0,
    profileComplete: _prefs.getBool(_kProfileComplete)  ?? false,
    bio:             _prefs.getString(_kBio)            ?? '',
    location:        _prefs.getString(_kLocation)       ?? '',
    experience:      _prefs.getString(_kExperience)     ?? '',
    username:        _prefs.getString(_kUsername)       ?? '',
  ));

  Future<void> completeAuth({
    required String name,
    required String email,
    String phone = '',
    bool profileComplete = false,
  }) async {
    await _prefs.setBool(_kLoggedIn, true);
    await _prefs.setString(_kName, name);
    await _prefs.setString(_kEmail, email);
    if (phone.isNotEmpty) await _prefs.setString(_kPhone, phone);
    if (profileComplete) await _prefs.setBool(_kProfileComplete, true);
    state = state.copyWith(
      isLoggedIn:      true,
      name:            name,
      email:           email,
      phone:           phone.isNotEmpty ? phone : state.phone,
      profileComplete: profileComplete,
    );
  }

  Future<void> completeProfile({
    required String name,
    required int age,
    String phone = '',
    String experience = '',
  }) async {
    await _prefs.setBool(_kLoggedIn, true);
    await _prefs.setString(_kName, name);
    await _prefs.setInt(_kAge, age);
    await _prefs.setBool(_kProfileComplete, true);
    if (phone.isNotEmpty) await _prefs.setString(_kPhone, phone);
    state = state.copyWith(
      isLoggedIn:      true,
      name:            name,
      age:             age,
      phone:           phone.isNotEmpty ? phone : state.phone,
      profileComplete: true,
    );
  }

  Future<void> updateProfile({
    String? name,
    String? bio,
    String? location,
    String? experience,
    String? username,
    String? phone,
    String? email,
    int? age,
  }) async {
    if (name       != null) await _prefs.setString(_kName,       name);
    if (bio        != null) await _prefs.setString(_kBio,        bio);
    if (location   != null) await _prefs.setString(_kLocation,   location);
    if (experience != null) await _prefs.setString(_kExperience, experience);
    if (username   != null) await _prefs.setString(_kUsername,   username);
    if (phone      != null) await _prefs.setString(_kPhone,      phone);
    if (email      != null) await _prefs.setString(_kEmail,      email);
    if (age        != null) await _prefs.setInt(_kAge,           age);
    state = state.copyWith(
      name:       name       ?? state.name,
      bio:        bio        ?? state.bio,
      location:   location   ?? state.location,
      experience: experience ?? state.experience,
      username:   username   ?? state.username,
      phone:      phone      ?? state.phone,
      email:      email      ?? state.email,
      age:        age        ?? state.age,
    );
  }

  Future<void> savePin(String pin) async {
    await _prefs.setString(_kPin, pin);
    state = state.copyWith(hasPin: true);
  }

  bool checkPin(String pin) => _prefs.getString(_kPin) == pin;

  Future<void> continueAsGuest() async {
    await _prefs.setBool(_kLoggedIn, true);
    await _prefs.setString(_kName, 'Explorer');
    await _prefs.setBool(_kProfileComplete, true);
    state = state.copyWith(
      isLoggedIn:      true,
      name:            'Explorer',
      profileComplete: true,
    );
  }

  Future<void> signOut() async {
    await _prefs.setBool(_kLoggedIn, false);
    await _prefs.setBool(_kProfileComplete, false);
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(sharedPrefsProvider));
});

// Temporary form data passed between auth screens.
// Cleared once auth completes.
final authFormProvider = StateProvider<({
  String name,
  String email,
  String phone,
  String signInMethod,
})?>((_) => null);

// Session-only guest flag — not persisted to SharedPreferences.
final sessionGuestProvider = StateProvider<bool>((_) => false);
