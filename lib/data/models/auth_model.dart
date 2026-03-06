
import 'user_model.dart';

class AuthModel {
  final bool isLoading;
  final bool isObsecure;
  final int time;
  final UserModel user;

  AuthModel({
    required this.isLoading,
    required this.isObsecure,
    required this.time,
    required this.user,
  });
  AuthModel copyWith({
    bool? isLoading,
    bool? isObsecure,
    int? time,
    UserModel? user,
  }) {
    return AuthModel(
      isLoading: isLoading ?? this.isLoading,
      isObsecure: isObsecure ?? this.isObsecure,
      time: time ?? this.time,
      user: user ?? this.user,
    );
  }
}
