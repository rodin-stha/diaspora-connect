import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/initials_avatar.dart';
import '../models/user_profile.dart';

/// Blue header with the user's avatar, name and location.
class ProfileHeader extends StatelessWidget {
  final UserProfile user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        TSizes.pagePadding,
        topPadding,
        TSizes.pagePadding,
        TSizes.pagePadding,
      ),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(TSizes.headerRadius),
        ),
      ),
      child: Row(
        children: [
          InitialsAvatar(
            name: user.fullName,
            size: TSizes.avatarLg,
            backgroundColor: colors.onPrimaryMuted,
            foregroundColor: colors.onPrimary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: TTextStyles.appBarTitle.copyWith(
                    color: colors.onPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.location,
                  style: TTextStyles.bodySmall.copyWith(
                    color: colors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
