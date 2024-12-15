import 'package:flutter/material.dart';

class NewTop extends StatefulWidget {
  const NewTop({super.key});

  @override
  State<NewTop> createState() => _NewTopState();
}

class _NewTopState extends State<NewTop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Top'),
      ),
      body: ListView(),
    );
  }
}
