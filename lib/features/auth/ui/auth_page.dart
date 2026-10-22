import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../entities/user/model/user.dart';
import '../../../entities/user/repository/auth_repository.dart';
import '../../../shared/router/routes.dart';
import '../../../shared/ui/labeled_field.dart';
import '../cubit/auth_form_cubit.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key, required this.mode});

  final AuthMode mode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(mode),
      create: (context) => AuthFormCubit(context.read<AuthRepository>(), mode),
      child: _AuthView(mode: mode),
    );
  }
}

class _AuthView extends StatefulWidget {
  const _AuthView({required this.mode});

  final AuthMode mode;

  @override
  State<_AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<_AuthView> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool get _isLogin => widget.mode == AuthMode.login;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthFormCubit>().submit(
      email: _email.text,
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: BlocBuilder<AuthFormCubit, AuthFormState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.menu_book_outlined,
                          color: scheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isLogin ? 'Вход' : 'Регистрация',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isLogin
                            ? 'Войдите, чтобы видеть каталог и своё избранное'
                            : 'Создайте аккаунт — избранное будет сохраняться за вами',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),
                      if (state.error != null) ...[
                        _Banner(state.error!),
                        const SizedBox(height: 20),
                      ],
                      if (state.info != null) ...[
                        _Banner(state.info!, isError: false),
                        const SizedBox(height: 20),
                      ],
                      LabeledField(
                        label: 'Email',
                        controller: _email,
                        hint: 'name@example.com',
                        errorText: state.emailError,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      LabeledField(
                        label: 'Пароль',
                        controller: _password,
                        hint: _isLogin ? null : 'Минимум 6 символов',
                        errorText: state.passwordError,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                      ),
                      if (_isLogin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: state.isSubmitting
                                ? null
                                : () => context
                                      .read<AuthFormCubit>()
                                      .resetPassword(_email.text),
                            child: const Text('Забыли пароль?'),
                          ),
                        )
                      else ...[
                        const SizedBox(height: 16),
                        Text(
                          'Роль',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<Role>(
                            segments: const [
                              ButtonSegment(
                                value: Role.user,
                                icon: Icon(Icons.person_outline),
                                label: Text('Пользователь'),
                              ),
                              ButtonSegment(
                                value: Role.admin,
                                icon: Icon(Icons.admin_panel_settings_outlined),
                                label: Text('Админ'),
                              ),
                            ],
                            selected: {state.role},
                            onSelectionChanged: state.isSubmitting
                                ? null
                                : (roles) => context
                                      .read<AuthFormCubit>()
                                      .setRole(roles.first),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Админ может редактировать и удалять любые книги',
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: state.isSubmitting ? null : _submit,
                        child: state.isSubmitting
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => context.go(
                                  Routes.withFrom(
                                    _isLogin ? Routes.register : Routes.login,
                                    GoRouterState.of(context)
                                        .uri
                                        .queryParameters[Routes.fromParam],
                                  ),
                                ),
                          child: Text(
                            _isLogin
                                ? 'Нет аккаунта? Зарегистрироваться'
                                : 'Уже есть аккаунт? Войти',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner(this.message, {this.isError = true});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = isError
        ? scheme.errorContainer
        : scheme.primaryContainer;
    final foreground = isError
        ? scheme.onErrorContainer
        : scheme.onPrimaryContainer;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.mark_email_read_outlined,
            color: foreground,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: foreground)),
          ),
        ],
      ),
    );
  }
}
