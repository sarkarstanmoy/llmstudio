import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../common/prompt_model.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  final List<PromptModel> prompts = <PromptModel>[];
  final streamController = StreamController();
  var showLoading = false;
  var showStop = false;
  var _channel = WebSocketChannel.connect(
    // Uri.parse('ws://127.0.0.1:8000/chat'),
    Uri.parse(
        'wss://llamapubsub.webpubsub.azure.com/client/hubs/myhub1?access_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJ3c3M6Ly9sbGFtYXB1YnN1Yi53ZWJwdWJzdWIuYXp1cmUuY29tL2NsaWVudC9odWJzL0h1YiIsImlhdCI6MTY5NTExMjE2MywiZXhwIjoxNjk1MTE1NzYzfQ.EzK8lOsxIu7-lGQCRwKp5cAj_-s2IGQtuIQSpJCH7Mo'),
  );

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final promptController = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                  reverse: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        "Prompt: ${prompts[index].question}",
                        maxLines: 100,
                      ),
                      subtitle:
                          Text("LLM: ${prompts[index].answer}", maxLines: 100),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: prompts.length - 1 < 0 ? 0 : prompts.length - 1),
            ),
            prompts.isEmpty
                ? Text("Ask Question?")
                : StreamBuilder(
                    stream: _channel.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        prompts.last.answer =
                            prompts.last.answer + snapshot.data;
                        streamController.add(prompts.last.answer
                            .replaceAll("''", "")
                            .replaceAll("\\n", "\n"));
                        prompts.last.answer = prompts.last.answer
                            .replaceAll("''", "")
                            .replaceAll("\\n", "\n");
                      }
                      return Expanded(
                        child: Center(
                            child: SingleChildScrollView(
                                child: ListTile(
                          title: Text("Prompt: ${prompts.last.question}",
                              maxLines: 100),
                          subtitle: Text("LLM: ${prompts.last.answer}",
                              maxLines: 100),
                        ))),
                      );
                    },
                  ),
            showLoading ? const CircularProgressIndicator() : Container(),
            showStop
                ? ElevatedButton(
                    onPressed: () {
                      _channel.sink.close();
                    },
                    child: Text("Stop"))
                : Container(),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      prompts.clear();
                      _channel.sink.close();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: promptController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) async {
                      if (_channel.closeCode != null) {
                        _channel = WebSocketChannel.connect(
                          //Uri.parse('ws://127.0.0.1:8000/chat'),
                          Uri.parse(
                              'wss://llamapubsub.webpubsub.azure.com/client/hubs/myhub1?access_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJ3c3M6Ly9sbGFtYXB1YnN1Yi53ZWJwdWJzdWIuYXp1cmUuY29tL2NsaWVudC9odWJzL0h1YiIsImlhdCI6MTY5NTExMjE2MywiZXhwIjoxNjk1MTE1NzYzfQ.EzK8lOsxIu7-lGQCRwKp5cAj_-s2IGQtuIQSpJCH7Mo'),
                        );
                      }
                      setState(() {
                        showLoading = true;
                      });
                      var promptModel = PromptModel();
                      promptModel.question = value;
                      promptModel.answer = "";
                      _channel.sink.add(value);
                      setState(() {
                        prompts.add(promptModel);
                        showLoading = false;
                        showStop = true;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Send a message',
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            setState(() {
                              //prompts.add(promptController.text);
                            });
                          }),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 3,
                              color: Theme.of(context).colorScheme.onPrimary)),
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
