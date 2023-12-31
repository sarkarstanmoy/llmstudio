import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late String _selectedModel = "llama-7b-chat";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("Models:"),
                DropdownButtonHideUnderline(
                  child: DropdownButton(
                    items: const [
                      DropdownMenuItem(
                        child: Text("Llama-7b-chat"),
                        value: "llama-7b-chat",
                      ),
                      DropdownMenuItem(
                        child: Text("Llama-13b-chat"),
                        value: "llama-13b-chat",
                      )
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedModel = value!;
                      });
                    },
                    value: _selectedModel,
                  ),
                )
              ],
            ),
            Divider(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Temperature"),
                SizedBox(
                  width: 100,
                  height: 30,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '0.1',
                    ),
                  ),
                )
              ],
            ),
            Divider()
          ],
        ),
      ),
    ));
  }
}
