import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../common/globals.dart' as globals;

List<String> list = <String>['Select Model', 'Llama-7b', 'Falcon-7b', 'MPT'];

class LocalServer extends StatefulWidget {
  const LocalServer({super.key});

  @override
  State<LocalServer> createState() => _LocalServerState();
}

class _LocalServerState extends State<LocalServer> {
  String dropdownValue = list.first;
  //late Process process;
  late String status = "Server status \n";

  startServer() async {
    globals.serverProcess = await Process.start(
        'uvicorn', ['main:app', '--port=8000', '--reload'],
        workingDirectory:
            "C://Learnings//LLM//LLMStudio//llmstudio//Monorepo//llama-studio//apps//server",
        runInShell: true);
    globals.serverProcess!.stdout.transform(utf8.decoder).forEach((s) {
      setState(() {
        status = status + s + "\n";
      });
    });
    globals.serverProcess!.stderr.transform(utf8.decoder).forEach((s) {
      setState(() {
        status = status + s + "\n";
      });
    });
  }

  stopServer() {
    if (globals.serverProcess!.kill()) {
      globals.serverProcess = null;
      setState(() {
        status = status + "Stopped successfully" + "\n";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(
        child: DropdownMenu<String>(
          initialSelection: list.first,
          onSelected: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              dropdownValue = value!;
            });
          },
          dropdownMenuEntries:
              list.map<DropdownMenuEntry<String>>((String value) {
            return DropdownMenuEntry<String>(value: value, label: value);
          }).toList(),
        ),
      ),
      const Divider(),
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: [
            Column(
        crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: "Local Inference Server",
                        style: Theme.of(context).textTheme.headlineSmall),
                  ])),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                  child: Text("Start a local HTTP Server on your chosen port"),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child:
                      Text("This is used to train local models using prompt"),
                ),
                Text(
                  "Select model from drop down to start",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Text("Server Options",
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 30, 30, 0),
                      child: Text("Server Port"),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: SizedBox(
                        width: 100,
                        height: 50,
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '8000',
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),

             Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,20,0,0),
                  child: const Text("Example client request "),
                ),
                Text("Run this code in your terminal",style: Theme.of(context).textTheme.bodySmall,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 200,
                    width: 300,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1,color: Theme.of(context).colorScheme.primary)
                    ),
                    child: Text(""),
                  ),
                )


              ],
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(100, 10, 0, 0),
        child: Row(
          children: [
            ElevatedButton(
                onPressed: () {
                  startServer();
                },
                child: const Text("START")),
            ElevatedButton(
                onPressed: () {
                  stopServer();
                },
                child: const Text("STOP"))
          ],
        ),
      ),
      const Divider(),
      Expanded(
        child: SingleChildScrollView(
          child: Text(
            status,
            style: const TextStyle(fontFamily: "IBMPlexMono", fontSize: 12.0),
          ),
        ),
      ),
    ])));
  }
}
