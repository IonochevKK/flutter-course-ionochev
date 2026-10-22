import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../entities/user/cubit/auth_cubit.dart';
import '../../../entities/user/cubit/favorites_cubit.dart';
import '../../../entities/user/repository/auth_repository.dart';
import '../../../shared/theme/theme_cubit.dart';

class CatalogStats {
  const CatalogStats({required this.totalCount, required this.bookIds});

  final int totalCount;
  final Set<String> bookIds;
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.stats});

  final CatalogStats? stats;

  Future<void> _resetPassword(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final email = context.read<AuthCubit>().state.user?.email ?? '';
    try {
      await context.read<AuthCubit>().sendPasswordReset();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Письмо для сброса пароля отправлено на $email'),
        ),
      );
    } on AuthFailure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = context.select((AuthCubit c) => c.state.user);
    final stats = this.stats;
    final favoritesCount = context.select(
      (FavoritesCubit c) =>
          stats == null ? null : c.state.countAmong(stats.bookIds),
    );
    final isDark = context.select((ThemeCubit c) => c.isDark);
    final email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              child: Text(
                email.isEmpty ? '?' : email[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              email,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          if (user?.isAdmin ?? false)
            Center(
              child: Text(
                'Администратор',
                style: TextStyle(fontSize: 12, color: scheme.primary),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: stats == null ? '—' : '${stats.totalCount}',
                  label: 'В каталоге',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  value: favoritesCount == null ? '—' : '$favoritesCount',
                  label: 'В избранном',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Сбросить пароль'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _resetPassword(context),
              ),
              Divider(height: 1, color: scheme.outlineVariant),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Тёмная тема'),
                value: isDark,
                onChanged: context.read<ThemeCubit>().setDark,
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.read<AuthCubit>().signOut(),
            style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
            child: const Text('Выйти из аккаунта'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Section(
      padding: const EdgeInsets.all(14),
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children, this.padding = EdgeInsets.zero});

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
