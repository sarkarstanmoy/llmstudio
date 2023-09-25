import 'package:flutter/material.dart';

class LocalServerWeb extends StatelessWidget {
  const LocalServerWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Local Server",style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 30,),
          Text("* Local server will work on windows version",style: Theme.of(context).textTheme.bodySmall,textAlign: TextAlign.left),

        ],
      ),
    );
  }
}
