import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/pin_service.dart';

/// Shows a modal asking the user to enter their PIN.
/// Returns true if the correct PIN was entered, false if cancelled or wrong
/// after the allowed attempts.
Future<bool> showPinEntryDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _PinEntryDialog(),
  );
  return result ?? false;
}

class _PinEntryDialog extends StatefulWidget {
  const _PinEntryDialog();

  @override
  State<_PinEntryDialog> createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<_PinEntryDialog> {
  final _controller = TextEditingController();
  String? _error;
  int _attempts = 0;
  static const _maxAttempts = 3;

  Future<void> _submit() async {
    final ok = await PinService.verifyPin(_controller.text);
    if (ok) {
      if (mounted) Navigator.pop(context, true);
      return;
    }

    _attempts++;
    if (_attempts >= _maxAttempts) {
      if (mounted) Navigator.pop(context, false);
      return;
    }

    setState(() {
      _error = 'Incorrect PIN. ${_maxAttempts - _attempts} attempt(s) left.';
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('PIN required'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('This number is protected. Enter your PIN to call it.'),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 8,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'PIN',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
