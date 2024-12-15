import 'package:flutter/material.dart';

class feedbacks extends StatefulWidget {
  const feedbacks({super.key});

  @override
  State<feedbacks> createState() => _feedbacksState();
}

class _feedbacksState extends State<feedbacks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: ListView(),
    );
  }
}