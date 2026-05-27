import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watch_earn_4/widgets/app_button.dart';
import 'package:watch_earn_4/widgets/common_appbar.dart';
import 'package:watch_earn_4/widgets/loading_overlay/loading_overlay.dart';

import '../../extension/ext_context.dart';
import '../../extension/ext_string_alert.dart';
import '../../res/theme_colors.dart';
import '../../res/theme_text_colors.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/remote_config.dart';
import '../login/provider/auth_provider.dart';
import 'provider/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: const _ProfileBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ProfileBody extends StatefulWidget {
  const _ProfileBody();

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'profile',
      screenClass: 'ProfileScreen',
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final colors = context.themeColors;
    final textColors = context.themeTextColors;
    final user = provider.user;

    final level = user?.level ?? 1.0;
    final xp = user?.xp ?? 0.0;
    final name = user?.name ?? 'User';
    final email = user?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: CommonAppBar(titleText: context.l10n.profile, showLeading: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
          child: Column(
            children: [
              SizedBox(height: AppSize.h28),

              // Avatar
              _Avatar(initial: initial)
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 450.ms)
                  .scale(
                    begin: const Offset(0.75, 0.75),
                    end: const Offset(1, 1),
                    delay: 80.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),

              SizedBox(height: AppSize.h14),

              // Name
              Text(
                name,
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: AppSize.sp20,
                  fontWeight: FontWeight.w700,
                  color: textColors.textBlackColor,
                ),
              ).animate().fadeIn(delay: 140.ms, duration: 400.ms),

              SizedBox(height: AppSize.h4),

              // Email
              Text(
                email,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: textColors.hintTextColor,
                  fontSize: AppSize.sp14,
                ),
              ).animate().fadeIn(delay: 180.ms, duration: 400.ms),

              SizedBox(height: AppSize.h14),

              // Level badge
              _LevelBadge(
                level: level,
                levelName: provider.levelName(level),
              ).animate().fadeIn(delay: 220.ms, duration: 400.ms),

              SizedBox(height: AppSize.h24),

              // Level progress card
              _LevelProgressCard(
                progress: provider.levelProgress(xp),
                nextLevel: provider.nextLevelName(level),
                colors: colors,
                textColors: textColors,
              )
                  .animate()
                  .fadeIn(delay: 280.ms, duration: 400.ms)
                  .slideY(
                    begin: 0.08,
                    end: 0,
                    delay: 280.ms,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),

              SizedBox(height: AppSize.h16),

              // Settings card
              _buildSettingsCard(context, provider, colors, textColors)
                  .animate()
                  .fadeIn(delay: 340.ms, duration: 400.ms)
                  .slideY(
                    begin: 0.08,
                    end: 0,
                    delay: 340.ms,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),

              SizedBox(height: AppSize.h32),

              // Sign Out
              GestureDetector(
                onTap: () => _handleSignOut(context, provider),
                child: Text(
                  context.l10n.signOut,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.primary,
                    fontSize: AppSize.sp16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              SizedBox(height: AppSize.h24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    ProfileProvider provider,
    ThemeColors colors,
    ThemeTextColors textColors,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r20),
        boxShadow: [
          BoxShadow(
            color: context.themeColors.cardShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (provider.user?.isGuest == true)
            _SettingsTile(
              icon: Icons.link_rounded,
              label: context.l10n.linkGoogleAccount,
              onTap: () => _handleLinkGoogle(context),
              trailing: _buildChevron(context),
              textColors: textColors,
            ),
          // _SettingsTile(
          //   icon: Icons.volume_up_rounded,
          //   label: context.l10n.soundEffects,
          //   trailing: _buildSwitch(context, provider.soundEffects, provider.toggleSoundEffects),
          //   textColors: textColors,
          // ),
          // _SettingsTile(
          //   icon: Icons.vibration_rounded,
          //   label: context.l10n.hapticFeedback,
          //   trailing: _buildSwitch(context, provider.hapticFeedback, provider.toggleHapticFeedback),
          //   textColors: textColors,
          // ),
          _SettingsTile(
            icon: Icons.star_outline_rounded,
            label: context.l10n.rateUs,
            onTap: _handleRateUs,
            trailing: _buildChevron(context),
            textColors: textColors,
          ),
          _SettingsTile(
            icon: Icons.translate_rounded,
            label: context.l10n.language,
            onTap: () => context.pushNamed(AppRoutes.language, extra: true),
            trailing: _buildChevron(context),
            textColors: textColors,
          ),
          // _divider(),
          _SettingsTile(
            icon: Icons.headset_mic_rounded,
            label: context.l10n.support,
            onTap: () => context.pushNamed(AppRoutes.contactUs),
            trailing: _buildChevron(context),
            textColors: textColors,
          ),
          // _divider(),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            label: context.l10n.privacyPolicy,
            onTap: () => _launchUrl(
              RemoteConfigService.instance.privacyPolicyUrl,
              'Privacy Policy',
            ),
            trailing: _buildChevron(context),
            textColors: textColors,
          ),
          // _divider(),
          _SettingsTile(
            icon: Icons.description_outlined,
            label: context.l10n.termsAndCondition,
            onTap: () => _launchUrl(
              RemoteConfigService.instance.termsAndConditions,
              'Terms & Conditions',
            ),
            trailing: _buildChevron(context),
            textColors: textColors,
          ),
          _SettingsTile(
            icon: Icons.delete_forever_outlined,
            label: context.l10n.deleteAccount,
            onTap: () => _handleDeleteAccount(context, provider),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colors.buttonColor2,
              size: AppSize.sp22,
            ),
            textColors: textColors,
            iconColor: colors.buttonColor2,
            labelColor: colors.buttonColor2,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildChevron(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      color: context.themeTextColors.bodyTextColor,
      size: AppSize.sp22,
    );
  }

  Future<void> _handleRateUs() async {
    AnalyticsManager.instance.logEvent(name: 'profile_rate_us_tap');
    try {
      final info = await PackageInfo.fromPlatform();
      final url = 'https://play.google.com/store/apps/details?id=${info.packageName}';
      await _launchUrl(url, 'Rate Us');
    } catch (e) {
      debugPrint('Rate Us: launch failed: $e');
    }
  }

  Future<void> _handleLinkGoogle(BuildContext context) async {
    AnalyticsManager.instance.logEvent(name: 'profile_link_google_tap');
    final auth = AuthProvider();
    await auth.linkGoogleAccount();

    if (!context.mounted) return;
    if (auth.linkSuccess) {
      AnalyticsManager.instance.logEvent(name: 'profile_link_google_success');
      context.l10n.googleAccountLinkedSuccess.showSuccessAlert();
      setState(() {});
    } else if (auth.linkErrorMessage != null) {
      AnalyticsManager.instance.logEvent(
        name: 'profile_link_google_failed',
        parameters: {'error': auth.linkErrorMessage ?? 'unknown'},
      );
      auth.linkErrorMessage!.showErrorAlert();
    }
  }

  Future<void> _handleSignOut(
    BuildContext context,
    ProfileProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.themeColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.r16),
        ),
        title: Text(
          ctx.l10n.signOut,
          style: ctx.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: ctx.themeTextColors.textBlackColor,
          ),
        ),
        content: Text(
          ctx.l10n.areYouSureSignOut,
          style: ctx.textTheme.bodyMedium?.copyWith(
            color: ctx.themeTextColors.hintTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              ctx.l10n.cancel,
              style: TextStyle(color: ctx.themeTextColors.hintTextColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              ctx.l10n.signOut,
              style: TextStyle(
                color: ctx.themeColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.signOut();
      if (context.mounted) context.goNamed(AppRoutes.login);
    }
  }

  Future<void> _handleDeleteAccount(
    BuildContext context,
    ProfileProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _DeleteAccountDialog(),
    );
    if (confirmed != true || !context.mounted) return;

    LoadingOverlay.instance().show(
      context: context,
      text: context.l10n.deletingAccount,
    );
    try {
      await provider.deleteAccount();
    } finally {
      LoadingOverlay.instance().hide();
    }

    if (context.mounted) context.goNamed(AppRoutes.login);
  }

  Future<void> _launchUrl(String url, String label) async {
    if (url.isEmpty) {
      'No URL configured for $label.'.showInfoAlert();
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
      'Could not open $label.'.showErrorAlert();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.w100,
      height: AppSize.w100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.r26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.themeColors.buttonColor, Color(0xFF494EF6)],
        ),
        boxShadow: [
          BoxShadow(
            color: context.themeColors.buttonColor.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        textAlign: TextAlign.center,
        style: context.textTheme.titleMedium?.copyWith(
          fontSize: AppSize.sp40,
          color: context.themeColors.whiteColor,
        )
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Level badge
// ─────────────────────────────────────────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level, required this.levelName});

  final double level;
  final String levelName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w16,
        vertical: AppSize.h8,
      ),
      decoration: BoxDecoration(
        color: context.themeColors.coinSurfaceColor,
        borderRadius: BorderRadius.circular(AppSize.r20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: context.themeColors.coinAmberColor,
            size: 16,
          ),
          SizedBox(width: AppSize.w6),
          Text(
            context.l10n.lvDotLevel(level.toInt(), levelName),
            style: context.textTheme.titleMedium?.copyWith(
              color: context.themeColors.coinAmberColor,
              fontSize: AppSize.sp12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Level progress card
// ─────────────────────────────────────────────────────────────────────────────

class _LevelProgressCard extends StatelessWidget {
  const _LevelProgressCard({
    required this.progress,
    required this.nextLevel,
    required this.colors,
    required this.textColors,
  });

  final double progress;
  final String nextLevel;
  final ThemeColors colors;
  final ThemeTextColors textColors;

  @override
  Widget build(BuildContext context) {
    final pct = (progress.clamp(0.0, 1.0) * 100).toInt();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.h16),
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r20),
        boxShadow: [
          BoxShadow(
            color: context.themeColors.cardShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.levelProgress,
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: AppSize.sp15,
                  fontWeight: FontWeight.w700,
                  color: textColors.textBlackColor,
                ),
              ),
              Text(
                '$pct%',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.primary,
                  fontSize: AppSize.sp15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSize.r4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: AppSize.h8,
              backgroundColor: context.themeColors.borderColor2,
              valueColor: AlwaysStoppedAnimation<Color>(colors.buttonColor),
            ),
          ),
          SizedBox(height: AppSize.h10),
          // Next level label
          Row(
            children: [
              Text(
                context.l10n.nextLevel,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: textColors.textBlackColor,
                  fontSize: AppSize.sp13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                nextLevel,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.buttonColor,
                  fontSize: AppSize.sp13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings tile — unified, fixed-height row
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.textColors,
    this.onTap,
    this.isLast = false,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final Widget trailing;
  final ThemeTextColors textColors;
  final VoidCallback? onTap;
  final bool isLast;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            )
          : BorderRadius.zero,
      child: SizedBox(
        height: AppSize.h44,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? context.themeTextColors.bodyTextColor, size: AppSize.sp22),
              SizedBox(width: AppSize.w14),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: labelColor ?? textColors.textBlackColor,
                    fontSize: AppSize.sp16,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Delete account confirmation dialog
// ─────────────────────────────────────────────────────────────────────────────

class _DeleteAccountDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;

    return AlertDialog(
      backgroundColor: colors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.r28),
      ),
      titlePadding: EdgeInsets.fromLTRB(
        AppSize.w24,
        AppSize.h28,
        AppSize.w24,
        0,
      ),
      contentPadding: EdgeInsets.fromLTRB(
        AppSize.w24,
        AppSize.h12,
        AppSize.w24,
        0,
      ),
      actionsPadding: EdgeInsets.fromLTRB(
        AppSize.w16,
        AppSize.h16,
        AppSize.w16,
        AppSize.h20,
      ),
      title: Column(
        children: [
          Container(
            width: AppSize.w60,
            height: AppSize.w60,
            decoration: BoxDecoration(
              color: colors.buttonColor2.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.delete_forever_rounded,
              color: colors.buttonColor2,
              size: AppSize.sp32,
            ),
          ),
          SizedBox(height: AppSize.h14),
          Text(
            context.l10n.deleteAccountTitle,
            style: context.textTheme.titleLarge?.copyWith(
              color: colors.buttonColor2,
              fontWeight: FontWeight.w700,
              fontSize: AppSize.sp18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Text(
        context.l10n.deleteAccountDesc,
        textAlign: TextAlign.center,
        style: context.textTheme.bodyMedium?.copyWith(
          color: textColors.hintTextColor,
          height: 1.4,
          fontSize: AppSize.sp14,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: context.l10n.cancel,
                buttonColor: context.themeColors.whiteColor,
                shadowColor: context.themeColors.borderColor,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            SizedBox(width: AppSize.w12),
            Expanded(
              child: AppButton(
                text: context.l10n.delete,
                buttonColor: context.themeColors.buttonColor2,
                shadowColor: context.themeColors.buttonBorderColor2,
                foregroundColor: context.themeColors.whiteColor,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
