import 'package:flutter/material.dart';

import '../../common/common.dart';

class Offline extends StatelessWidget {
  const Offline({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Common().CustomAppBar(),
      body: Center(child: Text("Offline"))
    );
  }
}
