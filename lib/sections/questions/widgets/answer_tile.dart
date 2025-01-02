import 'package:flutter/material.dart';
import '../../../shared/constants/text_styles.dart';

class AnswerTile extends StatelessWidget {
  final String title;
  final int value;
  final int? groupValue;
  final ValueChanged<int?>? onChanged;
  final bool isCorrect;
  final bool showFeedback;

  const AnswerTile({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.isCorrect,
    required this.showFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      child: RadioListTile<int>(
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: kInactiveBoldTextStyle(context).copyWith(
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            if (showFeedback)
              Icon(
                isCorrect ? Icons.check : Icons.close,
                color: isCorrect ? Colors.green : Colors.red,
              ),
          ],
        ),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
    );
  }
}
