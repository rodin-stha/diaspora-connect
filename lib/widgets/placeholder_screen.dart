import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// Temporary screen for tabs that haven't been designed yet.
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          title,
          style: TTextStyles.titleMedium.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
