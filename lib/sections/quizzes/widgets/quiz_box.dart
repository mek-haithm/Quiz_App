import 'package:flutter/material.dart';
import 'package:quiz_app/shared/constants/sizes.dart';
import '../../../shared/constants/text_styles.dart';

class QuizBox extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String description;

  const QuizBox({
    super.key,
    required this.title,
    required this.onTap,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.6),
              offset: const Offset(2, 2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.6),
              offset: const Offset(-2, -2),
              blurRadius: 4,
              spreadRadius: -1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: kInactiveBoldTextStyle(context).copyWith(
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            kSizedBoxHeight_15,
            Text(
              description,
              style: kInactiveTextStyle(context).copyWith(
                fontSize: 15.0,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
