import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../models/protected_number.dart';
import '../services/protected_numbers_service.dart';
import 'pin_entry_dialog.dart';

class DialerScreen extends StatefulWidget {
  const DialerScreen({super.key});

  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen> {
  final _controller = TextEditingController();
  String? _status;

  Future<void> _call() async {
    final number = _controller.text.trim();
    if (number.isEmpty) return;

    setState(() => _status = null);

    final isProtected =
        await ProtectedNumbersService.isProtected(ProtectedNumber.normalize(number));

    if (isProtected) {
      final ok = await showPinEntryDialog(context);
      if (!ok) {
        setState(() => _status = 'Call cancelled: PIN not verified.');
        return;
      }
    }

    final success = await FlutterPhoneDirectCaller.callNumber(number);
    if (success != true && mounted) {
      setState(() => _status = 'Could not place the call.');
    }
  }

  void _appendDigit(String digit) {
    _controller.text += digit;
  }

  void _backspace() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      _controller.text = text.substring(0, text.length - 1);
    }
  }

  Widget _dialButton(String digit) {
    return SizedBox(
      width: 72,
      height: 72,
      child: OutlinedButton(
        onPressed: () => _appendDigit(digit),
        style: OutlinedButton.styleFrom(shape: const CircleBorder()),
        child: Text(digit, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              readOnly: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28),
              decoration: const InputDecoration(
                hintText: 'Enter number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  for (final d in [
                    '1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'
                  ])
                    Center(child: _dialButton(d)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.backspace_outlined),
                  onPressed: _backspace,
                ),
                FilledButton.icon(
                  onPressed: _call,
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
            if (_status != null) ...[
              const SizedBox(height: 8),
              Text(_status!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
