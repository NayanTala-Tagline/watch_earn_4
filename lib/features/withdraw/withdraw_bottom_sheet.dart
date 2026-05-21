import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:watch_earn_4/extension/ext_string_alert.dart';
import 'package:watch_earn_4/features/withdraw/model/withdraw_models.dart';
import 'package:watch_earn_4/features/withdraw/provider/withdraw_provider.dart';
import 'package:watch_earn_4/gen/fonts.gen.dart';
import 'package:watch_earn_4/utils/app_size.dart';

class WithdrawBottomSheet extends StatelessWidget {
  const WithdrawBottomSheet({super.key, required this.item});

  final WithdrawItem item;

  static const _pageBg = Color(0xFFEAEFFC);
  static const _titleColor = Color(0xFF0E0F66);
  static const _bodyColor = Color(0xFF8A8FA8);
  static const _cardBorder = Color(0xFFEDEFF5);
  static const _primaryBlue = Color(0xFF1A1AE8);
  static const _fieldBg = Color(0xFFF6F7FB);
  static const _errorColor = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Consumer<WithdrawProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            decoration: const BoxDecoration(
              color: _pageBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
              AppSize.w20,
              AppSize.h20,
              AppSize.w20,
              AppSize.h24,
            ),
            child: Form(
              key: provider.formKey,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: AppSize.w40,
                        height: AppSize.h4,
                        decoration: BoxDecoration(
                          color: _cardBorder,
                          borderRadius: BorderRadius.circular(AppSize.r4),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSize.h16),
                    Container(
                      width: AppSize.w60,
                      height: AppSize.w60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppSize.r16),
                      ),
                      child: item.icon,
                    ),
                    SizedBox(height: AppSize.h16),
                    Text(
                      'Withdraw to ${item.title}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FontFamily.kommonGrotesk,
                        fontSize: AppSize.sp20,
                        fontWeight: FontWeight.w900,
                        color: _titleColor,
                      ),
                    ),
                    SizedBox(height: AppSize.h20),
                    _buildField(
                      controller: provider.btcWalletAddressController,
                      label: item.formData.title,
                      prefixIcon: item.formData.icon,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Field required';
                        }
                        if (!RegExp(item.formData.regex).hasMatch(v)) {
                          return 'Invalid input';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSize.h14),
                    _buildField(
                      controller: provider.amountController,
                      label: 'Amount (Coins)',
                      prefixIcon: Icon(
                        Icons.monetization_on_sharp,
                        color: item.color,
                      ),
                      suffixText:
                          'Min ${WithdrawProvider.minWithdrawAmount.toStringAsFixed(0)}',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onChanged: provider.onAmountChanged,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Field required';
                        }
                        final amount = double.tryParse(v.trim());
                        if (amount == null) return 'Enter a valid amount';
                        if (amount < WithdrawProvider.minWithdrawAmount) {
                          return 'Minimum withdraw is ${WithdrawProvider.minWithdrawAmount.toStringAsFixed(0)} coins';
                        }
                        return null;
                      },
                    ),
                    if (provider.amountController.text.isNotEmpty) ...[
                      SizedBox(height: AppSize.h10),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: AppSize.h10,
                          horizontal: AppSize.w12,
                        ),
                        decoration: BoxDecoration(
                          color: _errorColor.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(AppSize.r10),
                          border: Border.all(
                            color: _errorColor.withValues(alpha: 0.4),
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          'Value \$${provider.convertedValue}',
                          style: TextStyle(
                            fontFamily: FontFamily.kommonGrotesk,
                            fontSize: AppSize.sp13,
                            fontWeight: FontWeight.w600,
                            color: _errorColor,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: AppSize.h14),
                    _buildField(
                      controller: provider.noteController,
                      label: 'Additional note (optional)',
                      prefixIcon: const Icon(Icons.note, color: _bodyColor),
                    ),
                    SizedBox(height: AppSize.h24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                if (!provider.formKey.currentState!
                                    .validate()) {
                                  return;
                                }
                                final success = await provider.createWithdraw();
                                if (success) {
                                  provider.resetWithdrawForm();
                                  'Withdraw request sent'.showSuccessAlert();
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                } else {
                                  (provider.error ?? 'Error')
                                      .showErrorAlert();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.color,
                          padding: EdgeInsets.symmetric(vertical: AppSize.h16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.r14),
                          ),
                          elevation: 0,
                        ),
                        child: provider.isLoading
                            ? SizedBox(
                                height: AppSize.h20,
                                width: AppSize.w20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _confirmTextColor(item.color),
                                ),
                              )
                            : Text(
                                'Confirm Withdrawal',
                                style: TextStyle(
                                  fontFamily: FontFamily.kommonGrotesk,
                                  fontSize: AppSize.sp16,
                                  fontWeight: FontWeight.w900,
                                  color: _confirmTextColor(item.color),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _confirmTextColor(Color bg) {
    // Use black text on near-white brand colors so it stays readable
    // (mirrors daily_cash's isWhite check).
    return bg.toARGB32() == 0xFFFFFFFF ? Colors.black : Colors.white;
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required Widget prefixIcon,
    String? suffixText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cursorColor: _primaryBlue,
      style: TextStyle(
        fontFamily: FontFamily.kommonGrotesk,
        fontSize: AppSize.sp15,
        fontWeight: FontWeight.w700,
        color: _titleColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: FontFamily.kommonGrotesk,
          fontSize: AppSize.sp14,
          fontWeight: FontWeight.w600,
          color: _bodyColor,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: FontFamily.kommonGrotesk,
          fontSize: AppSize.sp14,
          fontWeight: FontWeight.w800,
          color: _primaryBlue,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSize.w12),
          child: prefixIcon,
        ),
        prefixIconConstraints: BoxConstraints(minWidth: AppSize.w36),
        suffixText: suffixText,
        suffixStyle: TextStyle(
          fontFamily: FontFamily.kommonGrotesk,
          fontSize: AppSize.sp13,
          fontWeight: FontWeight.w700,
          color: _bodyColor,
        ),
        filled: true,
        fillColor: _fieldBg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.r14),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.r14),
          borderSide: const BorderSide(color: _primaryBlue, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.r14),
          borderSide: const BorderSide(color: _errorColor, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.r14),
          borderSide: const BorderSide(color: _errorColor, width: 1.6),
        ),
        errorStyle: TextStyle(
          fontFamily: FontFamily.kommonGrotesk,
          fontSize: AppSize.sp12,
          fontWeight: FontWeight.w700,
          color: _errorColor,
        ),
      ),
    );
  }
}
