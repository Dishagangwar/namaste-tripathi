import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/session/session_bloc.dart';
import '../../core/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name =
      TextEditingController(text: context.read<SessionBloc>().state.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<SessionBloc>().add(SessionNameChanged(_name.text.trim()));
    Navigator.pop(context);
    showAppSnack(context, 'Profile updated.');
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionBloc>().state;
    final phone = session.phone.isEmpty
        ? 'Signed in with Google'
        : '${session.countryCode} ${session.phone}';

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
            ),
            const SizedBox(height: 16),
            // The sign-in identity is not editable here: changing it would
            // mean changing the account.
            TextFormField(
              initialValue: phone,
              enabled: false,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        actionLabel: 'Save changes',
        onAction: _save,
      ),
    );
  }
}
