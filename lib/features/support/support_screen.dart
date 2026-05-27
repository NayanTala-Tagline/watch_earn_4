import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/app_db.dart';
import '../../di/injector.dart';
import '../../extension/ext_context.dart';
import '../../extension/ext_string_alert.dart';
import '../../gen/fonts.gen.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/logger.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common_appbar.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'support',
      screenClass: 'SupportScreen',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    AnalyticsManager.instance.logEvent(name: 'support_ticket_submit_attempt');
    setState(() => _submitting = true);

    final successMsg = context.l10n.ticketSubmittedSuccess;
    final failMsg = context.l10n.ticketSubmitFailed;

    try {
      final db = Injector.instance<AppDB>();
      final user = db.userModel;

      await FirebaseFirestore.instance.collection('support_tickets').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'user_id': user?.userId ?? 'unknown',
        'email': user?.email ?? '',
        'device_id': user?.deviceId ?? 'unknown',
        'status': 'open',
        'created_at': FieldValue.serverTimestamp(),
      });

      AnalyticsManager.instance.logEvent(name: 'support_ticket_submit_success');
      'support_ticket submitted'.logI;

      if (!mounted) return;
      successMsg.showSuccessAlert();
      context.pop();
    } catch (e) {
      AnalyticsManager.instance.logEvent(
        name: 'support_ticket_submit_failed',
        parameters: {'error': e.toString()},
      );
      'Failed to submit: $e'.logE;
      if (!mounted) return;
      failMsg.showErrorAlert();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: CommonAppBar(titleText: context.l10n.support),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSize.w20,
            AppSize.h20,
            AppSize.w20,
            AppSize.h32,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  context.l10n.howCanWeHelp,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontSize: AppSize.sp22,
                    fontWeight: FontWeight.w800,
                    color: textColors.darkTitleColor,
                  ),
                ),
                SizedBox(height: AppSize.h8),
                Text(
                  context.l10n.supportDesc,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: textColors.bodyTextColor,
                    height: 1.45,
                  ),
                ),

                SizedBox(height: AppSize.h28),

                // Title field
                _FieldLabel(context.l10n.titleLabel),
                SizedBox(height: AppSize.h8),
                _SupportField(
                  controller: _titleController,
                  hint: context.l10n.titleHint,
                  maxLines: 1,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return context.l10n.pleaseAddTitle;
                    if (value.length < 3) return context.l10n.titleTooShort;
                    return null;
                  },
                ),

                SizedBox(height: AppSize.h20),

                // Description field
                _FieldLabel(context.l10n.descriptionLabel),
                SizedBox(height: AppSize.h8),
                _SupportField(
                  controller: _descController,
                  hint: context.l10n.descriptionHint,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return context.l10n.pleaseAddDescription;
                    if (value.length < 10) return context.l10n.descriptionTooShort;
                    return null;
                  },
                ),

                SizedBox(height: AppSize.h32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: AppSize.h56,
                  child: AppButton(
                    text: _submitting ? context.l10n.submitting : context.l10n.submit,
                    isLoading: _submitting,
                    buttonColor: colors.buttonColor,
                    shadowColor: colors.buttonBorderColor,
                    foregroundColor: colors.whiteColor,
                    wallOffset: 4,
                    borderRadius: AppSize.r29,
                    textStyle: TextStyle(
                      fontFamily: FontFamily.kommonGrotesk,
                      fontSize: AppSize.sp16,
                      fontWeight: FontWeight.w800,
                      color: colors.whiteColor,
                    ),
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
      ),
    );
  }
}

// ── Field label ───────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: FontFamily.kommonGrotesk,
        fontSize: AppSize.sp14,
        fontWeight: FontWeight.w700,
        color: context.themeTextColors.darkTitleColor,
      ),
    );
  }
}

// ── Text form field ───────────────────────────────────────────────────────────
class _SupportField extends StatelessWidget {
  const _SupportField({
    required this.controller,
    required this.hint,
    required this.maxLines,
    required this.validator,
    required this.textInputAction,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final FormFieldValidator<String> validator;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: textInputAction,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cursorColor: colors.buttonColor,
      style: context.textTheme.bodyMedium?.copyWith(
        color: textColors.darkTitleColor,
        fontFamily: FontFamily.kommonGrotesk,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: context.textTheme.bodyMedium?.copyWith(
          color: textColors.bodyTextColor,
          fontFamily: FontFamily.kommonGrotesk,
        ),
        filled: true,
        fillColor: colors.fieldBgColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSize.w16,
          vertical: AppSize.h14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.r14),
          borderSide: BorderSide(color: colors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.r14),
          borderSide: BorderSide(color: colors.borderColor2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.r14),
          borderSide: BorderSide(color: colors.buttonColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.r14),
          borderSide: BorderSide(color: colors.redColor, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.r14),
          borderSide: BorderSide(color: colors.redColor, width: 1.6),
        ),
        errorStyle: TextStyle(
          fontFamily: FontFamily.kommonGrotesk,
          fontSize: AppSize.sp12,
          fontWeight: FontWeight.w600,
          color: colors.redColor,
        ),
      ),
    );
  }
}
