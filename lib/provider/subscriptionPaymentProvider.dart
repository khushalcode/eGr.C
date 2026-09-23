import 'package:project/helper/utils/generalImports.dart';


class SubscriptionPaymentProvider extends ChangeNotifier {
  String message = "";

  bool isPaymentUnderProcessing = false;

  // Subscription payment variables
  String subscriptionOrderId = "";
  String razorpayOrderId = "";
  String transactionId = "";
  String payStackReference = "";
  String paytmTxnToken = "";

  // Wallet variables for subscription
  bool useWallet = false;
  double walletUsedAmount = 0.0;
  double availableWalletAmount = 0.0;
  double totalSubscriptionAmount = 0.0;

  Future setSubscriptionPaymentProcessState(bool value) async {
    isPaymentUnderProcessing = value;
    notifyListeners();
  }

  void updateWalletUsage({
    required bool useWalletValue,
    required double walletBalance,
    required double subscriptionAmount,
  }) {
    useWallet = useWalletValue;
    if (useWalletValue) {
      if (walletBalance >= subscriptionAmount) {
        walletUsedAmount = subscriptionAmount;
        availableWalletAmount = walletBalance - subscriptionAmount;
        totalSubscriptionAmount = 0.0;
      } else {
        walletUsedAmount = walletBalance;
        availableWalletAmount = 0.0;
        totalSubscriptionAmount = subscriptionAmount - walletUsedAmount;
      }
    } else {
      availableWalletAmount = walletBalance;
      totalSubscriptionAmount = subscriptionAmount;
      walletUsedAmount = 0.0;
    }
    notifyListeners();
  }

  Future initiateSubscriptionPaytmTransaction({
    required BuildContext context,
    required String subscriptionPlanId,
    required String subscriptionAmount,
  }) async {
    try {
      Map<String, String> params = {};

      params[ApiAndParams.subscriptionPlanId] = subscriptionPlanId;
      params[ApiAndParams.amount] = subscriptionAmount;
      params[ApiAndParams.type] = "subscription";
      if (useWallet) {
        params[ApiAndParams.walletUsed] = "1";
        params[ApiAndParams.walletBalance] = walletUsedAmount.toString();
      }

      Map<String, dynamic> getPaytmTransactionTokenResponse =
          (await getPaytmTransactionTokenApi(context: context, params: params));

      if (getPaytmTransactionTokenResponse[ApiAndParams.status].toString() ==
          "1") {
        PaytmTransactionToken paytmTransactionToken =
            PaytmTransactionToken.fromJson(getPaytmTransactionTokenResponse);
        paytmTxnToken = paytmTransactionToken.data?.txnToken ?? "";
        notifyListeners();
      } else {
        showMessage(
          context,
          message,
          MessageType.warning,
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      message = e.toString();
      showMessage(
        context,
        message,
        MessageType.warning,
      );
      notifyListeners();
      return false;
    }
  }

  Future initiateSubscriptionRazorpayTransaction({
    required BuildContext context,
    required String subscriptionPlanId,
    required String subscriptionAmount,
  }) async {
    try {
      Map<String, String> params = {};

      params[ApiAndParams.paymentMethod] = context
          .read<PaymentMethodsProvider>()
          .selectedPaymentMethod
          .toString();
      params[ApiAndParams.subscriptionPlanId] = subscriptionPlanId;
      params[ApiAndParams.amount] = subscriptionAmount;
      params[ApiAndParams.type] = ApiAndParams.subscriptionType;
      if (useWallet) {
        params[ApiAndParams.walletUsed] = "1";
        params[ApiAndParams.walletBalance] = walletUsedAmount.toString();
      }

      Map<String, dynamic> getInitiatedTransactionResponse =
          (await getInitiatedTransactionApi(context: context, params: params));

      if (getInitiatedTransactionResponse[ApiAndParams.status].toString() ==
          "1") {
        InitiateTransaction initiateTransaction =
            InitiateTransaction.fromJson(getInitiatedTransactionResponse);
        razorpayOrderId = initiateTransaction.data.transactionId;
        notifyListeners();
      } else {
        showMessage(
          context,
          getInitiatedTransactionResponse["message"],
          MessageType.warning,
        );
        notifyListeners();
      }
      return getInitiatedTransactionResponse;
    } catch (e) {
      message = e.toString();
      showMessage(
        context,
        message,
        MessageType.warning,
      );
      notifyListeners();
    }
  }

  Future initiateSubscriptionPaypalTransaction({
    required BuildContext context,
    required String subscriptionPlanId,
    required String subscriptionAmount,
  }) async {
    try {
      Map<String, String> params = {};

      params[ApiAndParams.paymentMethod] = context
          .read<PaymentMethodsProvider>()
          .selectedPaymentMethod
          .toString();
      params[ApiAndParams.subscriptionPlanId] = subscriptionPlanId;
      params[ApiAndParams.amount] = subscriptionAmount;
      params[ApiAndParams.type] = "subscription";
      if (useWallet) {
        params[ApiAndParams.walletUsed] = "1";
        params[ApiAndParams.walletBalance] = walletUsedAmount.toString();
      }

      Map<String, dynamic> getInitiatedTransactionResponse =
          await getInitiatedTransactionApi(context: context, params: params);

      if (getInitiatedTransactionResponse[ApiAndParams.status].toString() ==
          "1") {
        Map<String, dynamic> data =
            getInitiatedTransactionResponse[ApiAndParams.data];
        Navigator.pushNamed(context, paypalPaymentScreen,
                arguments: data["paypal_redirect_url"])
            .then((value) async {
          if (value == "success" || value == "pending") {
            await getUserDetail(context: context).then(
              (value) {
                if (value[ApiAndParams.status].toString() == "1") {
                  context
                      .read<UserProfileProvider>()
                      .updateUserDataInSession(value, context);
                }
              },
            );
            if (value == "pending") {
              showMessage(
                  context,
                  getTranslatedValue(
                      context, "Subscription payment is pending"),
                  MessageType.warning);
            }
            Navigator.pop(context);
            Navigator.pushNamed(context, subscriptionSuccessScreen);
            return true;
          } else if (value == "fail") {
            showMessage(
              context,
              getTranslatedValue(context, paymentCancelledByUserLabel),
              MessageType.warning,
            );
            return false;
          }
        });
        notifyListeners();
      } else {
        showMessage(
          context,
          message,
          MessageType.warning,
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      message = e.toString();
      showMessage(
        context,
        message,
        MessageType.warning,
      );
      notifyListeners();
      return false;
    }
  }

  Future initiateSubscriptionMidtransTransaction({
    required BuildContext context,
    required String subscriptionPlanId,
    required String subscriptionAmount,
  }) async {
    try {
      Map<String, String> params = {};

      params[ApiAndParams.paymentMethod] = context
          .read<PaymentMethodsProvider>()
          .selectedPaymentMethod
          .toString();
      params[ApiAndParams.subscriptionPlanId] = subscriptionPlanId;
      params[ApiAndParams.amount] = subscriptionAmount;
      params[ApiAndParams.type] = "subscription";
      if (useWallet) {
        params[ApiAndParams.walletUsed] = "1";
        params[ApiAndParams.walletBalance] = walletUsedAmount.toString();
      }

      Map<String, dynamic> getInitiatedTransactionResponse =
          await getInitiatedTransactionApi(context: context, params: params);

      if (getInitiatedTransactionResponse[ApiAndParams.status].toString() ==
          "1") {
        Map<String, dynamic> data =
            getInitiatedTransactionResponse[ApiAndParams.data];

        if (data.containsKey("snapUrl") && data["snapUrl"].toString() != "") {
          Navigator.pushNamed(context, midtransPaymentScreen,
                  arguments: data["snapUrl"])
              .then((status_code) async {
            if (status_code is String) {
              if (status_code == "200" || status_code == "201") {
                await getUserDetail(context: context).then(
                  (value) {
                    if (value[ApiAndParams.status].toString() == "1") {
                      context
                          .read<UserProfileProvider>()
                          .updateUserDataInSession(value, context);
                    }
                  },
                );
                if (status_code == "201") {
                  showMessage(
                      context,
                      getTranslatedValue(
                          context, "Subscription payment is pending"),
                      MessageType.warning);
                }
                notifyListeners();
                Navigator.pop(context);
                Navigator.pushNamed(context, subscriptionSuccessScreen);
              } else if (status_code == "202") {
                showMessage(
                  context,
                  getTranslatedValue(context, paymentCancelledByUserLabel),
                  MessageType.warning,
                );
                notifyListeners();
                Navigator.pop(context, false);
              }
            }
          });
        }
      } else {
        showMessage(
          context,
          message,
          MessageType.warning,
        );
        notifyListeners();
        Navigator.pop(context, false);
      }
    } catch (e) {
      message = e.toString();
      showMessage(
        context,
        message,
        MessageType.warning,
      );
      notifyListeners();
      Navigator.pop(context, false);
    }
  }

  Future orderStatusPhonePe({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    try {
      Map<String, String> params = {};

      params[ApiAndParams.transactionId] = transactionId.toString();
      params[ApiAndParams.token] = token;

      Map<String, dynamic> getOrderStatusPhonePeResponse =
          await getOrderStatusPhonepeApi(context: context, params: params);

      if (getOrderStatusPhonePeResponse[ApiAndParams.status].toString() ==
          "1") {
        if (getOrderStatusPhonePeResponse[ApiAndParams.data]
                    [ApiAndParams.status] ==
                "SUCCESS" ||
            getOrderStatusPhonePeResponse[ApiAndParams.data]
                    [ApiAndParams.status] ==
                "COMPLETED") {
          Navigator.pop(context);
          Navigator.pushNamed(context, subscriptionSuccessScreen);
          notifyListeners();
        } else if (getOrderStatusPhonePeResponse[ApiAndParams.data]
                [ApiAndParams.status] ==
            "FAILED") {
          Navigator.pop(context, true);
          notifyListeners();
          showMessage(
            context,
            getTranslatedValue(context, orderPhonePeErrorLabel),
            MessageType.warning,
          );
        } else if (getOrderStatusPhonePeResponse[ApiAndParams.data]
                [ApiAndParams.status] ==
            "PAYMENT_ERROR") {
          Navigator.pop(context, true);
          notifyListeners();
          showMessage(
            context,
            getTranslatedValue(context, orderPhonePeErrorLabel),
            MessageType.warning,
          );
        } else if (getOrderStatusPhonePeResponse[ApiAndParams.data]
                [ApiAndParams.status] ==
            "PAYMENT_DECLINED") {
          Navigator.pop(context, true);
          notifyListeners();
          showMessage(
            context,
            getTranslatedValue(context, orderPhonePeDeclinedLabel),
            MessageType.warning,
          );
        } else if (getOrderStatusPhonePeResponse[ApiAndParams.data]
                [ApiAndParams.status] ==
            "PAYMENT_CANCELLED") {
          Navigator.pop(context, true);
          notifyListeners();
          showMessage(
            context,
            getTranslatedValue(context, orderPhonePeCancelledLabel),
            MessageType.warning,
          );
        }
      } else {
        Navigator.pop(context, true);
        showMessage(
          context,
          getOrderStatusPhonePeResponse[ApiAndParams.message].toString(),
          MessageType.warning,
        );
        notifyListeners();
      }
    } catch (e) {
      Navigator.pop(context, true);
      message = e.toString();
      showMessage(
        context,
        message,
        MessageType.warning,
      );
      notifyListeners();
    }
  }

  Future initiateSubscriptionPhonePeTransaction({
    required BuildContext context,
    required String subscriptionPlanId,
    required String subscriptionAmount,
  }) async {
    try {
      Map<String, String> params = {};

      params[ApiAndParams.paymentMethod] = context
          .read<PaymentMethodsProvider>()
          .selectedPaymentMethod
          .toString();
      params[ApiAndParams.subscriptionPlanId] = subscriptionPlanId;
      params[ApiAndParams.amount] = subscriptionAmount;
      params[ApiAndParams.type] = "subscription";
      if (useWallet) {
        params[ApiAndParams.walletUsed] = "1";
        params[ApiAndParams.walletBalance] = walletUsedAmount.toString();
      }

      Map<String, dynamic> getInitiatedTransactionResponse =
          await getInitiatedTransactionApi(context: context, params: params);

      if (getInitiatedTransactionResponse[ApiAndParams.status].toString() ==
          "1") {
        Map<String, dynamic> data =
            getInitiatedTransactionResponse[ApiAndParams.data];

        if (data.containsKey("redirectUrl") &&
            data["redirectUrl"].toString() != "") {
          Navigator.pushNamed(context, phonePePaymentScreen,
                  arguments: data["redirectUrl"])
              .then((status_code) async {
            if (status_code is String) {
              if (status_code == "SUCCESS" || status_code == "PENDING") {
                await getUserDetail(context: context).then(
                  (value) {
                    if (value[ApiAndParams.status].toString() == "1") {
                      context
                          .read<UserProfileProvider>()
                          .updateUserDataInSession(value, context);
                    }
                  },
                );
                if (status_code == "PENDING") {
                  showMessage(
                      context,
                      getTranslatedValue(context, orderPhonePePendingLabel),
                      MessageType.warning);
                  Navigator.pop(context);
                  Navigator.pushNamed(context, subscriptionSuccessScreen);
                } else if (status_code == "SUCCESS") {
                  orderStatusPhonePe(
                      context: context,
                      transactionId: data['merchantOrderId'],
                      token: data['token']);
                }
              } else if (status_code == "FAILED") {
                Navigator.pop(context, false);
                showMessage(
                  context,
                  getTranslatedValue(context, orderPhonePeErrorLabel),
                  MessageType.warning,
                );
                return false;
              } else if (status_code == "ERROR") {
                Navigator.pop(context, false);
                showMessage(
                  context,
                  getTranslatedValue(context, orderPhonePeErrorLabel),
                  MessageType.warning,
                );
                return false;
              } else if (status_code == "DECLINED") {
                Navigator.pop(context, false);
                showMessage(
                  context,
                  getTranslatedValue(context, orderPhonePeDeclinedLabel),
                  MessageType.warning,
                );
                return false;
              } else if (status_code == "CANCELLED") {
                Navigator.pop(context, false);
                showMessage(
                  context,
                  getTranslatedValue(context, orderPhonePeCancelledLabel),
                  MessageType.warning,
                );
                return false;
              }
            }
          });
        }
      } else {
        showMessage(
          context,
          message,
          MessageType.warning,
        );
        notifyListeners();
        Navigator.pop(context, false);
      }
    } catch (e) {
      message = e.toString();
      showMessage(
        context,
        message,
        MessageType.warning,
      );
      notifyListeners();
      Navigator.pop(context, false);
    }
  }

  Future initiateSubscriptionCashfreeTransaction({
    required BuildContext context,
    required String subscriptionPlanId,
    required String subscriptionAmount,
  }) async {
    try {
      Map<String, String> params = {};

      params[ApiAndParams.paymentMethod] = context
          .read<PaymentMethodsProvider>()
          .selectedPaymentMethod
          .toString();
      params[ApiAndParams.subscriptionPlanId] = subscriptionPlanId;
      params[ApiAndParams.amount] = subscriptionAmount;
      params[ApiAndParams.type] = "subscription";
      if (useWallet) {
        params[ApiAndParams.walletUsed] = "1";
        params[ApiAndParams.walletBalance] = walletUsedAmount.toString();
      }

      Map<String, dynamic> getInitiatedTransactionResponse =
          await getInitiatedTransactionApi(context: context, params: params);

      if (getInitiatedTransactionResponse[ApiAndParams.status].toString() ==
          "1") {
        Map<String, dynamic> data =
            getInitiatedTransactionResponse[ApiAndParams.data];

        if (data.containsKey("redirectUrl") &&
            data["redirectUrl"].toString() != "") {
          Navigator.pushNamed(context, cashfreePaymentScreen,
                  arguments: data["redirectUrl"])
              .then((status_code) async {
            if (status_code is String) {
              if (status_code == "success" || status_code == "pending") {
                await getUserDetail(context: context).then(
                  (value) {
                    if (value[ApiAndParams.status].toString() == "1") {
                      context
                          .read<UserProfileProvider>()
                          .updateUserDataInSession(value, context);
                    }
                  },
                );
                if (status_code == "pending") {
                  showMessage(
                      context,
                      getTranslatedValue(
                          context, "Subscription payment confirmed"),
                      MessageType.warning);
                }
                Navigator.pop(context);
                Navigator.pushNamed(context, subscriptionSuccessScreen);
              } else if (status_code == "failed") {
                Navigator.pop(context, false);
                showMessage(
                  context,
                  getTranslatedValue(context, "Subscription payment failed"),
                  MessageType.warning,
                );
                return false;
              } else if (status_code == "user_dropped") {
                Navigator.pop(context, false);
                showMessage(
                  context,
                  getTranslatedValue(context, paymentCancelledByUserLabel),
                  MessageType.warning,
                );
                return false;
              }
            }
          });
        }
      } else {
        showMessage(
          context,
          message,
          MessageType.warning,
        );
        notifyListeners();
        Navigator.pop(context, false);
      }
    } catch (e) {
      message = e.toString();
      showMessage(
        context,
        message,
        MessageType.warning,
      );
      notifyListeners();
      Navigator.pop(context, false);
    }
  }

  Future initiateSubscriptionPaytabsTransaction({
    required BuildContext context,
    required String subscriptionPlanId,
    required String subscriptionAmount,
  }) async {
    try {
      Map<String, String> params = {};

      params[ApiAndParams.paymentMethod] = context
          .read<PaymentMethodsProvider>()
          .selectedPaymentMethod
          .toString();
      params[ApiAndParams.subscriptionPlanId] = subscriptionPlanId;
      params[ApiAndParams.amount] = subscriptionAmount;
      params[ApiAndParams.type] = "subscription";
      if (useWallet) {
        params[ApiAndParams.walletUsed] = "1";
        params[ApiAndParams.walletBalance] = walletUsedAmount.toString();
      }

      Map<String, dynamic> getInitiatedTransactionResponse =
          await getInitiatedTransactionApi(context: context, params: params);

      if (getInitiatedTransactionResponse[ApiAndParams.status].toString() ==
          "1") {
        Map<String, dynamic> data =
            getInitiatedTransactionResponse[ApiAndParams.data];

        if (data.containsKey("redirectUrl") &&
            data["redirectUrl"].toString() != "") {
          Navigator.pushNamed(context, cashfreePaymentScreen,
                  arguments: data["redirectUrl"])
              .then((status_code) async {
            if (status_code is String) {
              if (status_code == "success" || status_code == "pending") {
                await getUserDetail(context: context).then(
                  (value) {
                    if (value[ApiAndParams.status].toString() == "1") {
                      context
                          .read<UserProfileProvider>()
                          .updateUserDataInSession(value, context);
                    }
                  },
                );
                if (status_code == "pending") {
                  showMessage(
                      context,
                      getTranslatedValue(
                          context, "Subscription payment confirmed"),
                      MessageType.warning);
                }
                Navigator.pop(context);
                Navigator.pushNamed(context, subscriptionSuccessScreen);
              } else if (status_code == "failed") {
                Navigator.pop(context, false);
                showMessage(
                  context,
                  getTranslatedValue(context, "Subscription payment failed"),
                  MessageType.warning,
                );
                return false;
              } else if (status_code == "user_dropped") {
                Navigator.pop(context, false);
                showMessage(
                  context,
                  getTranslatedValue(context, paymentCancelledByUserLabel),
                  MessageType.warning,
                );
                return false;
              }
            }
          });
        }
      } else {
        showMessage(
          context,
          message,
          MessageType.warning,
        );
        notifyListeners();
        Navigator.pop(context, false);
      }
    } catch (e) {
      message = e.toString();
      showMessage(
        context,
        message,
        MessageType.warning,
      );
      notifyListeners();
      Navigator.pop(context, false);
    }
  }

  Future initiateSubscriptionWalletTransaction({
    required BuildContext context,
    required String subscriptionPlanId,
    required String subscriptionAmount,
  }) async {
    try {
      // For wallet payment, directly add transaction without payment gateway
      transactionId = DateTime.now().millisecondsSinceEpoch.toString();

      await addSubscriptionTransaction(
        context: context,
        subscriptionPlanId: subscriptionPlanId,
        subscriptionAmount: subscriptionAmount,
      );
    } catch (e) {
      message = e.toString();
      showMessage(
        context,
        message,
        MessageType.warning,
      );
      setSubscriptionPaymentProcessState(false);
      notifyListeners();
    }
  }

  Future addSubscriptionTransaction({
    required BuildContext context,
    required String subscriptionPlanId,
    required String subscriptionAmount,
  }) async {
    try {
      PackageInfo packageInfo;
      packageInfo = await PackageInfo.fromPlatform();

      Map<String, String> params = {};

      params[ApiAndParams.subscriptionPlanId] = subscriptionPlanId;
      params[ApiAndParams.amount] = subscriptionAmount;
      params[ApiAndParams.deviceType] =
          setFirstLetterUppercase(Platform.operatingSystem);
      params[ApiAndParams.appVersion] = packageInfo.version;
      params[ApiAndParams.transactionId] = transactionId;
      params[ApiAndParams.paymentMethod] = context
          .read<PaymentMethodsProvider>()
          .selectedPaymentMethod
          .toString();
      params[ApiAndParams.type] = "subscription";
      if (useWallet) {
        params[ApiAndParams.walletUsed] = "1";
        params[ApiAndParams.walletBalance] = walletUsedAmount.toString();
      }

      Map<String, dynamic> addedTransaction =
          (await getAddTransactionApi(context: context, params: params));
      if (addedTransaction[ApiAndParams.status].toString() == "1") {
        // Update wallet balance if wallet was used
        /* if (useWallet) {
          Constant.session.setData(
              SessionManager.keyWalletBalance,
              transactionData[ApiAndParams.userBalance].toString(),
              true);
        } */

        isPaymentUnderProcessing = false;
        notifyListeners();
        Navigator.pop(context);
        Navigator.pushNamed(context, subscriptionSuccessScreen);
      } else {
        showMessage(
          context,
          addedTransaction[ApiAndParams.message],
          MessageType.warning,
        );
        isPaymentUnderProcessing = false;
        notifyListeners();
      }
    } catch (e) {
      message = e.toString();
      showMessage(
        context,
        message,
        MessageType.warning,
      );
      isPaymentUnderProcessing = false;
      notifyListeners();
    }
  }
}
