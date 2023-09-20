import 'dart:async';
import 'dart:typed_data';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:neu_llm_studio/common/common.dart';

import '../../common/prompt_model.dart';
import '../../infrastructure/llama_provider.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  final List<PromptModel> prompts = <PromptModel>[];
  var showLoading = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final promptController = TextEditingController();
    return Scaffold(
      appBar: Common().CustomAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: "Prompt: ",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)),
                            TextSpan(
                                text: prompts[index].question,
                                style: Theme.of(context).textTheme.labelLarge)
                          ])),
                          AnimatedTextKit(
                            isRepeatingAnimation: false,
                            stopPauseOnTap: true,
                            animatedTexts: [
                              TyperAnimatedText(prompts[index].answer)
                            ],
                          )
                        ],
                      );
                    },
                    itemCount: prompts.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider();
                    })),
            showLoading ? CircularProgressIndicator() : Container(),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      prompts.clear();
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
                      setState(() {
                        showLoading = true;
                      });
                      var promptModel = PromptModel();
                      promptModel.question = value;
                      var response = await LlamaProvider().getResponse(value);
                      promptModel.answer = response.response;
                      setState(() {
                        prompts.add(promptModel);
                        showLoading = false;
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
}
