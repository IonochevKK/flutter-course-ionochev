import 'package:flutter/material.dart';

class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.isError = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isError ? scheme.errorContainer : scheme.surface,
                shape: BoxShape.circle,
                border: isError
                    ? null
                    : Border.all(color: scheme.outlineVariant),
              ),
              child: Icon(
                icon,
                size: 30,
                color: isError ? scheme.error : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 160,
                child: isError
                    ? FilledButton(
                        onPressed: onAction,
                        child: Text(actionLabel!),
                      )
                    : OutlinedButton(
                        onPressed: onAction,
                        child: Text(actionLabel!),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
