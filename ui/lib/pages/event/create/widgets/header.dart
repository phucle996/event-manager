import 'package:flutter/material.dart';

class EventFormHeader extends StatelessWidget {
  final String title;
  const EventFormHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Text(
      title,
      style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
