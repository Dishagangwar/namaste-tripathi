import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../shell/main_shell.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  void _choose(BuildContext context, JoinRole role) {
    context.read<SessionState>().setRole(role);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const BackButton(),
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'How would you like to join?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 27, fontWeight: FontWeight.w800, height: 1.2),
              ),
              const SizedBox(height: 14),
              const Text(
                'Select the path that best fits your needs. You can always '
                'change this later in your profile settings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: AppColors.muted, height: 1.55),
              ),
              const SizedBox(height: 34),
              _RoleCard(
                icon: Icons.person_search_rounded,
                title: 'I am a User',
                body: 'Discover and book premium services near you. From home '
                    'maintenance to personal care, find verified experts '
                    'instantly.',
                onTap: () => _choose(context, JoinRole.user),
              ),
              const SizedBox(height: 18),
              _RoleCard(
                icon: Icons.storefront_rounded,
                title: 'I am a Service Provider',
                body: 'List your business and reach a wider audience. Manage '
                    'bookings, client reviews, and grow your revenue '
                    'effortlessly.',
                onTap: () => _choose(context, JoinRole.provider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      radius: 22,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftIconBox(icon, size: 52, iconSize: 26),
          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
                fontSize: 13.5, color: AppColors.muted, height: 1.55),
          ),
        ],
      ),
    );
  }
}
