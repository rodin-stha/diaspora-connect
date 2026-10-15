import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/sizes.dart';
import '../../widgets/app_background.dart';
import '../announcements/widgets/announcements_section.dart';
import '../profile/data/user_provider.dart';
import 'widgets/home_actions.dart';
import 'widgets/home_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // White status bar icons on the blue header
      value: SystemUiOverlayStyle.light,
      child: AppBackground(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeHeader(
                  userName: user.givenName,
                  location: user.location,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.pagePadding,
                    vertical: TSizes.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [AnnouncementsSection(), HomeActions()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
