import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/preferences/preferences_cubit.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<PreferencesCubit>().state.textSize;

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 4, 4, 10),
            child: Text('TEXT SIZE',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: AppColors.muted)),
          ),
          AppCard(
            padding: EdgeInsets.zero,
            child: RadioGroup<TextSize>(
              groupValue: selected,
              onChanged: (v) => v == null
                  ? null
                  : context.read<PreferencesCubit>().setTextSize(v),
              child: Column(
                children: [
                  for (final size in TextSize.values)
                    RadioListTile<TextSize>(
                      value: size,
                      title: Text(size.label),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Text(
              'The quick brown fox jumps over the lazy dog.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.text,
              ),
              textScaler: TextScaler.noScaling,
            ),
          ),
        ],
      ),
    );
  }
}
