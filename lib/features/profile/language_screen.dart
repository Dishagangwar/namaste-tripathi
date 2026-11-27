import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/preferences/preferences_cubit.dart';
import '../../core/theme.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<PreferencesCubit>().state.language;

    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: ListView(
        children: [
          RadioGroup<String>(
            groupValue: selected,
            onChanged: (v) => v == null
                ? null
                : context.read<PreferencesCubit>().setLanguage(v),
            child: Column(
              children: [
                for (final l in AppLanguage.all)
                  RadioListTile<String>(
                    value: l.code,
                    title: Text(l.nativeName),
                    subtitle: Text(l.name),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              'Your choice is saved. Screens will switch language as '
              'translations are added.',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
