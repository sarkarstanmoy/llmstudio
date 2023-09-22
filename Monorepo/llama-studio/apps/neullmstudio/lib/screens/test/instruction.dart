import 'package:flutter/material.dart';

class Instruction extends StatelessWidget {
  const Instruction({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Chat with Large Language Model",style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 30,),
          Text("* Chat with model using send",style: Theme.of(context).textTheme.bodySmall,textAlign: TextAlign.left),
          Text("* Remove all the chat history using Refresh icon",style: Theme.of(context).textTheme.bodySmall,textAlign: TextAlign.left),
          Text("* Send icons is for smaller devices. Use ENTER to send message",style: Theme.of(context).textTheme.bodySmall,textAlign: TextAlign.left),

        ],
      ),
    );
  }
}
