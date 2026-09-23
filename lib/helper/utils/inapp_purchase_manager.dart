import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:project/helper/generalWidgets/paymentDialogWidget.dart';
import 'package:project/helper/utils/generalImports.dart';

class InAppPurchaseManager {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  String? packageId;
  String? productId;
  static Set<String> processedPurchaseIds = {};
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  Future<void> close() async {
    // Cancel the subscription when closing.
    await _subscription.cancel();
  }

  // Make sure to call this method when you are done with the instance
  // to avoid memory leaks and dangling subscriptions.
  void dispose() {
    close();
  }

  Future<ProductDetails> getProductByProductId(String productId) async {
    ProductDetailsResponse productDetailsResponse = await _inAppPurchase.queryProductDetails({productId});

    return productDetailsResponse.productDetails.first;
  }

  void onSuccessfulPurchase(BuildContext context, PurchaseDetails purchase) async {
    purchaseCompleteDialog(purchase);
  }

  void onPurchaseCancel(BuildContext context, PurchaseDetails purchase) async {
    paymentCancelDialog(context);
  }

  void onErrorPurchase(BuildContext context, PurchaseDetails purchase) async {
    paymentErrorDialog(context, purchase);
  }

  void onPendingPurchase(PurchaseDetails purchase) async {
    if (purchase.purchaseID != null && purchase.pendingCompletePurchase) {
      try {
        await Future.delayed(Duration(seconds: 1));
        await _inAppPurchase.completePurchase(purchase);
      } catch (e) {}
    }
  }

  void onRestoredPurchase(PurchaseDetails purchase) async {}

  Future completePending(event) async {
    for (var _purchaseDetails in event) {
      if (_purchaseDetails.purchaseID != null && _purchaseDetails.pendingCompletePurchase) {
        try {
          await Future.delayed(Duration(seconds: 1));
          await _inAppPurchase.completePurchase(_purchaseDetails);
        } catch (e) {
          debugPrint('Error completing purchase: $e');
          // Handle the error appropriately
        }
      }
    }
  }

  static void getPending() {
    _inAppPurchase.purchaseStream.listen((event) {
      ;
    });
  }

  void listenIAP(BuildContext context) {
    _subscription = _inAppPurchase.purchaseStream.listen(
      (event) async {
        //await completePending(event);
        for (PurchaseDetails inAppPurchaseEvent in event) {
          if (inAppPurchaseEvent.error != null) {}
          if (inAppPurchaseEvent.purchaseID != null && inAppPurchaseEvent.pendingCompletePurchase) {
            try {
              await Future.delayed(Duration(seconds: 1));
              await _inAppPurchase.completePurchase(inAppPurchaseEvent);
            } catch (e) {
              debugPrint('Error completing purchase: $e');
              // Handle the error appropriately
            }
          }

          Future.delayed(
            Duration.zero,
            () async {
              if (inAppPurchaseEvent.status == PurchaseStatus.purchased || inAppPurchaseEvent.status == PurchaseStatus.restored) {
                await _inAppPurchase.completePurchase(inAppPurchaseEvent);
                onSuccessfulPurchase(context, inAppPurchaseEvent);
              } else if (inAppPurchaseEvent.status == PurchaseStatus.canceled) {
                onPurchaseCancel(context, inAppPurchaseEvent);
              } else if (inAppPurchaseEvent.status == PurchaseStatus.error) {
                onErrorPurchase(context, inAppPurchaseEvent);
              }

              if (inAppPurchaseEvent.pendingCompletePurchase) {
                await _inAppPurchase.completePurchase(inAppPurchaseEvent);
              }
            },
          );
        }
      },
      onDone: () {
        // Cancel the subscription when the stream is done
        _subscription.cancel();
      },
      onError: (error) {
        debugPrint('Purchase stream error: $error');
      },
    );
  }

  Future<void> buy(String productId, String packageId) async {
    bool _isAvailable = await _inAppPurchase.isAvailable();
    if (_isAvailable) {
      ProductDetails productDetails = await getProductByProductId(productId);

      this.packageId = packageId;
      this.productId = productId;
      await _inAppPurchase.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: productDetails),
      );
    }
  }

  void purchaseCompleteDialog(PurchaseDetails purchase) async {
    final context = navigatorKey.currentContext!;

    if (packageId != null) {
      // Trigger the in-app purchase
      await context
          .read<InAppPurchaseProvider>()
          .inAppPurchase(packageId: int.parse(packageId!), method: ApiAndParams.inAppPurchase, purchaseToken: purchase.purchaseID!)
          .then((value) {
        if (value[ApiAndParams.status].toString() == "1") {
          // Listen to the provider state after the dialog is dismissed
          final providerState = context.read<InAppPurchaseProvider>().inAppPurchaseState;
          if (providerState == InAppPurchaseState.success) {
            Navigator.pushNamed(context, subscriptionSuccessScreen);
          } else if (providerState == InAppPurchaseState.failure) {
            showMessage(context, context.read<InAppPurchaseProvider>().error, MessageType.error);
          }
        }
      });
    }
  }

  void paymentCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const PaymentCancelDialog();
      },
    );
  }

  void paymentErrorDialog(BuildContext context, PurchaseDetails purchase) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PaymentErrorDialog(
          errorMessage: purchase.error?.message,
        );
      },
    );
  }
}
