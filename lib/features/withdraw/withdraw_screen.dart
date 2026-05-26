import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_earn_4/db/app_db.dart';
import 'package:watch_earn_4/di/injector.dart';
import 'package:watch_earn_4/extension/ext_context.dart';
import 'package:watch_earn_4/features/withdraw/model/withdraw_models.dart';
import 'package:watch_earn_4/features/withdraw/provider/withdraw_provider.dart';
import 'package:watch_earn_4/features/withdraw/withdraw_bottom_sheet.dart';
import 'package:watch_earn_4/gen/assets.gen.dart';
import 'package:watch_earn_4/gen/fonts.gen.dart';
import 'package:watch_earn_4/utils/anaytics_manager.dart';
import 'package:watch_earn_4/utils/app_size.dart';
import 'package:watch_earn_4/utils/navigation_helper.dart';
import 'package:watch_earn_4/utils/remote_config.dart';
import 'package:watch_earn_4/widgets/ad_slot.dart';
import 'package:watch_earn_4/widgets/app_button.dart';
import 'package:watch_earn_4/widgets/balance_card.dart';
import 'package:watch_earn_4/widgets/common_header.dart';

// feature-specific colours not covered by the mapping
const _coinPillText = Color(0xFF7A4A00);

class WithdrawScreen extends StatelessWidget {
  const WithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WithdrawProvider(),
      child: const _WithdrawView(),
    );
  }
}

class _WithdrawView extends StatefulWidget {
  const _WithdrawView();

  @override
  State<_WithdrawView> createState() => _WithdrawViewState();
}

class _WithdrawViewState extends State<_WithdrawView> {
  static const _initialItemCount = 9;

  final Map<int, bool> _expanded = {};
  double _amount = 10;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'withdraw',
      screenClass: 'WithdrawScreen',
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WithdrawProvider>();
    final categories = provider.getWithdrawCategories(context);
    final categoryIndex = provider.selectedIndex;
    final currentCategory = categories[categoryIndex];

    final isExpanded = _expanded[categoryIndex] ?? false;
    final canExpand = currentCategory.items.length > _initialItemCount;
    final visibleItems = isExpanded
        ? currentCategory.items
        : currentCategory.items.take(_initialItemCount).toList();

    final selectedItem = currentCategory.items.firstWhere(
      (item) => item.dbTitle == provider.withdrawSubType,
      orElse: () => currentCategory.items.first,
    );
    final selectedMethodIndex = currentCategory.items.indexOf(selectedItem);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
      backgroundColor: context.themeColors.backgroundColor,
      body: Column(
        children: [
          CommonHeader(
            title: 'Withdraw',
            backgroundColor: context.themeColors.backgroundColor,
            trailingIcon: Icon(
              Icons.refresh_rounded,
              size: AppSize.sp20,
              color: context.themeColors.buttonBorderColor,
            ),
            onTrailingTap: () {},
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: AppSize.h8,
                bottom: AppSize.h20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _hPad(const _LiveBalanceCard()),
                  if (provider.nativeAd?.adData.enabled ?? false) ...[
                    AdSlot(
                      ad: provider.nativeAd,
                      safeAreaTop: false,
                      safeAreaBottom: false,
                    ),
                    SizedBox(height: AppSize.h5),
                  ] else
                    SizedBox(height: AppSize.h12),
                  _hPad(_PendingWithdrawBanner(provider: provider)),
                  SizedBox(height: AppSize.h4),
                  _hPad(
                    _CategoryTabs(
                      categories: categories,
                      selectedIndex: categoryIndex,
                      onChanged: (i) {
                        provider.setSelectedIndex(i);
                        provider.setWithdrawType(categories[i].dbTitle);
                      },
                    ),
                  ),
                  _hPad(
                    _MethodsGrid(
                      items: visibleItems,
                      selectedIndex: selectedMethodIndex,
                      onChanged: (i) {
                        provider.setWithdrawSubType(
                          currentCategory.items[i].dbTitle,
                        );
                      },
                    ),
                  ),
                  if (canExpand) ...[
                    Center(
                      child: GestureDetector(
                        onTap: () => setState(
                          () => _expanded[categoryIndex] = !isExpanded,
                        ),
                        child: Text(
                          isExpanded ? 'View Less' : 'View More',
                          style: TextStyle(
                            fontFamily: FontFamily.kommonGrotesk,
                            fontSize: AppSize.sp15,
                            fontWeight: FontWeight.w900,
                            color: context.themeColors.buttonColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: AppSize.h18),
                  _hPad(
                    _AmountCard(
                      amount: _amount,
                      onChanged: (v) => setState(() => _amount = v),
                    ),
                  ),
                  SizedBox(height: AppSize.h18),
                  _hPad(
                    _WithdrawCta(
                      amount: _amount,
                      onPressed: () =>
                          _openWithdrawSheet(provider, selectedItem),
                    ),
                  ),
                  SizedBox(height: AppSize.h12),
                  Center(
                    child: Text(
                      'Proceed within 24h - No fees on cash',
                      style: TextStyle(
                        fontFamily: FontFamily.kommonGrotesk,
                        fontSize: AppSize.sp12,
                        fontWeight: FontWeight.w600,
                        color: context.themeTextColors.bodyTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _hPad(Widget child) => Padding(
    padding: EdgeInsets.symmetric(horizontal: AppSize.w16),
    child: child,
  );

  void _openWithdrawSheet(WithdrawProvider provider, WithdrawItem item) {
    provider.setWithdrawSubType(item.dbTitle);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: WithdrawBottomSheet(item: item),
      ),
    ).then((_) => provider.resetWithdrawForm());
  }
}

// ── Live balance card ────────────────────────────────────────────────────────
class _LiveBalanceCard extends StatelessWidget {
  const _LiveBalanceCard();

  @override
  Widget build(BuildContext context) {
    final db = Injector.instance<AppDB>();
    return StreamBuilder(
      stream: db.userListenable(),
      builder: (context, _) {
        final coins = db.userModel?.coin ?? 0;
        final divider = RemoteConfigService.instance.coinToDollarDivider;
        final minCoins = RemoteConfigService.instance.minWithdrawAmount;
        final dollarValue = coins / divider;
        final minDollar = minCoins / divider;

        final whole = '\$${dollarValue.toStringAsFixed(2).split('.').first}';
        final fraction = '.${dollarValue.toStringAsFixed(5).split('.').last}';

        return BalanceCard(
          title: 'Available Balance',
          amountWhole: whole,
          amountFraction: fraction,
          body: _BalanceBody(coins: coins.toInt(), minDollar: minDollar),
        );
      },
    );
  }
}

// ── Balance body ─────────────────────────────────────────────────────────────
class _BalanceBody extends StatelessWidget {
  const _BalanceBody({required this.coins, required this.minDollar});

  final int coins;
  final double minDollar;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSize.w8,
      runSpacing: AppSize.h8,
      children: [
        _pill(
          surface: context.themeColors.coinSurfaceColor,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.icons.icCoin.svg(width: 18, height: 18),
              SizedBox(width: AppSize.w6),
              Text(
                '$coins Coins',
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp12,
                  fontWeight: FontWeight.w900,
                  color: _coinPillText,
                ),
              ),
            ],
          ),
        ),
        _pill(
          surface: context.themeColors.xpBadgeColor,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt_rounded,
                size: AppSize.sp16,
                color: context.themeColors.buttonBorderColor,
              ),
              SizedBox(width: AppSize.w4),
              Text(
                'Min. Withdrawal – \$${minDollar.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp12,
                  fontWeight: FontWeight.w900,
                  color: context.themeColors.buttonBorderColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pill({required Color surface, required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w10,
        vertical: AppSize.h6,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSize.r20),
      ),
      child: child,
    );
  }
}

// ── Pending withdrawal banner ────────────────────────────────────────────────
class _PendingWithdrawBanner extends StatelessWidget {
  const _PendingWithdrawBanner({required this.provider});

  final WithdrawProvider provider;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: provider.pendingWithdrawStream(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.w16,
            vertical: AppSize.h12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE6A817).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSize.r12),
            border: Border.all(
              color: const Color(0xFFE6A817).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                color: const Color(0xFFE6A817),
                size: AppSize.sp20,
              ),
              SizedBox(width: AppSize.w10),
              Expanded(
                child: Text(
                  'You have a pending withdrawal. New requests are disabled until it is approved.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.themeTextColors.darkTitleColor,
                    fontSize: AppSize.sp13,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Withdraw CTA ────────────────────────────────────────────────────────────
class _WithdrawCta extends StatelessWidget {
  const _WithdrawCta({required this.amount, required this.onPressed});

  final double amount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: AppButton(
        text: 'Withdraw \$ ${amount.toStringAsFixed(2)}',
        buttonColor: context.themeColors.buttonColor,
        shadowColor: context.themeColors.buttonBorderColor,
        foregroundColor: context.themeColors.whiteColor,
        borderRadius: AppSize.r30,
        wallOffset: 4,
        textStyle: TextStyle(
          fontFamily: FontFamily.kommonGrotesk,
          fontSize: AppSize.sp16,
          fontWeight: FontWeight.w900,
          color: context.themeColors.whiteColor,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

// ── Category tabs ───────────────────────────────────────────────────────────
class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.categories,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<WithdrawCategory> categories;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const double _wallOffset = 4;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSize.h42 + _wallOffset,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        itemCount: categories.length,
        separatorBuilder: (_, _) => SizedBox(width: AppSize.w10),
        itemBuilder: (_, i) {
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(bottom: isSelected ? 0 : _wallOffset),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.w18,
                  vertical: AppSize.h10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.themeColors.buttonColor
                      : context.themeColors.whiteColor,
                  borderRadius: BorderRadius.circular(AppSize.r28),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: context.themeColors.buttonBorderColor,
                            offset: const Offset(0, _wallOffset),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  categories[i].title,
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp14,
                    fontWeight: FontWeight.w900,
                    color: isSelected
                        ? context.themeColors.whiteColor
                        : context.themeColors.buttonBorderColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Methods grid ────────────────────────────────────────────────────────────
class _MethodsGrid extends StatelessWidget {
  const _MethodsGrid({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<WithdrawItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSize.w10,
        mainAxisSpacing: AppSize.h12,
        childAspectRatio: 0.99,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        return _MethodTile(
          item: items[i],
          isSelected: i == selectedIndex,
          onTap: () => onChanged(i),
        );
      },
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final WithdrawItem item;
  final bool isSelected;
  final VoidCallback onTap;

  static const double _wallOffset = 3;
  static const double _radius = 20;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(bottom: isSelected ? 0 : _wallOffset),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isSelected
                ? context.themeColors.buttonColor
                : context.themeColors.whiteColor,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: isSelected
                  ? context.themeColors.buttonColor
                  : context.themeColors.borderColor2,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: context.themeColors.buttonBorderColor,
                      offset: const Offset(0, _wallOffset),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.w2,
            vertical: AppSize.h10,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: AppSize.w42,
                height: AppSize.w42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.themeColors.whiteColor.withValues(alpha: 0.16)
                      : item.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSize.r12),
                ),
                child: item.icon,
              ),
              SizedBox(height: AppSize.h8),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp12,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? context.themeColors.whiteColor
                      : context.themeColors.buttonBorderColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Amount card ─────────────────────────────────────────────────────────────
class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.amount, required this.onChanged});

  final double amount;
  final ValueChanged<double> onChanged;

  static const _quickAmounts = [1.0, 5.0, 10.0, 25.0];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.w16),
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r24),
        border: Border.all(color: context.themeColors.borderColor2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Enter Withdrawal Amount',
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp13,
                  fontWeight: FontWeight.w600,
                  color: context.themeTextColors.bodyTextColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => onChanged(0.00015),
                child: Text(
                  'Use all',
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp13,
                    fontWeight: FontWeight.w900,
                    color: context.themeColors.buttonColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h12),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: FontFamily.kommonGrotesk,
                fontWeight: FontWeight.w900,
                color: context.themeTextColors.textColor,
                letterSpacing: -1,
              ),
              children: [
                TextSpan(
                  text: '\$ ',
                  style: TextStyle(
                    fontSize: AppSize.sp26,
                    color: context.themeTextColors.mutedTextColor,
                  ),
                ),
                TextSpan(
                  text: amount.toStringAsFixed(2).split('.').first,
                  style: TextStyle(fontSize: AppSize.sp40),
                ),
                TextSpan(
                  text: '.${amount.toStringAsFixed(2).split('.').last}',
                  style: TextStyle(
                    fontSize: AppSize.sp40,
                    color: context.themeTextColors.mutedTextColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSize.h14),
          Row(
            children: [
              for (final a in _quickAmounts) ...[
                Expanded(
                  child: _QuickAmount(
                    value: a,
                    isSelected: a == amount,
                    onTap: () => onChanged(a),
                  ),
                ),
                if (a != _quickAmounts.last) SizedBox(width: AppSize.w8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAmount extends StatelessWidget {
  const _QuickAmount({
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final double value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSize.h38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? context.themeColors.buttonColor.withValues(alpha: 0.08)
              : context.themeColors.whiteColor,
          borderRadius: BorderRadius.circular(AppSize.r24),
          border: Border.all(color: context.themeColors.borderColor2),
        ),
        child: Text(
          '\$ ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontFamily: FontFamily.kommonGrotesk,
            fontSize: AppSize.sp14,
            fontWeight: FontWeight.w900,
            color: context.themeColors.buttonBorderColor,
          ),
        ),
      ),
    );
  }
}
