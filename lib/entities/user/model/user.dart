import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum Role { user, admin }

class AppUser extends Equatable {
  final String uid;
  final String email;
  final String name;
  final Role role;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.role = Role.user,
  });

  bool get isAdmin => role == Role.admin;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] == 'admin' ? Role.admin : Role.user,
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'name': name, 'role': role.name};
  }

  @override
  List<Object?> get props => [uid, email, name, role];
}
