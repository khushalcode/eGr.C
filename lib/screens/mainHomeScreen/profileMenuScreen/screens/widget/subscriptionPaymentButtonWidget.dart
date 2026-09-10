import 'package:project/helper/utils/generalImports.dart';

class SubscriptionPaymentButtonWidget extends StatefulWidget {
  final BuildContext context;
  final String planId;
  final String planAmount;
  final bool useWallet;
  final double walletUsedAmount;
  final double availableWalletAmount;

  const SubscriptionPaymentButtonWidget({
    Key? key,
    required this.context,
    required this.planId,
    required this.planAmount,
    required this.useWallet,
    required this.walletUsedAmount,
    required this.availableWalletAmount,
  }) : super(key: key);

  @override
  State<SubscriptionPaymentButtonWidget> createState() =>
      SubscriptionPaymentButtonWidgetState();
}

class SubscriptionPaymentButtonWidgetState
    extends State<SubscriptionPaymentButtonWidget> {
  final Razorpay _razorpay = Razorpay();
  late String razorpayKey = "";
  late String paystackKey = "";
  late double amount = 0.00;
  late PaystackPlugin paystackPlugin;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) async {
      paystackPlugin = PaystackPlugin();

      _razorpay.on(
          Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorPayPaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorPayPaymentError);
      _razorpay.on(
          Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorPayExternalWallet);
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handleRazorPayPaymentSuccess(PaymentSuccessResponse response) {
    context.read<SubscriptionPaymentProvider>().transactionId =
        response.paymentId.toString();
    context.read<SubscriptionPaymentProvider>().addSubscriptionTransaction(
        context: context,
        subscriptionPlanId: widget.planId,
        subscriptionAmount: widget.planAmount);
  }

  void _handleRazorPayPaymentError(PaymentFailureResponse response) {
    context
        .read<SubscriptionPaymentProvider>()
        .setSubscriptionPaymentProcessState(false);
    showMessage(context, response.message.toString(), MessageType.warning);
  }

  void _handleRazorPayExternalWallet(ExternalWalletResponse response) {
    context
        .read<SubscriptionPaymentProvider>()
        .setSubscriptionPaymentProcessState(false);
    showMessage(context, response.toString(), MessageType.warning);
  }

  void openRazorPayGateway() async {
    final options = {
      'key': razorpayKey,
      'order_id':
          context.read<SubscriptionPaymentProvider>().razorpayOrderId,
      'prefill': {
        'contact': Constant.session.getData(SessionManager.keyPhone),
        'email': Constant.session.getData(SessionManager.keyEmail)
      },
    };

    _razorpay.open(options);
  }

  // Using package flutter_paystack
  Future openPaystackPaymentGateway() async {
    try {
      await paystackPlugin.initialize(
          publicKey: context
                  .read<PaymentMethodsProvider>()
                  .paymentMethodsData
                  ?.paystackPublicKey ??
              "0");

      Charge charge = Charge()
        ..amount = (widget.planAmount.toDouble * 100).toInt()
        ..currency = context
                .read<PaymentMethodsProvider>()
                .paymentMethodsData
                ?.paystackCurrencyCode ??
            ""
        ..reference = DateTime.now().millisecondsSinceEpoch.toString()
        ..email = Constant.session.getData(SessionManager.keyEmail);

      CheckoutResponse response = await paystackPlugin.checkout(
        context,
        fullscreen: false,
        logo: defaultImg(
          height: 50,
          width: 50,
          image: AppAssets.logoIcon,
          requiredRTL: false,
        ),
        method: CheckoutMethod.card,
        charge: charge,
      );

      if (response.status) {
        context.read<SubscriptionPaymentProvider>().transactionId =
            response.reference.toString();
        context.read<SubscriptionPaymentProvider>().addSubscriptionTransaction(
            context: context,
            subscriptionPlanId: widget.planId,
            subscriptionAmount: widget.planAmount);
      } else {
        context
            .read<SubscriptionPaymentProvider>()
            .setSubscriptionPaymentProcessState(false);
      }
    } catch (e) {
      showMessage(context, e.toString(), MessageType.error);
    }
  }

  openPaytmPaymentGateway(String subscriptionAmount) async {
    try {
      var response = PaytmPaymentsAllinonesdk().startTransaction(
        context
                .read<PaymentMethodsProvider>()
                .paymentMethodsData
                ?.paytmMerchantId ??
            "",
        context.read<SubscriptionPaymentProvider>().subscriptionOrderId,
        subscriptionAmount,
        context
            .read<SubscriptionPaymentProvider>()
            .paytmTxnToken
            .toString(),
        "",
        context.read<PaymentMethodsProvider>().paymentMethodsData?.paytmMode ==
            "sandbox",
        false,
      );
      response.then((value) {
        debugPrint(value.toString());
        setState(() {});
      }).catchError((onError) {
        if (onError is PlatformException) {
          setState(() {});
        } else {
          setState(() {});
        }
      });
    } catch (err) {}
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentMethodsProvider>(
      builder: (context, paymentMethodsProvider, child) {
        return Consumer<SubscriptionPaymentProvider>(
          builder: (context, subscriptionPaymentProvider, child) {
            return gradientBtnWidget(
              context,
              5,
              callback: () async {
                if (widget.planId.isNotEmpty &&
                    !subscriptionPaymentProvider.isPaymentUnderProcessing) {
                  subscriptionPaymentProvider
                      .setSubscriptionPaymentProcessState(true)
                      .then(
                    (value) {
                      amount = widget.planAmount.toDouble;
                      if (paymentMethodsProvider.selectedPaymentMethod ==
                          "Razorpay") {
                        razorpayKey = paymentMethodsProvider
                                .paymentMethodsData?.razorpayKey ??
                            "0";

                        context
                            .read<SubscriptionPaymentProvider>()
                            .initiateSubscriptionRazorpayTransaction(
                                context: context,
                                subscriptionPlanId: widget.planId,
                                subscriptionAmount: widget.planAmount)
                            .then((value) {
                          if (value["status"].toString() == "1") {
                            debugPrint("value:${value}");
                            openRazorPayGateway();
                          } else {
                            context
                                .read<SubscriptionPaymentProvider>()
                                .setSubscriptionPaymentProcessState(false);
                            showMessage(
                                context, value["message"], MessageType.warning);
                          }
                        });
                      } else if (paymentMethodsProvider.selectedPaymentMethod ==
                          "Paystack") {
                        return openPaystackPaymentGateway();
                      } else if (paymentMethodsProvider.selectedPaymentMethod ==
                          "Stripe") {
                        try {
                          StripeService.init(
                            stripeId: paymentMethodsProvider
                                    .paymentMethods?.data.stripePublishableKey ??
                                "",
                            secretKey: paymentMethodsProvider
                                    .paymentMethods?.data.stripeSecretKey ??
                                "",
                          ).then(
                            (value) {
                              StripeService.payWithPaymentSheet(
                                amount: int.parse(
                                    (amount * 100).toStringAsFixed(0)),
                                isTestEnvironment: true,
                                awaitedOrderId: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                context: context,
                                currency: paymentMethodsProvider
                                        .paymentMethods?.data.stripeCurrencyCode ??
                                    "0",
                                from: "subscription",
                              ).then(
                                (value) {
                                  return context
                                      .read<SubscriptionPaymentProvider>()
                                      .setSubscriptionPaymentProcessState(false);
                                },
                              );
                            },
                          );
                        } catch (e) {
                          showMessage(context, e.toString(), MessageType.error);
                        }
                      } else if (paymentMethodsProvider.selectedPaymentMethod ==
                          "Paytm") {
                        openPaytmPaymentGateway(widget.planAmount);
                      } else if (paymentMethodsProvider.selectedPaymentMethod ==
                          "Paypal") {
                        context
                            .read<SubscriptionPaymentProvider>()
                            .initiateSubscriptionPaypalTransaction(
                                context: context,
                                subscriptionPlanId: widget.planId,
                                subscriptionAmount: widget.planAmount)
                            .then(
                          (value) {
                            context
                                .read<SubscriptionPaymentProvider>()
                                .setSubscriptionPaymentProcessState(false);
                          },
                        );
                      } else if (paymentMethodsProvider.selectedPaymentMethod ==
                          "Midtrans") {
                        context
                            .read<SubscriptionPaymentProvider>()
                            .initiateSubscriptionMidtransTransaction(
                          context: context,
                          subscriptionPlanId: widget.planId,
                          subscriptionAmount: widget.planAmount,
                        );
                      } else if (paymentMethodsProvider.selectedPaymentMethod ==
                          "Phonepe") {
                        context
                            .read<SubscriptionPaymentProvider>()
                            .initiateSubscriptionPhonePeTransaction(
                          context: context,
                          subscriptionPlanId: widget.planId,
                          subscriptionAmount: widget.planAmount,
                        );
                      } else if (paymentMethodsProvider.selectedPaymentMethod ==
                          "Cashfree") {
                        context
                            .read<SubscriptionPaymentProvider>()
                            .initiateSubscriptionCashfreeTransaction(
                          context: context,
                          subscriptionPlanId: widget.planId,
                          subscriptionAmount: widget.planAmount,
                        );
                      } else if (paymentMethodsProvider.selectedPaymentMethod ==
                          "Paytabs") {
                        context
                            .read<SubscriptionPaymentProvider>()
                            .initiateSubscriptionPaytabsTransaction(
                          context: context,
                          subscriptionPlanId: widget.planId,
                          subscriptionAmount: widget.planAmount,
                        );
                      } else if (paymentMethodsProvider.selectedPaymentMethod ==
                          "Wallet") {
                        // Wallet payment - direct transaction without payment gateway
                        context
                            .read<SubscriptionPaymentProvider>()
                            .initiateSubscriptionWalletTransaction(
                          context: context,
                          subscriptionPlanId: widget.planId,
                          subscriptionAmount: widget.planAmount,
                        );
                      } else if (paymentMethodsProvider.selectedPaymentMethod ==
                          "COD") {
                        // COD not supported for subscriptions
                        context
                            .read<SubscriptionPaymentProvider>()
                            .setSubscriptionPaymentProcessState(false);
                        showMessage(
                            context,
                            "Cash on Delivery is not available for subscriptions",
                            MessageType.warning);
                      }
                    },
                  );
                }
              },
              title: getTranslatedValue(context, confirmLabel),
            );
          },
        );
      },
    );
  }
}
