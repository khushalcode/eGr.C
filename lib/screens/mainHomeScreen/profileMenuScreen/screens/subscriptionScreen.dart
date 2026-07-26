import 'package:project/helper/utils/generalImports.dart';
import 'package:project/helper/utils/inapp_purchase_manager.dart';
import 'package:project/models/subscriptionPlans.dart';
import 'package:project/models/subscriptionDetail.dart';
import 'package:project/helper/utils/analyticsHelper.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int selectedPlanIndex = 1; // Default to MAX Plus
  late final InAppPurchaseManager? _inAppPurchaseManager;

  bool get hasActiveSubscription {
    final status = Constant.session.hasActiveSubscription();
    return status == 'true' || status == '1';
  }

  @override
  void initState() {
    super.initState();

    // Log screen view for analytics
    AnalyticsHelper.logScreenView('subscription_screen');
    if (Platform.isIOS) {
      InAppPurchaseManager.getPending();
      _inAppPurchaseManager = InAppPurchaseManager();
      _inAppPurchaseManager!.listenIAP(context);
    } else {
      _inAppPurchaseManager = null;
    }

    _loadData();
  }

  @override
  void dispose() {
    _inAppPurchaseManager?.dispose();
    super.dispose();
  }

  void _loadData() {
    Future.delayed(Duration.zero).then((value) {
      context.read<PaymentMethodsProvider>().getPaymentMethods(context: context, from: "wallet_recharge");
      context.read<SubscriptionPlansProvider>().getSubscriptionPlansProvider(context: context);

      // Fetch active subscription if user has one
      if (hasActiveSubscription) {
        context.read<ActiveSubscriptionProvider>().getActiveSubscriptionProvider(context: context);
      }
    });
  }

  Future<void> _onRefresh() async {
    await getUserDetail(context: context).then((value) {
      if (value[ApiAndParams.status].toString() == "1") {
        context.read<UserProfileProvider>().updateUserDataInSession(value, context);

        // Refresh active subscription if user has one
        if (hasActiveSubscription) {
          context.read<ActiveSubscriptionProvider>().getActiveSubscriptionProvider(context: context);
        } else {
          // If no active subscription, reload plans
          context.read<SubscriptionPlansProvider>().getSubscriptionPlansProvider(context: context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: ColorsRes.appColor,
        child: CustomScrollView(
          slivers: [
            // SliverAppBar - Different based on subscription status
            hasActiveSubscription ? _buildActiveSliverAppBar() : _buildSliverAppBar(),

            // Scrollable Content - Different based on subscription status
            SliverToBoxAdapter(
              child: hasActiveSubscription ? _buildActiveSubscriptionContent(context) : _buildSubscriptionPlansContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: hasActiveSubscription ? null : _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.5,
      pinned: false,
      floating: false,
      backgroundColor: ColorsRes.appColorBlack,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: ColorsRes.appColorWhite),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: ColorsRes.appColorBlack,
          ),
          child: SafeArea(
            child: Column(
              children: [
                getSizedBox(height: 56), // Space for AppBar
                // eGrocerMAX Header
                Padding(
                  padding: EdgeInsetsDirectional.only(bottom: MediaQuery.of(context).size.height * 0.02),
                  child: Column(
                    children: [
                      defaultImg(
                        image: AppAssets.subscriptionIcon,
                        height: MediaQuery.of(context).size.width * 0.14,
                        width: MediaQuery.of(context).size.width * 0.14,
                      ),
                      getSizedBox(height: 12),
                      CustomTextLabel(
                        jsonKey: Constant.session.getSubscriptionName(),
                        style: TextStyle(
                          color: ColorsRes.appColorWhite,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      getSizedBox(height: 8),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: MediaQuery.of(context).size.width * 0.04,
                          end: MediaQuery.of(context).size.width * 0.04,
                        ),
                        child: CustomTextLabel(
                          text: getTranslatedValue(context, egrocerMaxSubtitleLabel)
                              .replaceAll("{subscriptionName}", Constant.session.getSubscriptionName()),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorsRes.appColorWhite.withValues(alpha: .80),
                            fontSize: 14,
                            fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Dotted Divider
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04,
                    vertical: MediaQuery.of(context).size.height * 0.03,
                  ),
                  child: DashedDivider(
                    color: ColorsRes.appColorWhite.withValues(alpha: .25),
                    height: 1,
                  ),
                ),
                // MAX Benefits Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextLabel(
                        jsonKey: maxBenefitsTitleLabel,
                        style: TextStyle(
                          color: ColorsRes.appColorWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      getSizedBox(height: 8),
                      _buildBenefitItemInAppBar(
                        icon: AppAssets.subscriptionFreeDeliveryIcon,
                        title: freeDeliveryTitleLabel,
                        description: freeDeliveryDescriptionLabel,
                      ),
                    ],
                  ),
                ),
                getSizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItemInAppBar({
    required String icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.015),
      decoration: BoxDecoration(
        color: ColorsRes.appColorWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            decoration: DesignConfig.boxDecoration(ColorsRes.appColorBlack, 9),
            padding: EdgeInsetsDirectional.all(MediaQuery.of(context).size.width * 0.03),
            child: defaultImg(
              image: icon,
              height: MediaQuery.of(context).size.width * 0.08,
              width: MediaQuery.of(context).size.width * 0.08,
            ),
          ),
          getSizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextLabel(
                  jsonKey: title,
                  style: TextStyle(
                    color: ColorsRes.appColorBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                getSizedBox(height: 4),
                CustomTextLabel(
                  jsonKey: description,
                  style: TextStyle(
                    color: ColorsRes.appColorBlack.withValues(alpha: .70),
                    fontSize: 12,
                    fontWeight: FontWeight.w400
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Content for subscription plans (when no active subscription)
  Widget _buildSubscriptionPlansContent() {
    return Column(
      children: [
        // Choose Your Plan Section
        _buildPlanSelection(),
        getSizedBox(height: 24),
        // FAQ Button
        _buildFaqButton(context),
      ],
    );
  }

  Widget _buildPlanSelection() {
    return Consumer<SubscriptionPlansProvider>(
      builder: (context, subscriptionPlansProvider, _) {
        if (subscriptionPlansProvider.subscriptionPlansState == SubscriptionPlansState.loading) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (subscriptionPlansProvider.subscriptionPlansState == SubscriptionPlansState.error) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CustomTextLabel(
                text: subscriptionPlansProvider.message,
                style: TextStyle(color: ColorsRes.appColorRed),
              ),
            ),
          );
        }

        if (subscriptionPlansProvider.subscriptionPlansState == SubscriptionPlansState.empty ||
            subscriptionPlansProvider.subscriptionPlansData?.plans == null ||
            subscriptionPlansProvider.subscriptionPlansData!.plans!.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CustomTextLabel(
                text: "No subscription plans available",
                style: TextStyle(color: ColorsRes.subTitleMainTextColor),
              ),
            ),
          );
        }

        final plans = subscriptionPlansProvider.subscriptionPlansData!.plans!;

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextLabel(
                jsonKey: chooseYourPlanTitleLabel,
                style: TextStyle(
                  color: ColorsRes.mainTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              getSizedBox(height: 16),
              ...List.generate(
                plans.length,
                (index) {
                  final plan = plans[index];
                  return Column(
                    children: [
                      _buildPlanCard(
                        index: index,
                        planData: plan,
                      ),
                      if (index < plans.length - 1) getSizedBox(height: 12),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlanCard({
    required int index,
    required Plans planData,
  }) {
    bool isSelected = selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlanIndex = index;
        });

        // Log subscription plan view
        AnalyticsHelper.logSubscriptionView(
          planId: planData.id ?? '',
          planName: planData.name ?? '',
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor,8,isboarder: true, bordercolor: isSelected ? ColorsRes.appColor : ColorsRes.cardBoarderColor,
        ),
        child: Row(
          children: [
            // Plan Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextLabel(
                          text: planData.name ?? "",
                          style: TextStyle(
                            color: ColorsRes.mainTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      getSizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ColorsRes.appColor,
                            borderRadius: BorderRadius.circular(80),
                          ),
                          child: CustomTextLabel(
                            text: "${planData.days ?? "0"} ${getTranslatedValue(context, dayLabel)}",
                            style: TextStyle(
                              color: ColorsRes.appColorWhite,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      getSizedBox(width: 10),
                      // Radio Button
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? ColorsRes.appColor : ColorsRes.subTitleMainTextColor,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorsRes.appColor,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      ],
                    /* ], */
                  ),
                  Container(margin: EdgeInsetsDirectional.only(top:16, bottom: 16), decoration: DesignConfig.boxDecoration(Theme.of(context).scaffoldBackgroundColor,12),padding: EdgeInsetsDirectional.all(12),
                    child: Row(
                      children: [
                        defaultImg(
                          image: AppAssets.subscriptionPlanIcon,
                          height: MediaQuery.of(context).size.width * 0.04,
                          width: MediaQuery.of(context).size.width * 0.04,
                          iconColor: ColorsRes.mainTextColor.withValues(alpha: .76),
                        ),
                        getSizedBox(width: 6),
                        CustomTextLabel(
                          text: "${getTranslatedValue(context, freeDeliveryConditionLabel)} ${(planData.freeDeliveryAbove ?? "0").toString().currency}",
                          style: TextStyle(
                            color: ColorsRes.mainTextColor.withValues(alpha: .76),
                            fontSize: 14,
                            fontWeight: FontWeight.w400
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: CustomTextLabel(
                          text: "${getTranslatedValue(context, filterTypePriceLabel)} :",
                          style: TextStyle(
                            color: ColorsRes.mainTextColor.withValues(alpha: .76),
                            fontSize: 14,
                            fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                      getSizedBox(width: 8),
                      CustomTextLabel(
                        text: ((planData.discountedPrice == null ||
                                planData.discountedPrice == "0" ||
                                planData.discountedPrice == "0.0" ||
                                planData.discountedPrice == "0.00") ? (planData.price ?? "0")
                                : planData.discountedPrice).toString().currency,
                        style: TextStyle(
                          color: ColorsRes.mainTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      getSizedBox(width: 8),
                      if ((planData.discountedPrice ?? "0").toString().toDouble > 0)
                        CustomTextLabel(
                          text: (planData.price ?? "0").toString().currency,
                          style: TextStyle(
                            color: ColorsRes.mainTextColor.withValues(alpha: .76),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,decorationColor: ColorsRes.mainTextColor.withValues(alpha: .76),
                            decoration: TextDecoration.lineThrough
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: DesignConfig.boxDecoration(
        Theme.of(context).cardColor,0
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, subscriptionFaqScreen);
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: DesignConfig.boxDecoration(
            Theme.of(context).scaffoldBackgroundColor,
            12,
            isboarder: true,
            bordercolor: ColorsRes.cardBoarderColor,
          ),
          child: Row(
            children: [
              Container(padding: EdgeInsetsDirectional.all(16),
                decoration: DesignConfig.boxDecoration(ColorsRes.appColor.withValues(alpha: .10),8
                ),
                child: defaultImg(
                  image: AppAssets.subscriptionFaqsIcon,
                  height: 26,
                  width: 26,
                ),
              ),
              getSizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextLabel(
                      jsonKey: faqTitleLabel,
                      style: TextStyle(
                        color: ColorsRes.mainTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    getSizedBox(height: 4),
                    CustomTextLabel(
                      jsonKey: faqSubtitleLabel,
                      style: TextStyle(
                        color: ColorsRes.mainTextColor.withValues(alpha: .76),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              getSizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: ColorsRes.subTitleMainTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Consumer<SubscriptionPlansProvider>(
      builder: (context, subscriptionPlansProvider, _) {
        if (subscriptionPlansProvider.subscriptionPlansState != SubscriptionPlansState.loaded ||
            subscriptionPlansProvider.subscriptionPlansData?.plans == null ||
            subscriptionPlansProvider.subscriptionPlansData!.plans!.isEmpty) {
          return SizedBox.shrink();
        }

        final plans = subscriptionPlansProvider.subscriptionPlansData!.plans!;

        // Ensure selectedPlanIndex is valid
        if (selectedPlanIndex >= plans.length) {
          selectedPlanIndex = 0;
        }

        final selectedPlan = plans[selectedPlanIndex];

        return Container(
          padding: EdgeInsetsDirectional.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: ColorsRes.appColorBlack.withValues(alpha: .05),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: gradientBtnWidget(
            context,
            12,
            callback: () {
              if(Platform.isIOS){
                _inAppPurchaseManager!.buy(selectedPlan.iosProductId!, selectedPlan.id!);
              }else{
              _showPaymentBottomSheet(
                selectedPlan.name ?? "",
                ((selectedPlan.discountedPrice=="0" || selectedPlan.discountedPrice=="0.00") ? selectedPlan.price : selectedPlan.discountedPrice).toString(),
                (selectedPlan.price ?? "0").toString(),
                selectedPlan.id ?? "",
                selectedPlan.name ?? "",
                int.tryParse(selectedPlan.days ?? '0') ?? 0,
                selectedPlan.discountedPrice.toString()
              );
              }
            },
            title: "${getTranslatedValue(context, subscribeToLabel)} ${selectedPlan.name ?? ""}",
          ),
        );
      },
    );
  }

  void _showPaymentBottomSheet(String selectedPlan, String planPrice, String originalPrice, String planId, String planName, int planDays, String discountPrice) {
    final paymentProvider = context.read<PaymentMethodsProvider>();
    final subscriptionPaymentProvider = context.read<SubscriptionPaymentProvider>();

    // Initialize wallet and total amount
    final walletBalance = Constant.session.getData(SessionManager.keyWalletBalance);
    final initialWalletBalance = double.tryParse(walletBalance) ?? 0.0;
    final originalAmount = double.tryParse(planPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

    // Reset provider variables for this payment session
    subscriptionPaymentProvider.updateWalletUsage(
      useWalletValue: false,
      walletBalance: initialWalletBalance,
      subscriptionAmount: originalAmount,
    );
    print(planPrice);
    print(originalPrice);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: false,
      shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
      backgroundColor: Theme.of(context).cardColor,
      builder: (BuildContext sheetContext) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<PaymentMethodsProvider>.value(
              value: paymentProvider,
            ),
            ChangeNotifierProvider<SubscriptionPaymentProvider>.value(
              value: subscriptionPaymentProvider,
            ),
          ],
          child: Wrap(
          children: [
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.75,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Payment Methods List
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                                // Wallet Option
                                /* if (initialWalletBalance > 0)
                                  Container(
                                    decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
                                    // padding: const EdgeInsets.all(10),
                                    margin: EdgeInsetsDirectional.only(
                                      start: 20,
                                      end: 20,
                                      top: 20,
                                    ),
                                    child: Row(
                                      children: [
                                        defaultImg(
                                          image: AppAssets.walletIcon,
                                          iconColor: ColorsRes.appColor,
                                        ),
                                        getSizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CustomTextLabel(
                                                jsonKey: walletBalanceLabel,
                                              ),
                                              CustomTextLabel(
                                                text: "${context.watch<SubscriptionPaymentProvider>().availableWalletAmount.toStringAsFixed(2)}".currency,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: ColorsRes.appColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        getSizedBox(width: 10),
                                        CustomCheckbox(
                                          value: context.watch<SubscriptionPaymentProvider>().useWallet,
                                          onChanged: (value) {
                                            if(value!){
                                            final originalAmount = double.tryParse(planPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                                            context.read<SubscriptionPaymentProvider>().updateWalletUsage(
                                              useWalletValue: value,
                                              walletBalance: initialWalletBalance,
                                              subscriptionAmount: originalAmount,
                                            );

                                            // If wallet is checked and covers full amount, set payment method to "Wallet"
                                            if (value && initialWalletBalance >= originalAmount) {
                                              context.read<PaymentMethodsProvider>().setSelectedPaymentMethod("Wallet");
                                            }
                                            }else{
                                              context.read<PaymentMethodsProvider>().setSelectedPaymentMethod("");
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ), */
                              (!context.watch<SubscriptionPaymentProvider>().useWallet ||
                               (context.watch<SubscriptionPaymentProvider>().useWallet &&
                                context.watch<SubscriptionPaymentProvider>().totalSubscriptionAmount > 0))
                                ?PaymentMethodsWidget(
                                  isPaymentUnderProcessing: context.watch<SubscriptionPaymentProvider>().isPaymentUnderProcessing,
                                  title: choosePaymentLabel
                                ):const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Bar
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .05),
                              blurRadius: 10,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextLabel(
                                    text: "$selectedPlan ${getTranslatedValue(context, planLabel)}",
                                    style: TextStyle(
                                      color: ColorsRes.mainTextColor.withValues(alpha: .76),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      CustomTextLabel(
                                        text: (planPrice).toDouble.toStringAsFixed(2).currency,
                                        style: TextStyle(
                                          color: ColorsRes.mainTextColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if ((discountPrice).toString().toDouble > 0) ...[
                                        getSizedBox(width: 8),
                                        CustomTextLabel(
                                          text: (originalPrice).toDouble.toStringAsFixed(2).currency,
                                          style: TextStyle(
                                              color: ColorsRes.mainTextColor.withValues(alpha: .76),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              decoration: TextDecoration.lineThrough,decorationColor: ColorsRes.mainTextColor.withValues(alpha: .76),
                                              decorationThickness: 2),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Builder(
                                builder: (builderContext) {
                                  final subscriptionProvider = builderContext.watch<SubscriptionPaymentProvider>();
                                  // Always pass original plan amount to API
                                  final originalPlanAmount = double.tryParse(planPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

                                  // Log subscription purchase attempt
                                  AnalyticsHelper.logSubscriptionPurchase(
                                    planId: planId,
                                    planName: planName,
                                    price: originalPlanAmount,
                                    days: planDays,
                                  );

                                  return SubscriptionPaymentButtonWidget(
                                    context: builderContext,
                                    planId: planId,
                                    planAmount: originalPlanAmount.toString(),
                                    useWallet: subscriptionProvider.useWallet,
                                    walletUsedAmount: subscriptionProvider.walletUsedAmount,
                                    availableWalletAmount: subscriptionProvider.availableWalletAmount,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          ),
        );
      },
    );
  }

  // Active Subscription SliverAppBar
  Widget _buildActiveSliverAppBar() {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.32,
      pinned: false,
      floating: false,
      backgroundColor: ColorsRes.subScriptionCardColor,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.arrow_back, color: ColorsRes.appColorWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: ColorsRes.subScriptionCardColor,
          ),
          child: Stack(fit: StackFit.loose,
            children: [
              // Background decoration image on right side
              PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                child: defaultImg(
                  image: AppAssets.subscriptionMaxIcon,
                  boxFit: BoxFit.fill,
                ),
              ),
              // Main content
              SafeArea(
                child: Container(alignment: Alignment.center,
                  padding: EdgeInsetsDirectional.only(bottom: MediaQuery.of(context).size.height * 0.02),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getSizedBox(height: 56), // Space for AppBar
                      defaultImg(
                        image: AppAssets.subscriptionActiveIcon,
                        height: MediaQuery.of(context).size.width * 0.2,
                        width: MediaQuery.of(context).size.width * 0.2,
                      ),
                      getSizedBox(height: 16),
                      CustomTextLabel(
                        jsonKey: planActiveTitleLabel,
                        style: TextStyle(
                          color: ColorsRes.appColorWhite,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),textAlign: TextAlign.center
                      ),
                      getSizedBox(height: 8),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: MediaQuery.of(context).size.width * 0.05,
                          end: MediaQuery.of(context).size.width * 0.05,
                        ),
                        child: CustomTextLabel(
                          text: getTranslatedValue(context, planActiveDescriptionLabel).replaceAll("{subscriptionName}", Constant.session.getSubscriptionName()),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorsRes.appColorWhite.withValues(alpha: .80),
                            fontSize: 14,
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
      ),
    );
  }

  // Active Subscription Content
  Widget _buildActiveSubscriptionContent(BuildContext context) {
    return Consumer<ActiveSubscriptionProvider>(
      builder: (context, activeSubscriptionProvider, _) {
        if (activeSubscriptionProvider.activeSubscriptionState == ActiveSubscriptionState.loading) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (activeSubscriptionProvider.activeSubscriptionState == ActiveSubscriptionState.error) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CustomTextLabel(
                text: activeSubscriptionProvider.message,
                style: TextStyle(color: ColorsRes.appColorRed),
              ),
            ),
          );
        }

        if (activeSubscriptionProvider.activeSubscriptionState == ActiveSubscriptionState.empty ||
            activeSubscriptionProvider.activeSubscriptionData == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CustomTextLabel(
                text: "No active subscription found",
                style: TextStyle(color: ColorsRes.subTitleMainTextColor),
              ),
            ),
          );
        }

        final subscriptionData = activeSubscriptionProvider.activeSubscriptionData!;

        return Column(
          children: [
            // Savings Card
            _buildSavingsCard(subscriptionData),
            // Current Plan Details
            _buildCurrentPlanSection(context, subscriptionData),
            // FAQ Button
            _buildFaqButton(context),
          ],
        );
      },
    );
  }

  Widget _buildSavingsCard(subscriptionDetail subscription) {
    return ((subscription.totalMoneySaved!="0"|| subscription.totalMoneySaved!="0.00") && subscription.deliveriesNumber!="0")?Container(
      margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      decoration:
          DesignConfig.boxDecoration(ColorsRes.appColorSafron.withValues(alpha: .10), 12, isboarder: true, bordercolor: ColorsRes.appColorSafron),
      child: Row(
        children: [
          Container(
            decoration: DesignConfig.boxDecoration(ColorsRes.appColorSafron, 5),
            padding: EdgeInsetsDirectional.all(MediaQuery.of(context).size.width * 0.02),
            child: defaultImg(
              image: AppAssets.subscriptionSaveAmountIcon,
              height: MediaQuery.of(context).size.width * 0.055,
              width: MediaQuery.of(context).size.width * 0.055,
            ),
          ),
          getSizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextLabel(
                  text: "${getTranslatedValue(context, savingsSummaryLabel).replaceAll("{amount}", (subscription.totalMoneySaved ?? "0").toString().currency).replaceAll("{deliveries}", (subscription.deliveriesNumber ?? "0").toString())}",
                  style: TextStyle(
                    color: ColorsRes.mainTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ): const SizedBox.shrink();
  }

  Widget _buildCurrentPlanSection(BuildContext context, subscriptionDetail subscription) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextLabel(
            jsonKey: currentPlanTitleLabel,
            style: TextStyle(
              color: ColorsRes.mainTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          getSizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            decoration: DesignConfig.boxDecoration(
              Theme.of(context).cardColor, 8,isboarder: true, bordercolor: Color(0xffD8E0E6)
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextLabel(
                        text: subscription.planName ?? "",
                        style: TextStyle(
                          color: ColorsRes.mainTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
                      decoration: DesignConfig.boxDecoration(ColorsRes.appColor,80
                      ),
                      child: CustomTextLabel(
                        jsonKey: activeLabel,
                        style: TextStyle(
                          color: ColorsRes.appColorWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsetsDirectional.only(top: 16),
                  padding: EdgeInsetsDirectional.only(top: 8, start: 8, bottom: 8, end: 8),
                  decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 8,
                      isboarder: true, bordercolor: ColorsRes.subTitleMainTextColor.withValues(alpha: 0.25)),
                  child: Row(
                    children: [
                      // Expires On Card
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 16,
                                  color: ColorsRes.mainTextColor.withValues(alpha: .65),
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: CustomTextLabel(
                                    jsonKey: expiresOnLabel,
                                    style: TextStyle(
                                      color: ColorsRes.mainTextColor.withValues(alpha: .65),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                SizedBox(width: 16),
                                SizedBox(width: 8),
                                CustomTextLabel(
                                  text: (subscription.endDate ?? "").toString().formatDateForSubscription(),
                                  style: TextStyle(
                                    color: ColorsRes.mainTextColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        height: context.height / 20,
                        width: 1,
                        color: ColorsRes.subTitleMainTextColor.withValues(alpha: 0.2),
                      ),
                      SizedBox(width: 12),
                      // Days Remaining Card
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_outlined,
                                  size: 16,
                                  color: ColorsRes.mainTextColor.withValues(alpha: .65),
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: CustomTextLabel(
                                    jsonKey: daysRemainingLabel,
                                    style: TextStyle(
                                      color: ColorsRes.mainTextColor.withValues(alpha: .65),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                SizedBox(width: 16),
                                SizedBox(width: 8),
                                CustomTextLabel(
                                  text: subscription.daysRemaining!="0"?subscription.daysRemaining : getTranslatedValue(context, expiresTodayLabel),
                                  style: TextStyle(
                                    color: ColorsRes.mainTextColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsetsDirectional.only(top: MediaQuery.of(context).size.height * 0.02),
                  decoration: DesignConfig.boxDecoration(Theme.of(context).scaffoldBackgroundColor, 12),
                  padding: EdgeInsetsDirectional.all(MediaQuery.of(context).size.width * 0.03),
                  child: Row(
                    children: [
                      defaultImg(
                        image: AppAssets.subscriptionPlanIcon,
                        height: MediaQuery.of(context).size.width * 0.04,
                        width: MediaQuery.of(context).size.width * 0.04,
                        iconColor: ColorsRes.mainTextColor
                      ),
                      getSizedBox(width: 6),
                      CustomTextLabel(
                        text: "${getTranslatedValue(context, freeDeliveryConditionLabel)} ${(subscription.freeDeliveryAbove ?? "0").toString().currency}",
                        style: TextStyle(color: ColorsRes.mainTextColor.withValues(alpha: .76), fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ],
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
