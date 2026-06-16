import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../models/protected_number.dart';
import '../services/protected_numbers_service.dart';
import 'pin_entry_dialog.dart';

class ManageNumbersScreen extends StatefulWidget {
  const ManageNumbersScreen({super.key});

  @override
  State<ManageNumbersScreen> createState() => _ManageNumbersScreenState();
}

class _ManageNumbersScreenState extends State<ManageNumbersScreen> {
  List<ProtectedNumber> _numbers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final numbers = await ProtectedNumbersService.getAll();
    setState(() {
      _numbers = numbers;
      _loading = false;
    });
  }

  Future<void> _addFromContacts() async {
    try {
      final granted = await FlutterContacts.requestPermission(readonly: true);
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contacts permission denied.')),
          );
        }
        return;
      }

      final contacts = await FlutterContacts.getContacts(withProperties: true);
      if (!mounted) return;

      final selected = await showModalBottomSheet<Contact>(
        context: context,
        isScrollControlled: true,
        builder: (context) => _ContactPickerSheet(contacts: contacts),
      );

      if (selected == null) return;

      final phones = selected.phones;
      if (phones.isEmpty) return;

      String number;
      if (phones.length == 1) {
        number = phones.first.number;
      } else {
        final chosen = await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Select number'),
            children: phones
                .map((p) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, p.number),
                      child: Text(p.number),
                    ))
                .toList(),
          ),
        );
        if (chosen == null) return;
        number = chosen;
      }

      if (number.isEmpty) return;

      await ProtectedNumbersService.add(
        ProtectedNumber(
          displayName: selected.displayName.isEmpty ? number : selected.displayName,
          number: number,
        ),
      );
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not read contacts: $e')),
        );
      }
    }
  }

  Future<void> _addManually() async {
    final controller = TextEditingController();
    final nameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add number manually'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Label (optional)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      final number = controller.text.trim();
      final name =
          nameController.text.trim().isEmpty ? number : nameController.text.trim();
      await ProtectedNumbersService.add(
        ProtectedNumber(displayName: name, number: number),
      );
      _load();
    }
  }

  Future<void> _remove(ProtectedNumber number) async {
    // Require PIN to remove a number, so it can't be casually bypassed.
    final ok = await showPinEntryDialog(context);
    if (!ok) return;
    await ProtectedNumbersService.remove(number);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protected numbers')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _numbers.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No protected numbers yet. Add one from your contacts '
                      'or manually using the buttons below.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _numbers.length,
                  itemBuilder: (context, index) {
                    final n = _numbers[index];
                    return ListTile(
                      leading: const Icon(Icons.lock),
                      title: Text(n.displayName),
                      subtitle: Text(n.number),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _remove(n),
                      ),
                    );
                  },
                ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'contacts',
            onPressed: _addFromContacts,
            icon: const Icon(Icons.contacts),
            label: const Text('From contacts'),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'manual',
            onPressed: _addManually,
            icon: const Icon(Icons.edit),
            label: const Text('Manual'),
          ),
        ],
      ),
    );
  }
}

class _ContactPickerSheet extends StatelessWidget {
  final List<Contact> contacts;

  const _ContactPickerSheet({required this.contacts});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return ListView.builder(
          controller: scrollController,
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final c = contacts[index];
            return ListTile(
              title: Text(c.displayName.isEmpty ? 'Unknown' : c.displayName),
              subtitle: Text(
                c.phones.isNotEmpty ? c.phones.first.number : 'No number',
              ),
              onTap: () => Navigator.pop(context, c),
            );
          },
        );
      },
    );
  }
}
