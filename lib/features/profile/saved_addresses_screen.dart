import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/preferences/preferences_cubit.dart';
import '../../bloc/session/session_bloc.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  Future<void> _edit(BuildContext context, [SavedAddress? existing]) async {
    final cubit = context.read<PreferencesCubit>();
    final result = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => _AddressSheet(existing: existing),
    );
    if (result == null) return;
    if (existing == null) {
      cubit.addAddress(result.$1, result.$2);
    } else {
      cubit.updateAddress(SavedAddress(
          id: existing.id, label: result.$1.trim(), address: result.$2.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final addresses = context.watch<PreferencesCubit>().state.addresses;
    final current = context.watch<SessionBloc>().state.address;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved addresses')),
      body: addresses.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No saved addresses yet.\nAdd one to pick it quickly at checkout.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final a = addresses[i];
                final isCurrent = a.address == current;
                return AppCard(
                  onTap: () {
                    context
                        .read<SessionBloc>()
                        .add(SessionLocationChanged(a.label, a.address));
                    showAppSnack(context, 'Delivering to ${a.label}.');
                  },
                  child: Row(
                    children: [
                      SoftIconBox(
                          isCurrent
                              ? Icons.check_circle_rounded
                              : Icons.location_on_outlined,
                          size: 42,
                          iconSize: 20),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.label,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(a.address,
                                style: const TextStyle(
                                    fontSize: 12.5, color: AppColors.muted)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _edit(context, a),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 20, color: AppColors.danger),
                        onPressed: () => context
                            .read<PreferencesCubit>()
                            .removeAddress(a.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add address'),
      ),
    );
  }
}

/// Owns its controllers so they are disposed with the sheet, after it has
/// finished closing, rather than while it is still animating away.
class _AddressSheet extends StatefulWidget {
  const _AddressSheet({this.existing});
  final SavedAddress? existing;

  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<_AddressSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _label = TextEditingController(text: widget.existing?.label);
  late final _address = TextEditingController(text: widget.existing?.address);

  @override
  void dispose() {
    _label.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.existing == null ? 'Add address' : 'Edit address',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _label,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      labelText: 'Label', hintText: 'Home, Work…'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Give it a label'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _address,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (v) => (v == null || v.trim().length < 5)
                      ? 'Enter the full address'
                      : null,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, (_label.text, _address.text));
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
