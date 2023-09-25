import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neu_llm_studio/infrastructure/llama_provider.dart';
import 'package:neu_llm_studio/screens/offline/instruction.dart';

import '../../common/globals.dart' as globals;


class Offline extends StatefulWidget {
  const Offline({super.key});

  @override
  State<Offline> createState() => _OfflineState();
}

class _OfflineState extends State<Offline> {
  late Timer _timer;
  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if(globals.serverProcess != null){
        setState(() {});

      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !globals.IsWeb && globals.serverProcess == null ? Instruction() :  FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: SizedBox(
                      height: 200,
                      width: 400,
                      child: Card(
                        child: Center(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${snapshot.data!.cpu_percentage}%",
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            ),
                            const Text("CPU Percentage"),
                            Text(
                              "${snapshot.data!.ram_used}/${snapshot.data!.ram_total}",
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            ),
                            Text("Memory usage")
                          ],
                        )),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: SizedBox(
                      height: 200,
                      width: 400,
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Llama-7b-gguf",
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            ),
                            Text("Model Used"),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: SizedBox(
                      height: 200,
                      width: 400,
                      child: Card(
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${snapshot.data!.disk_used}/${snapshot.data!.disk_available}",
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            ),
                            Text("Disk Usages"),
                          ],
                        )),
                      ),
                    ),
                  )
                ],
              ),
            ]);
          } else {
            return Center(child: const CircularProgressIndicator());
          }
        },
        future: LlamaProvider().getSystemData(),
      ),
    );
  }
}
