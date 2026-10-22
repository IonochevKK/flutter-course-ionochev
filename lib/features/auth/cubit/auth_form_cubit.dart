import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../entities/user/model/user.dart';
import '../../../entities/user/repository/auth_repository.dart';

enum AuthMode { login, register }

class AuthFormState extends Equatable {
  const AuthFormState({
    this.isSubmitting = false,
    this.role = Role.user,
    this.error,
    this.info,
    this.emailError,
    this.passwordError,
  });

  final bool isSubmitting;

  final Role role;

  final String? error;

  final String? info;
  final String? emailError;
  final String? passwordError;

  AuthFormState copyWith({
    bool? isSubmitting,
    Role? role,
    String? Function()? error,
    String? Function()? info,
    String? Function()? emailError,
    String? Function()? passwordError,
  }) {
    return AuthFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      role: role ?? this.role,
      error: error != null ? error() : this.error,
      info: info != null ? info() : this.info,
      emailError: emailError != null ? emailError() : this.emailError,
      passwordError: passwordError != null
          ? passwordError()
          : this.passwordError,
    );
  }

  @override
  List<Object?> get props => [
    isSubmitting,
    role,
    error,
    info,
    emailError,
    passwordError,
  ];
}

class AuthFormCubit extends Cubit<AuthFormState> {
  AuthFormCubit(this._repository, this.mode) : super(const AuthFormState());

  final AuthRepository _repository;
  final AuthMode mode;

  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? _validateEmail(String email) =>
      _emailRegExp.hasMatch(email) ? null : 'Введите корректный email';

  void setRole(Role role) => emit(state.copyWith(role: role));

  AuthFormState _clean() => AuthFormState(role: state.role);

  Future<void> submit({required String email, required String password}) async {
    final trimmedEmail = email.trim();
    final emailError = _validateEmail(trimmedEmail);
    final passwordError = password.length < 6 ? 'Минимум 6 символов' : null;
    if (emailError != null || passwordError != null) {
      emit(
        _clean().copyWith(
          emailError: () => emailError,
          passwordError: () => passwordError,
        ),
      );
      return;
    }

    emit(_clean().copyWith(isSubmitting: true));
    try {
      if (mode == AuthMode.login) {
        await _repository.signIn(email: trimmedEmail, password: password);
      } else {
        await _repository.signUp(
          email: trimmedEmail,
          password: password,
          role: state.role,
        );
      }
      if (isClosed) return;
      emit(_clean());
    } on AuthFailure catch (failure) {
      if (isClosed) return;
      final title = mode == AuthMode.login
          ? 'Не удалось войти'
          : 'Не удалось создать аккаунт';
      emit(
        _clean().copyWith(
          error: () => failure.field == null ? failure.message : title,
          emailError: () =>
              failure.field == AuthField.email ? failure.message : null,
          passwordError: () =>
              failure.field == AuthField.password ? failure.message : null,
        ),
      );
    }
  }

  Future<void> resetPassword(String email) async {
    final trimmedEmail = email.trim();
    final emailError = _validateEmail(trimmedEmail);
    if (emailError != null) {
      emit(_clean().copyWith(emailError: () => emailError));
      return;
    }

    emit(_clean().copyWith(isSubmitting: true));
    try {
      await _repository.sendPasswordReset(trimmedEmail);
      if (isClosed) return;
      emit(
        _clean().copyWith(
          info: () =>
              'Если аккаунт $trimmedEmail существует, мы отправили на него '
              'письмо со ссылкой для сброса пароля',
        ),
      );
    } on AuthFailure catch (failure) {
      if (isClosed) return;
      emit(
        _clean().copyWith(
          error: () => failure.field == null
              ? failure.message
              : 'Не удалось отправить письмо',
          emailError: () =>
              failure.field == AuthField.email ? failure.message : null,
        ),
      );
    }
  }
}
