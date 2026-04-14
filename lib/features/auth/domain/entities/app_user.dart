import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  String get name => displayName ?? email.split('@').first;

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}
