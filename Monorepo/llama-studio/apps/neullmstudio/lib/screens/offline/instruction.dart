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
          Text("Go to local server section and start the server",style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 30,),
          Text("* This is created to help developers to run models offline",style: Theme.of(context).textTheme.bodySmall,textAlign: TextAlign.left),
          Text("* Test your local model and train it according to your needs",style: Theme.of(context).textTheme.bodySmall,textAlign: TextAlign.left),
          Text("* Models are referred from hugging face",style: Theme.of(context).textTheme.bodySmall,textAlign: TextAlign.left),
          Text("* Fast API is used to host local http server",style: Theme.of(context).textTheme.bodySmall,textAlign: TextAlign.left),

        ],
      ),
    );
  }
}
