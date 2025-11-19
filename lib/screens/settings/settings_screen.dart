import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          ListTile(leading: Icon(Icons.palette), title: Text('Theme Settings')),
          ListTile(
            leading: Icon(Icons.print),
            title: Text('Printer Configuration'),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About This App'),
          ),
        ],
      ),
    );
  }
}
