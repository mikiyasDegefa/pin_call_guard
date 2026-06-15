import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/pin_service.dart';
import 'dialer_screen.dart';
import 'manage_numbers_screen.dart';
import 'pin_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasPin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _requestPermissions();
    final hasPin = await PinService.hasPin();
    setState(() {
      _hasPin = hasPin;
      _loading = false;
    });
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.contacts,
      Permission.phone,
    ].request();
  }

  Future<void> _refresh() async {
    final hasPin = await PinService.hasPin();
    setState(() => _hasPin = hasPin);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('PIN Call Guard')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.shield_outlined, size: 72, color: Colors.indigo),
            const SizedBox(height: 16),
            Text(
              _hasPin
                  ? 'Your PIN is set up. Numbers in your protected list will '
                      'require the PIN before calling.'
                  : 'Set up a PIN first to start protecting numbers.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.lock_outline),
              label: Text(_hasPin ? 'Change PIN' : 'Set up PIN'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PinSetupScreen(),
                  ),
                );
                _refresh();
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.contacts_outlined),
              label: const Text('Manage protected numbers'),
              onPressed: _hasPin
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageNumbersScreen(),
                        ),
                      );
                    }
                  : null,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.dialpad),
              label: const Text('Open dialer'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DialerScreen()),
                );
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'How it works',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Set a PIN.\n'
              '2. Add numbers (e.g. 1122) to the protected list, from your '
              'contacts or manually.\n'
              '3. Use the in-app dialer to call any number. If the number '
              'is protected, you must enter the correct PIN before the '
              'call is placed. Other numbers dial normally.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
