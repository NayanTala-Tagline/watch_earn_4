import 'package:ad_manager/ad_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:watch_earn_4/db/app_db.dart';
import 'package:watch_earn_4/di/injector.dart';
import 'package:watch_earn_4/features/withdraw/model/withdraw_models.dart';
import 'package:watch_earn_4/gen/assets.gen.dart';
import 'package:watch_earn_4/utils/app_size.dart';
import 'package:watch_earn_4/utils/regex_helper.dart';
import 'package:watch_earn_4/utils/remote_config.dart';

class WithdrawProvider extends ChangeNotifier {
  static double get minWithdrawAmount =>
      RemoteConfigService.instance.minWithdrawAmount.toDouble();

  final _firestore = FirebaseFirestore.instance;
  final _db = Injector.instance<AppDB>();

  InlineAdManager? nativeAd;

  WithdrawProvider() {
    _loadAd();
  }

  Future<void> _loadAd() async {
    nativeAd = InlineAdManager(
      adData: RemoteConfigService.instance.withdrawNative,
    );
    await nativeAd!.load();
    notifyListeners();
  }

  List<WithdrawCategory> getWithdrawCategories(BuildContext context) {
    return [
      WithdrawCategory(
        title: 'Cash',
        dbTitle: 'Cash',
        items: [
          WithdrawItem(
            'PayPal',
            'PayPal',
            Assets.cashWithdrawIcons.icPaypal.svg(width: AppSize.w22),
            const Color(0xFF2559ca),
            FormData(
              'Enter PayPal email',
              Icon(Icons.payment, size: AppSize.w22, color: const Color(0xFF2559ca)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Wise',
            'Wise',
            Assets.cashWithdrawIcons.icWise.svg(width: AppSize.w22),
            const Color(0xFF00aeff),
            FormData(
              'Email or IBAN',
              Icon(Icons.account_balance_sharp, size: AppSize.w22, color: const Color(0xFF00aeff)),
              RegexHelper.email_or_iban,
            ),
          ),
          WithdrawItem(
            'Payoneer',
            'Payoneer',
            Assets.cashWithdrawIcons.icPayoneer.svg(width: AppSize.w22),
            const Color(0xFFff4000),
            FormData(
              'Payoneer email',
              Icon(Icons.email_sharp, size: AppSize.w22, color: const Color(0xFFff4000)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Skrill',
            'Skrill',
            Assets.cashWithdrawIcons.icSkrill.svg(width: AppSize.w22),
            const Color(0xFFb82986),
            FormData(
              'Skrill email',
              Icon(Icons.email_sharp, size: AppSize.w22, color: const Color(0xFFb82986)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Apple Pay',
            'Apple Pay',
            Assets.cashWithdrawIcons.icApplepay.svg(width: AppSize.w22),
            const Color(0xFF111111),
            FormData(
              'Apple ID',
              Icon(Icons.phone_android_sharp, size: AppSize.w22, color: const Color(0xFF111111)),
              RegexHelper.email_or_phone,
            ),
          ),
          WithdrawItem(
            'Google Wallet',
            'Google Wallet',
            Assets.cashWithdrawIcons.icGooglewallet.image(width: AppSize.w22),
            const Color(0xFF3a7af2),
            FormData(
              'Google Pay number',
              Icon(Icons.email_sharp, size: AppSize.w22, color: const Color(0xFF3a7af2)),
              RegexHelper.email_or_phone,
            ),
          ),
          WithdrawItem(
            'Samsung Wallet',
            'Samsung Wallet',
            Assets.cashWithdrawIcons.icSamsungwallet.svg(width: AppSize.w18),
            const Color(0xFF43a546),
            FormData(
              'Samsung Pay ID',
              Icon(Icons.email_sharp, size: AppSize.w22, color: const Color(0xFF43a546)),
              RegexHelper.alphanumeric,
            ),
          ),
          WithdrawItem(
            'Wells Fargo',
            'Wells Fargo',
            Assets.cashWithdrawIcons.icWellsfargo.svg(width: AppSize.w22),
            const Color(0xFFf68819),
            FormData(
              'Account number',
              Icon(Icons.account_balance_sharp, size: AppSize.w22, color: const Color(0xFFf68819)),
              RegexHelper.iban_or_account,
            ),
          ),
          WithdrawItem(
            'Alipay',
            'Alipay',
            Assets.cashWithdrawIcons.icAlipay.svg(width: AppSize.w22),
            const Color(0xFF166bff),
            FormData(
              'Alipay ID',
              Icon(Icons.qr_code, size: AppSize.w22, color: const Color(0xFF166bff)),
              RegexHelper.wallet_id,
            ),
          ),
          WithdrawItem(
            'WeChat Pay',
            'WeChat Pay',
            Icon(Icons.wechat, size: AppSize.w22, color: const Color(0xFF009e5f)),
            const Color(0xFF009e5f),
            FormData(
              'WeChat ID',
              Icon(Icons.message, size: AppSize.w22, color: const Color(0xFF009e5f)),
              RegexHelper.wallet_id,
            ),
          ),
          WithdrawItem(
            'UPI',
            'UPI',
            Icon(Icons.qr_code_2, size: AppSize.w22, color: const Color(0xFFFF7900)),
            const Color(0xFFFF7900),
            FormData(
              'UPI ID',
              Icon(Icons.alternate_email, size: AppSize.w22, color: const Color(0xFFFF7900)),
              RegexHelper.upi,
            ),
          ),
          WithdrawItem(
            'PhonePe',
            'PhonePe',
            Icon(Icons.local_parking_outlined, size: AppSize.w22, color: const Color(0xFF6F2C91)),
            const Color(0xFF6F2C91),
            FormData(
              'PhonePe number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF6F2C91)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'Paytm',
            'Paytm',
            Icon(Icons.credit_card, size: AppSize.w22, color: const Color(0xFF00AEEF)),
            const Color(0xFF00AEEF),
            FormData(
              'Paytm number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF00AEEF)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'GCash',
            'GCash',
            Icon(Icons.wallet, size: AppSize.w22, color: const Color(0xFF0066FF)),
            const Color(0xFF0066FF),
            FormData(
              'GCash number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF0066FF)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'GrabPay',
            'GrabPay',
            Icon(Icons.local_taxi_rounded, size: AppSize.w22, color: const Color(0xFF00A651)),
            const Color(0xFF00A651),
            FormData(
              'Grab registered number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF00A651)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'KakaoPay',
            'KakaoPay',
            Icon(Icons.chat_bubble, size: AppSize.w22, color: const Color(0xFFFFCC00)),
            const Color(0xFFFFCC00),
            FormData(
              'Kakao ID',
              Icon(Icons.chat_bubble, size: AppSize.w22, color: const Color(0xFFFFCC00)),
              RegexHelper.wallet_id,
            ),
          ),
          WithdrawItem(
            'PayPay',
            'PayPay',
            Icon(Icons.local_parking_outlined, size: AppSize.w22, color: const Color(0xFFE30613)),
            const Color(0xFFE30613),
            FormData(
              'PayPay ID',
              Icon(Icons.qr_code, size: AppSize.w22, color: const Color(0xFFE30613)),
              RegexHelper.wallet_id,
            ),
          ),
          WithdrawItem(
            'Easypaisa',
            'Easypaisa',
            Icon(Icons.account_balance_wallet_rounded, size: AppSize.w22, color: const Color(0xFF00B14F)),
            const Color(0xFF00B14F),
            FormData(
              'Easypaisa number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF00B14F)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'SadaPay',
            'SadaPay',
            Icon(Icons.credit_card, size: AppSize.w22, color: const Color(0xFF1B2838)),
            const Color(0xFF1B2838),
            FormData(
              'SadaPay account',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF1B2838)),
              RegexHelper.phone_or_id,
            ),
          ),
          WithdrawItem(
            'bKash',
            'bKash',
            Icon(Icons.money_outlined, size: AppSize.w22, color: const Color(0xFFf54293)),
            const Color(0xFFf54293),
            FormData(
              'bKash number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFFf54293)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'CallFin',
            'CallFin',
            Icon(Icons.phone_android, size: AppSize.w22, color: const Color(0xFF00A86B)),
            const Color(0xFF00A86B),
            FormData(
              'CallFin number',
              Icon(Icons.email_sharp, size: AppSize.w22, color: const Color(0xFF00A86B)),
              RegexHelper.phone_or_id,
            ),
          ),
          WithdrawItem(
            'Revolut',
            'Revolut',
            Assets.cashWithdrawIcons.icRevolut.image(width: AppSize.w22),
            const Color(0xFF0066FF),
            FormData(
              '@revtag or IBAN',
              Icon(Icons.tag, size: AppSize.w22, color: const Color(0xFF0066FF)),
              RegexHelper.email_or_iban,
            ),
          ),
          WithdrawItem(
            'Monzo',
            'Monzo',
            Assets.cashWithdrawIcons.icMonzo.image(width: AppSize.w22),
            const Color(0xFF1A2E5A),
            FormData(
              'Account + sort code',
              Icon(Icons.account_balance_sharp, size: AppSize.w22, color: const Color(0xFF1A2E5A)),
              RegexHelper.sort_code_account,
            ),
          ),
          WithdrawItem(
            'N26',
            'N26',
            Assets.cashWithdrawIcons.icN26.image(width: AppSize.w22),
            const Color(0xFF00C1B2),
            FormData(
              'IBAN',
              Icon(Icons.account_balance_sharp, size: AppSize.w22, color: const Color(0xFF00C1B2)),
              RegexHelper.iban,
            ),
          ),
          WithdrawItem(
            'Bunq',
            'Bunq',
            Icon(Icons.savings, size: AppSize.w22, color: const Color(0xFFeb7a8d)),
            const Color(0xFFeb7a8d),
            FormData(
              'IBAN or email',
              Icon(Icons.mail, size: AppSize.w22, color: const Color(0xFFeb7a8d)),
              RegexHelper.email_or_iban,
            ),
          ),
          WithdrawItem(
            'Starling Bank',
            'Starling Bank',
            Assets.cashWithdrawIcons.icStarlingbank.svg(width: AppSize.w22),
            const Color(0xFF00b9aa),
            FormData(
              'Account number',
              Icon(Icons.tag, size: AppSize.w22, color: const Color(0xFF00b9aa)),
              RegexHelper.sort_code_account,
            ),
          ),
          WithdrawItem(
            'iDEAL',
            'iDEAL',
            Assets.cashWithdrawIcons.icIdeal.svg(width: AppSize.w22),
            const Color(0xFFCC0066),
            FormData(
              'IBAN',
              Icon(Icons.account_balance_sharp, size: AppSize.w22, color: const Color(0xFFCC0066)),
              RegexHelper.iban,
            ),
          ),
          WithdrawItem(
            'Tikkie',
            'Tikkie',
            Assets.cashWithdrawIcons.icTikkie.svg(width: AppSize.w22),
            const Color(0xFFff5f00),
            FormData(
              'Tikkie link or number',
              Icon(Icons.link, size: AppSize.w22, color: const Color(0xFFff5f00)),
              RegexHelper.link,
            ),
          ),
          WithdrawItem(
            'Vipps',
            'Vipps',
            Assets.cashWithdrawIcons.icVipps.svg(width: AppSize.w22),
            const Color(0xFFff5020),
            FormData(
              'Vipps number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFFff5f00)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'MobilePay',
            'MobilePay',
            Assets.cashWithdrawIcons.icMobilepay.svg(width: AppSize.w22),
            const Color(0xFF00509b),
            FormData(
              'MobilePay number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF00509b)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'Swish',
            'Swish',
            Assets.cashWithdrawIcons.icSwish.svg(width: AppSize.w22),
            const Color(0xFF02ab81),
            FormData(
              'Swish number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF02ab81)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'BLIK',
            'BLIK',
            Assets.cashWithdrawIcons.icBlik.svg(width: AppSize.w22),
            const Color(0xFFfc342a),
            FormData(
              'BLIK code',
              Icon(Icons.tag, size: AppSize.w22, color: const Color(0xFFfc342a)),
              RegexHelper.code,
            ),
          ),
          WithdrawItem(
            'Lydia',
            'Lydia',
            Assets.cashWithdrawIcons.icLydia.svg(width: AppSize.w22),
            const Color(0xFF612670),
            FormData(
              'Lydia number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF612670)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'PayLib',
            'PayLib',
            Assets.cashWithdrawIcons.icPaylib.svg(width: AppSize.w22),
            const Color(0xFF3c4985),
            FormData(
              'PayLib number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF3c4985)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'Twint',
            'Twint',
            Assets.cashWithdrawIcons.icTwint.svg(width: AppSize.w22),
            const Color(0xFF652786),
            FormData(
              'Twint number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF652786)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'Satispay',
            'Satispay',
            Assets.cashWithdrawIcons.icSatispay.svg(width: AppSize.w22),
            const Color(0xFFff5035),
            FormData(
              'Satispay number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFFff5035)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'iyzico',
            'iyzico',
            Assets.cashWithdrawIcons.icIyzico.svg(width: AppSize.w22),
            const Color(0xFF2882ff),
            FormData(
              'Account ID',
              Icon(Icons.account_circle, size: AppSize.w22, color: const Color(0xFF2882ff)),
              RegexHelper.flexible_id,
            ),
          ),
          WithdrawItem(
            'M-Pesa',
            'M-Pesa',
            Assets.cashWithdrawIcons.icMpesa.svg(width: AppSize.w22),
            const Color(0xFF009c46),
            FormData(
              'M-Pesa number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF009c46)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'OPay',
            'OPay',
            Assets.cashWithdrawIcons.icOpay.svg(width: AppSize.w22),
            const Color(0xFF1DC45A),
            FormData(
              'OPay number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF1DC45A)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'Orange Money',
            'Orange Money',
            Assets.cashWithdrawIcons.icOrangemoney.svg(width: AppSize.w22),
            const Color(0xFFFF7900),
            FormData(
              'Orange Money number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFFFF7900)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'MTN Mobile',
            'MTN Mobile',
            Assets.cashWithdrawIcons.icMynmobile.svg(width: AppSize.w22),
            const Color(0xFFFFCC00),
            FormData(
              'MTN Mobile number',
              Icon(Icons.cell_tower, size: AppSize.w22, color: const Color(0xFFFFCC00)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'Chipper Cash',
            'Chipper Cash',
            Assets.cashWithdrawIcons.icChippercash.svg(width: AppSize.w22),
            const Color(0xFF0066FF),
            FormData(
              'Chipper tag',
              Icon(Icons.alternate_email, size: AppSize.w22, color: const Color(0xFF0066FF)),
              RegexHelper.wallet_id,
            ),
          ),
          WithdrawItem(
            'Moniepoint',
            'Moniepoint',
            Icon(Icons.dialpad, size: AppSize.w22, color: const Color(0xFFFFCC00)),
            const Color(0xFFFFCC00),
            FormData(
              'Account number',
              Icon(Icons.tag, size: AppSize.w22, color: const Color(0xFFFFCC00)),
              RegexHelper.numberOnly,
            ),
          ),
          WithdrawItem(
            'Baxi',
            'Baxi',
            Assets.cashWithdrawIcons.icBaxi.svg(width: AppSize.w22),
            const Color(0xFF007BFF),
            FormData(
              'Baxi account',
              Icon(Icons.tag, size: AppSize.w22, color: const Color(0xFF007BFF)),
              RegexHelper.numberOnly,
            ),
          ),
          WithdrawItem(
            'Capitec Pay',
            'Capitec Pay',
            Assets.cashWithdrawIcons.icCapitecpay.svg(width: AppSize.w22),
            const Color(0xFF00B14F),
            FormData(
              'ID or phone',
              Icon(Icons.account_circle_outlined, size: AppSize.w22, color: const Color(0xFF00B14F)),
              RegexHelper.phone_or_id,
            ),
          ),
          WithdrawItem(
            'SnapScan',
            'SnapScan',
            Assets.cashWithdrawIcons.icSnapscan.svg(width: AppSize.w22),
            const Color(0xFF0033A0),
            FormData(
              'SnapScan ID',
              Icon(Icons.qr_code, size: AppSize.w22, color: const Color(0xFF0033A0)),
              RegexHelper.wallet_id,
            ),
          ),
          WithdrawItem(
            'NatsWallet',
            'NatsWallet',
            Assets.cashWithdrawIcons.icNasswallet.svg(width: AppSize.w22),
            const Color(0xFFF5A623),
            FormData(
              'Card or account',
              Icon(Icons.compare_arrows_outlined, size: AppSize.w22, color: const Color(0xFFF5A623)),
              RegexHelper.iban_or_account,
            ),
          ),
          WithdrawItem(
            'Onafriq',
            'Onafriq',
            Assets.cashWithdrawIcons.icOnafriq.svg(width: AppSize.w22),
            const Color(0xFFE53935),
            FormData(
              'User ID',
              Icon(Icons.account_circle_outlined, size: AppSize.w22, color: const Color(0xFFE53935)),
              RegexHelper.flexible_id,
            ),
          ),
          WithdrawItem(
            'STC Pay',
            'STC Pay',
            Assets.cashWithdrawIcons.icStcpay.svg(width: AppSize.w22),
            const Color(0xFF6A1B9A),
            FormData(
              'STC Pay number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF6A1B9A)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'Vodafone Cash',
            'Vodafone Cash',
            Assets.cashWithdrawIcons.icVodafonecash.svg(width: AppSize.w22),
            const Color(0xFFE60000),
            FormData(
              'Vodafone number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFFE60000)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'Careem Pay',
            'Careem Pay',
            Assets.cashWithdrawIcons.icCareempay.svg(width: AppSize.w22),
            const Color(0xFF00C853),
            FormData(
              'Careem number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF00C853)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'InstaPay',
            'InstaPay',
            Assets.cashWithdrawIcons.icInstapay.svg(width: AppSize.w22),
            const Color(0xFF0070BA),
            FormData(
              'InstaPay address',
              Icon(Icons.alternate_email, size: AppSize.w22, color: const Color(0xFF0070BA)),
              RegexHelper.payment_id,
            ),
          ),
          WithdrawItem(
            'myfawry',
            'myfawry',
            Assets.cashWithdrawIcons.icMyfawry.svg(width: AppSize.w22),
            const Color(0xFFF9B233),
            FormData(
              'Fawry number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFFF9B233)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'BenefitPay',
            'BenefitPay',
            Assets.cashWithdrawIcons.icBenefitpay.svg(width: AppSize.w22),
            const Color(0xFF00A3E0),
            FormData(
              'BenefitPay number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF00A3E0)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'Meeza',
            'Meeza',
            Assets.cashWithdrawIcons.icMeeza.svg(width: AppSize.w22),
            const Color(0xFF009639),
            FormData(
              'Meeza card or wallet',
              Icon(Icons.credit_card, size: AppSize.w22, color: const Color(0xFF009639)),
              RegexHelper.iban_or_account,
            ),
          ),
          WithdrawItem(
            'valU',
            'valU',
            Assets.cashWithdrawIcons.icValu.svg(width: AppSize.w22),
            const Color(0xFF0088FF),
            FormData(
              'valU account',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF0088FF)),
              RegexHelper.phone_or_id,
            ),
          ),
          WithdrawItem(
            'Nubank',
            'Nubank',
            Assets.cashWithdrawIcons.icNubank.svg(width: AppSize.w22),
            const Color(0xFF8A05BE),
            FormData(
              'Pix or account',
              Icon(Icons.add_box_sharp, size: AppSize.w22, color: const Color(0xFF8A05BE)),
              RegexHelper.pix_key,
            ),
          ),
          WithdrawItem(
            'PicPay',
            'PicPay',
            Assets.cashWithdrawIcons.icPicpay.svg(width: AppSize.w22),
            const Color(0xFF21C25E),
            FormData(
              'PicPay username or Pix',
              Icon(Icons.alternate_email, size: AppSize.w22, color: const Color(0xFF21C25E)),
              RegexHelper.pix_key,
            ),
          ),
          WithdrawItem(
            'Mercado Pago',
            'Mercado Pago',
            Assets.cashWithdrawIcons.icMercadopago.svg(width: AppSize.w22),
            const Color(0xFF009EE3),
            FormData(
              'Email or CVU',
              Icon(Icons.mail, size: AppSize.w22, color: const Color(0xFF009EE3)),
              RegexHelper.email_or_iban,
            ),
          ),
          WithdrawItem(
            'Nequi',
            'Nequi',
            Assets.cashWithdrawIcons.icNequi.svg(width: AppSize.w22),
            const Color(0xFF6A00FF),
            FormData(
              'Nequi number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF6A00FF)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'Daviplata',
            'Daviplata',
            Assets.cashWithdrawIcons.icDaviplata.svg(width: AppSize.w22),
            const Color(0xFFE30613),
            FormData(
              'Daviplata number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFFE30613)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'Yape',
            'Yape',
            Assets.cashWithdrawIcons.icYape.svg(width: AppSize.w22),
            const Color(0xFF6A1B9A),
            FormData(
              'Yape number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF6A1B9A)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'Plin',
            'Plin',
            Assets.cashWithdrawIcons.icPlin.svg(width: AppSize.w22),
            const Color(0xFF00AEEF),
            FormData(
              'Plin number',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFF00AEEF)),
              RegexHelper.phone,
            ),
          ),
          WithdrawItem(
            'RappiPay',
            'RappiPay',
            Assets.cashWithdrawIcons.icRappipay.svg(width: AppSize.w22),
            const Color(0xFFFF441F),
            FormData(
              'Rappi account',
              Icon(Icons.call, size: AppSize.w22, color: const Color(0xFFFF441F)),
              RegexHelper.phone_or_id,
            ),
          ),
          WithdrawItem(
            'MACH',
            'MACH',
            Assets.cashWithdrawIcons.icMach.svg(width: AppSize.w22),
            const Color(0xFFFFD400),
            FormData(
              'MACH account',
              Icon(Icons.account_circle, size: AppSize.w22, color: const Color(0xFFFFD400)),
              RegexHelper.flexible_id,
            ),
          ),
          WithdrawItem(
            'Prex',
            'Prex',
            Assets.cashWithdrawIcons.icPrex.svg(width: AppSize.w22),
            const Color(0xFF00AEEF),
            FormData(
              'Prex account',
              Icon(Icons.tag, size: AppSize.w22, color: const Color(0xFF00AEEF)),
              RegexHelper.flexible_id,
            ),
          ),
          WithdrawItem(
            'PayID',
            'PayID',
            Assets.cashWithdrawIcons.icPayid.svg(width: AppSize.w22),
            const Color(0xFF6C2BD9),
            FormData(
              'PayID email or phone',
              Icon(Icons.abc, size: AppSize.w22, color: const Color(0xFF6C2BD9)),
              RegexHelper.email_or_phone,
            ),
          ),
          WithdrawItem(
            'CommBank',
            'CommBank',
            Assets.cashWithdrawIcons.icCommbank.svg(width: AppSize.w22),
            const Color(0xFFFFCC00),
            FormData(
              'BSB + account',
              Icon(Icons.tag, size: AppSize.w22, color: const Color(0xFFFFCC00)),
              RegexHelper.bsb_account,
            ),
          ),
          WithdrawItem(
            'Westpac',
            'Westpac',
            Assets.cashWithdrawIcons.icWestpac.svg(width: AppSize.w22),
            const Color(0xFFD50000),
            FormData(
              'BSB + account',
              Icon(Icons.tag, size: AppSize.w22, color: const Color(0xFFD50000)),
              RegexHelper.bsb_account,
            ),
          ),
          WithdrawItem(
            'ANZ',
            'ANZ',
            Assets.cashWithdrawIcons.icAnz.svg(width: AppSize.w22),
            const Color(0xFF0072CE),
            FormData(
              'BSB + account',
              Icon(Icons.tag, size: AppSize.w22, color: const Color(0xFF0072CE)),
              RegexHelper.bsb_account,
            ),
          ),
          WithdrawItem(
            'NAB',
            'NAB',
            Assets.cashWithdrawIcons.icNab.svg(width: AppSize.w22),
            const Color(0xFFC8102E),
            FormData(
              'BSB + account',
              Icon(Icons.tag, size: AppSize.w22, color: const Color(0xFFC8102E)),
              RegexHelper.bsb_account,
            ),
          ),
          WithdrawItem(
            'Up',
            'Up',
            Assets.cashWithdrawIcons.icUp.svg(width: AppSize.w22),
            const Color(0xFFFF6F00),
            FormData(
              'Username or PayID',
              Icon(Icons.alternate_email, size: AppSize.w22, color: const Color(0xFFFF6F00)),
              RegexHelper.email_or_phone,
            ),
          ),
          WithdrawItem(
            'Afterpay',
            'Afterpay',
            Assets.cashWithdrawIcons.icAfterpay.svg(width: AppSize.w22),
            const Color(0xFF00D084),
            FormData(
              'Account email',
              Icon(Icons.mail, size: AppSize.w22, color: const Color(0xFF00D084)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Zip',
            'Zip',
            Assets.cashWithdrawIcons.icZip.svg(width: AppSize.w22),
            const Color(0xFF00C853),
            FormData(
              'Zip ID',
              Icon(Icons.account_circle, size: AppSize.w22, color: const Color(0xFF00C853)),
              RegexHelper.flexible_id,
            ),
          ),
          WithdrawItem(
            'Kiwibank',
            'Kiwibank',
            Assets.cashWithdrawIcons.icKiwibank.svg(width: AppSize.w22),
            const Color(0xFF78BE20),
            FormData(
              'Account number',
              Icon(Icons.tag, size: AppSize.w22, color: const Color(0xFF78BE20)),
              RegexHelper.numberOnly,
            ),
          ),
          WithdrawItem(
            'Scotiabank',
            'Scotiabank',
            Assets.cashWithdrawIcons.icScotiabank.svg(width: AppSize.w22),
            const Color(0xFFE31837),
            FormData(
              'Base ID or account',
              Icon(Icons.account_circle, size: AppSize.w22, color: const Color(0xFFE31837)),
              RegexHelper.flexible_id,
            ),
          ),
        ],
      ),

      WithdrawCategory(
        title: 'Crypto',
        dbTitle: 'Crypto',
        items: [
          WithdrawItem(
            'Bitcoin',
            'Bitcoin',
            Assets.cryptoWithdrawIcons.icBitcoin.svg(width: AppSize.w22),
            const Color(0xFFF7931A),
            FormData(
              'BTC wallet address',
              Icon(Icons.wallet_sharp, size: AppSize.w22, color: const Color(0xFFF7931A)),
              RegexHelper.crypto,
            ),
          ),
          WithdrawItem(
            'Ethereum',
            'Ethereum',
            Assets.cryptoWithdrawIcons.icEthereum.svg(width: AppSize.w22),
            const Color(0xFF627EEA),
            FormData(
              'ETH wallet address',
              Icon(Icons.wallet_sharp, size: AppSize.w22, color: const Color(0xFF627EEA)),
              RegexHelper.crypto,
            ),
          ),
          WithdrawItem(
            'USDT',
            'USDT',
            Assets.cryptoWithdrawIcons.icUsdt.svg(width: AppSize.w22),
            const Color(0xFF26A17B),
            FormData(
              'USDT network address',
              Icon(Icons.wallet_sharp, size: AppSize.w22, color: const Color(0xFF26A17B)),
              RegexHelper.crypto,
            ),
          ),
          WithdrawItem(
            'USDC',
            'USDC',
            Assets.cryptoWithdrawIcons.icUsdc.svg(width: AppSize.w22),
            const Color(0xFF2775CA),
            FormData(
              'USDC network address',
              Icon(Icons.wallet_sharp, size: AppSize.w22, color: const Color(0xFF2775CA)),
              RegexHelper.crypto,
            ),
          ),
          WithdrawItem(
            'Binance Pay',
            'Binance Pay',
            Assets.cryptoWithdrawIcons.icBinancepay.svg(width: AppSize.w22),
            const Color(0xFFF3BA2F),
            FormData(
              'Binance ID or email',
              Icon(Icons.person_outline, size: AppSize.w22, color: const Color(0xFFF3BA2F)),
              RegexHelper.email_or_phone,
            ),
          ),
          WithdrawItem(
            'BNB',
            'BNB',
            Assets.cryptoWithdrawIcons.icBnb.svg(width: AppSize.w22),
            const Color(0xFFF3BA2F),
            FormData(
              'BEP20 address',
              Icon(Icons.wallet_sharp, size: AppSize.w22, color: const Color(0xFFF3BA2F)),
              RegexHelper.crypto,
            ),
          ),
          WithdrawItem(
            'Litecoin',
            'Litecoin',
            Assets.cryptoWithdrawIcons.icLitecoin.svg(width: AppSize.w22),
            const Color(0xFF345D9D),
            FormData(
              'LTC wallet address',
              Icon(Icons.wallet_sharp, size: AppSize.w22, color: const Color(0xFF345D9D)),
              RegexHelper.crypto,
            ),
          ),
          WithdrawItem(
            'Tron (TRX)',
            'Tron (TRX)',
            Assets.cryptoWithdrawIcons.icTron.svg(width: AppSize.w22),
            const Color(0xFFFF060A),
            FormData(
              'TRX address',
              Icon(Icons.wallet_sharp, size: AppSize.w22, color: const Color(0xFFFF060A)),
              RegexHelper.crypto,
            ),
          ),
          WithdrawItem(
            'Dogecoin',
            'Dogecoin',
            Assets.cryptoWithdrawIcons.icDogecoin.svg(width: AppSize.w22),
            const Color(0xFFC2A633),
            FormData(
              'DOGE address',
              Icon(Icons.wallet_sharp, size: AppSize.w22, color: const Color(0xFFC2A633)),
              RegexHelper.crypto,
            ),
          ),
          WithdrawItem(
            'Shiba Inu',
            'Shiba Inu',
            Assets.cryptoWithdrawIcons.icShibainu.svg(width: AppSize.w22),
            const Color(0xFFF28C28),
            FormData(
              'SHIB address',
              Icon(Icons.wallet_sharp, size: AppSize.w22, color: const Color(0xFFF28C28)),
              RegexHelper.crypto,
            ),
          ),
          WithdrawItem(
            'Solana',
            'Solana',
            Assets.cryptoWithdrawIcons.icSolana.svg(width: AppSize.w22),
            const Color(0xFF9945FF),
            FormData(
              'SOL address',
              Icon(Icons.wallet_sharp, size: AppSize.w22, color: const Color(0xFF9945FF)),
              RegexHelper.crypto,
            ),
          ),
          WithdrawItem(
            'Ripple (XRP)',
            'Ripple (XRP)',
            Assets.cryptoWithdrawIcons.icRipple.svg(width: AppSize.w22),
            const Color(0xFF23292F),
            FormData(
              'XRP address + tag',
              Icon(Icons.wallet_sharp, size: AppSize.w22, color: const Color(0xFF23292F)),
              RegexHelper.crypto_with_tag,
            ),
          ),
          WithdrawItem(
            'Polygon (MATIC)',
            'Polygon (MATIC)',
            Assets.cryptoWithdrawIcons.icPolygon.svg(width: AppSize.w22),
            const Color(0xFF8247E5),
            FormData(
              'Polygon address',
              Icon(Icons.wallet_sharp, size: AppSize.w22, color: const Color(0xFF8247E5)),
              RegexHelper.crypto,
            ),
          ),
          WithdrawItem(
            'Dash',
            'Dash',
            Assets.cryptoWithdrawIcons.icDash.svg(width: AppSize.w22),
            const Color(0xFF008CE7),
            FormData(
              'DASH address',
              Icon(Icons.wallet_sharp, size: AppSize.w22, color: const Color(0xFF008CE7)),
              RegexHelper.crypto,
            ),
          ),
          WithdrawItem(
            'Bitcoin Cash',
            'Bitcoin Cash',
            Assets.cryptoWithdrawIcons.icBitcoincash.svg(width: AppSize.w22),
            const Color(0xFF8DC351),
            FormData(
              'BCH address',
              Icon(Icons.wallet_sharp, size: AppSize.w22, color: const Color(0xFF8DC351)),
              RegexHelper.crypto,
            ),
          ),
          WithdrawItem(
            'Perfect Money',
            'Perfect Money',
            Icon(Icons.local_parking, size: AppSize.w22, color: const Color(0xFF900600)),
            const Color(0xFF900600),
            FormData(
              'Perfect Money account',
              Icon(Icons.account_balance_wallet_rounded, size: AppSize.w22, color: const Color(0xFF900600)),
              RegexHelper.flexible_id,
            ),
          ),
        ],
      ),

      WithdrawCategory(
        title: 'Gift Cards',
        dbTitle: 'Gift Cards',
        items: [
          WithdrawItem(
            'Google Play',
            'Google Play',
            Icon(Icons.play_arrow, size: AppSize.w22, color: const Color(0xFF34A853)),
            const Color(0xFF34A853),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF34A853)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Apple Gift Card',
            'Apple Gift Card',
            Icon(Icons.apple, size: AppSize.w22, color: const Color(0xFF111111)),
            const Color(0xFF111111),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF111111)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Steam Wallet',
            'Steam Wallet',
            Assets.giftWithdrawIcons.icSteamwallet.svg(width: AppSize.w22),
            const Color(0xFF34A853),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF34A853)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'PlayStation',
            'PlayStation',
            Assets.giftWithdrawIcons.icPlaystation.svg(width: AppSize.w22),
            const Color(0xFF003791),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF003791)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Xbox Live',
            'Xbox Live',
            Assets.giftWithdrawIcons.icXboxlive.svg(width: AppSize.w22),
            const Color(0xFF1B2838),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF1B2838)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Nintendo eShop',
            'Nintendo eShop',
            Assets.giftWithdrawIcons.icNintendoEshop.svg(width: AppSize.w22),
            const Color(0xFF00D1B2),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF00D1B2)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Razer Gold',
            'Razer Gold',
            Assets.giftWithdrawIcons.icRazergold.svg(width: AppSize.w22),
            const Color(0xFF44D62C),
            FormData(
              'Razer ID or email',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF44D62C)),
              RegexHelper.email_or_phone,
            ),
          ),
          WithdrawItem(
            'Amazon',
            'Amazon',
            Assets.giftWithdrawIcons.icAmazon.svg(width: AppSize.w22),
            const Color(0xFFFF9900),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFFFF9900)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'eBay',
            'eBay',
            Assets.giftWithdrawIcons.icEbay.svg(width: AppSize.w22),
            const Color(0xFFE53238),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFFE53238)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Walmart',
            'Walmart',
            Assets.giftWithdrawIcons.icWalmart.svg(width: AppSize.w22),
            const Color(0xFF0071CE),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF0071CE)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Target',
            'Target',
            Assets.giftWithdrawIcons.icTarget.svg(width: AppSize.w22),
            const Color(0xFFCC0000),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFFCC0000)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Shien',
            'Shien',
            Assets.giftWithdrawIcons.icShien.svg(width: AppSize.w22),
            const Color(0xFF111111),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF111111)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Sephora',
            'Sephora',
            Assets.giftWithdrawIcons.icSephora.svg(width: AppSize.w22),
            const Color(0xFF111111),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF111111)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Nike',
            'Nike',
            Assets.giftWithdrawIcons.icNike.svg(width: AppSize.w22),
            const Color(0xFF111111),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF111111)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Netflix',
            'Netflix',
            Assets.giftWithdrawIcons.icNetflix.svg(width: AppSize.w22),
            const Color(0xFFE50914),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFFE50914)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Spotify',
            'Spotify',
            Assets.giftWithdrawIcons.icSpotify.svg(width: AppSize.w22),
            const Color(0xFF1DB954),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF1DB954)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Disney+',
            'Disney+',
            Assets.giftWithdrawIcons.icDisney.svg(width: AppSize.w22),
            const Color(0xFF113CCF),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF113CCF)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Twitch',
            'Twitch',
            Assets.giftWithdrawIcons.icTwitch.svg(width: AppSize.w22),
            const Color(0xFF9146FF),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF9146FF)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Starbucks',
            'Starbucks',
            Assets.giftWithdrawIcons.icStarbucks.svg(width: AppSize.w22),
            const Color(0xFF00704A),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF00704A)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Uber / Eats',
            'Uber / Eats',
            Assets.giftWithdrawIcons.icUbereats.svg(width: AppSize.w22),
            const Color(0xFF111111),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF111111)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'DoorDash',
            'DoorDash',
            Assets.giftWithdrawIcons.icDoordash.svg(width: AppSize.w22),
            const Color(0xFFFF3008),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFFFF3008)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Visa Prepaid',
            'Visa Prepaid',
            Assets.giftWithdrawIcons.icVisaprepaid.svg(width: AppSize.w22),
            const Color(0xFF1A1F71),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFF1A1F71)),
              RegexHelper.email,
            ),
          ),
          WithdrawItem(
            'Mastercard',
            'Mastercard',
            Assets.giftWithdrawIcons.icMastercard.svg(width: AppSize.w22),
            const Color(0xFFF79E1B),
            FormData(
              'Email to send code',
              Icon(Icons.email, size: AppSize.w22, color: const Color(0xFFF79E1B)),
              RegexHelper.email,
            ),
          ),
        ],
      ),

      WithdrawCategory(
        title: 'Game Credits',
        dbTitle: 'Game Credits',
        items: [
          WithdrawItem(
            'Free Fire',
            'Free Fire',
            Assets.gameWithdrawIcons.icFreefire.svg(width: AppSize.w22),
            const Color(0xFFF5A623),
            FormData(
              'Player ID / UID',
              Icon(Icons.videogame_asset_rounded, size: AppSize.w22, color: const Color(0xFFF79E1B)),
              RegexHelper.uid,
            ),
          ),
          WithdrawItem(
            'PUBG Mobile',
            'PUBG Mobile',
            Assets.gameWithdrawIcons.icPubgmobile.svg(width: AppSize.w22),
            const Color(0xFFF2A900),
            FormData(
              'Character ID',
              Icon(Icons.videogame_asset_rounded, size: AppSize.w22, color: const Color(0xFFF79E1B)),
              RegexHelper.uid,
            ),
          ),
          WithdrawItem(
            'CoD Mobile',
            'CoD Mobile',
            Assets.gameWithdrawIcons.icCodmobile.svg(width: AppSize.w22),
            const Color(0xFFC4C4C4),
            FormData(
              'Player ID / UID',
              Icon(Icons.videogame_asset_rounded, size: AppSize.w22, color: const Color(0xFFC4C4C4)),
              RegexHelper.uid,
            ),
          ),
          WithdrawItem(
            'Fortnite',
            'Fortnite',
            Assets.gameWithdrawIcons.icFortnite.svg(width: AppSize.w22),
            const Color(0xFF9146FF),
            FormData(
              'Epic Games username',
              Icon(Icons.person, size: AppSize.w22, color: const Color(0xFF9146FF)),
              RegexHelper.ea_id,
            ),
          ),
          WithdrawItem(
            'Apex Legends',
            'Apex Legends',
            Assets.gameWithdrawIcons.icApexLegends.svg(width: AppSize.w22),
            const Color(0xFFFF2D2D),
            FormData(
              'EA ID / username',
              Icon(Icons.person, size: AppSize.w22, color: const Color(0xFFFF2D2D)),
              RegexHelper.ea_id,
            ),
          ),
          WithdrawItem(
            'Mobile Legends',
            'Mobile Legends',
            Assets.gameWithdrawIcons.icMobilelegends.svg(width: AppSize.w22),
            const Color(0xFF00BFFF),
            FormData(
              'User ID / Zone ID',
              Icon(Icons.videogame_asset_rounded, size: AppSize.w22, color: const Color(0xFF00BFFF)),
              RegexHelper.uid_zone,
            ),
          ),
          WithdrawItem(
            'League of Legends',
            'League of Legends',
            Assets.gameWithdrawIcons.icLeagueoflegends.svg(width: AppSize.w22),
            const Color(0xFFC89B3C),
            FormData(
              'Riot ID + tag',
              Icon(Icons.videogame_asset_rounded, size: AppSize.w22, color: const Color(0xFFC89B3C)),
              RegexHelper.riot_id,
            ),
          ),
          WithdrawItem(
            'Brawl Stars',
            'Brawl Stars',
            Assets.gameWithdrawIcons.icBrawlstars.svg(width: AppSize.w22),
            const Color(0xFFFFD700),
            FormData(
              'Player tag',
              Icon(Icons.tag, size: AppSize.w22, color: const Color(0xFFFFD700)),
              RegexHelper.game_tag,
            ),
          ),
          WithdrawItem(
            'Valorant',
            'Valorant',
            Assets.gameWithdrawIcons.icValorant.svg(width: AppSize.w22),
            const Color(0xFFFF4655),
            FormData(
              'Riot ID + tag',
              Icon(Icons.person, size: AppSize.w22, color: const Color(0xFFFF4655)),
              RegexHelper.riot_id,
            ),
          ),
          WithdrawItem(
            'Genshin Impact',
            'Genshin Impact',
            Assets.gameWithdrawIcons.icGenshinimpact.svg(width: AppSize.w22),
            const Color(0xFFF28C28),
            FormData(
              'User ID + server',
              Icon(Icons.videogame_asset_rounded, size: AppSize.w22, color: const Color(0xFFF28C28)),
              RegexHelper.uid_zone,
            ),
          ),
          WithdrawItem(
            'Robux',
            'Robux',
            Assets.gameWithdrawIcons.icRobux.svg(width: AppSize.w22),
            const Color(0xFF00A2FF),
            FormData(
              'Roblox username',
              Icon(Icons.person, size: AppSize.w22, color: const Color(0xFF00A2FF)),
              RegexHelper.ea_id,
            ),
          ),
          WithdrawItem(
            'Minecraft',
            'Minecraft',
            Assets.gameWithdrawIcons.icMinecraft.svg(width: AppSize.w22),
            const Color(0xFF5C8A3E),
            FormData(
              'Xbox gamertag or email',
              Icon(Icons.mail, size: AppSize.w22, color: const Color(0xFF5C8A3E)),
              RegexHelper.email_or_phone,
            ),
          ),
          WithdrawItem(
            'Clash of Clans',
            'Clash of Clans',
            Assets.gameWithdrawIcons.icClashofclans.svg(width: AppSize.w22),
            const Color(0xFFD4AF37),
            FormData(
              'Player tag',
              Icon(Icons.tag, size: AppSize.w22, color: const Color(0xFFFFD700)),
              RegexHelper.game_tag,
            ),
          ),
          WithdrawItem(
            'EA FC',
            'EA FC',
            Assets.gameWithdrawIcons.icEafc.svg(width: AppSize.w22),
            const Color(0xFF444444),
            FormData(
              'EA ID / PSN / Xbox',
              Icon(Icons.videogame_asset_rounded, size: AppSize.w22, color: const Color(0xFF444444)),
              RegexHelper.ea_id,
            ),
          ),
        ],
      ),
    ];
  }

  int selectedIndex = 0;

  String? _withdrawType = 'Cash';
  String? _withdrawSubType;

  String? get withdrawType => _withdrawType;
  String? get withdrawSubType => _withdrawSubType;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final PageController pageController = PageController();

  void setWithdrawType(String value) {
    _withdrawType = value;
    notifyListeners();
  }

  void setWithdrawSubType(String value) {
    _withdrawSubType = value;
    notifyListeners();
  }

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  final TextEditingController btcWalletAddressController =
      TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String convertedValue = '0.0000';

  void onAmountChanged(String value) {
    final amount = double.tryParse(value) ?? 0;
    final divider = RemoteConfigService.instance.coinToDollarDivider;
    convertedValue = (amount / divider).toStringAsFixed(4);
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    btcWalletAddressController.dispose();
    amountController.dispose();
    noteController.dispose();
    nativeAd?.dispose();
    super.dispose();
  }

  void resetWithdrawForm() {
    btcWalletAddressController.clear();
    amountController.clear();
    noteController.clear();
    _withdrawSubType = null;
    convertedValue = '0.0000';
    notifyListeners();
  }

  bool showWithdrawSheet = false;

  void toggleSheet(bool value) {
    showWithdrawSheet = value;
    notifyListeners();
  }

  Future<bool> createWithdraw() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _db.userModel;
      if (user == null) {
        _error = 'User not signed in';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final amount = double.tryParse(amountController.text.trim());

      if (withdrawSubType == null || withdrawSubType!.isEmpty) {
        _error = 'Please select withdraw sub type';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (withdrawType == null || withdrawType!.isEmpty) {
        _error = 'Please select withdraw type';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (btcWalletAddressController.text.trim().isEmpty) {
        _error = 'Please enter wallet address';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (amount == null) {
        _error = 'Please enter a valid amount';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (amount < minWithdrawAmount) {
        _isLoading = false;
        _error =
            'Minimum withdraw is ${minWithdrawAmount.toStringAsFixed(0)} coins';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Block new request while one is still pending.
      final pendingSnap = await _firestore
          .collection('withdraw')
          .where('user_id', isEqualTo: user.userId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();
      if (pendingSnap.docs.isNotEmpty) {
        _error = 'You already have a pending withdrawal. Wait for it to be processed.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final docRef = _firestore.collection('withdraw').doc();
      await docRef.set({
        'user_id': user.userId,
        'email': btcWalletAddressController.text.trim(),
        'withdraw_type': withdrawType,
        'withdraw_sub_type': withdrawSubType,
        'amount': amount,
        'note': noteController.text.trim(),
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'reason': '',
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Withdraw failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Stream<QuerySnapshot> getWithdrawStream() {
    final userId = _db.userModel!.userId;
    return _firestore
        .collection('withdraw')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  /// Emits `true` whenever the user has at least one pending withdrawal.
  Stream<bool> pendingWithdrawStream() {
    final userId = _db.userModel?.userId;
    if (userId == null) return Stream.value(false);
    return _firestore
        .collection('withdraw')
        .where('user_id', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty);
  }
}
