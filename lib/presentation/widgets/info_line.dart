import 'package:flutter/material.dart';

/// One line of an information overlay: "Age: 20". Lines sit close together
/// to save space.
class InfoLine extends StatelessWidget {
  const InfoLine({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: style?.copyWith(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value, style: style),
          ],
        ),
      ),
    );
  }
}
