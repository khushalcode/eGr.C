import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsHelper {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  // Get analytics instance
  static FirebaseAnalytics get analytics => _analytics;

  // Set user properties
  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // Screen tracking
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
    );
  }

  // E-commerce events
  static Future<void> logViewProduct({
    required String productId,
    required String productName,
    required String category,
    required double price,
  }) async {
    await _analytics.logViewItem(
      currency: 'USD',
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productName,
          itemCategory: category,
          price: price,
        ),
      ],
    );
  }

  static Future<void> logAddToCart({
    required String productId,
    required String productName,
    required String category,
    required double price,
    required int quantity,
  }) async {
    await _analytics.logAddToCart(
      currency: 'USD',
      value: price * quantity,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productName,
          itemCategory: category,
          price: price,
          quantity: quantity,
        ),
      ],
    );
  }

  static Future<void> logRemoveFromCart({
    required String productId,
    required String productName,
    required double price,
    required int quantity,
  }) async {
    await _analytics.logRemoveFromCart(
      currency: 'USD',
      value: price * quantity,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productName,
          price: price,
          quantity: quantity,
        ),
      ],
    );
  }

  static Future<void> logBeginCheckout({
    required double value,
    required String currency,
    required List<AnalyticsEventItem> items,
  }) async {
    await _analytics.logBeginCheckout(
      value: value,
      currency: currency,
      items: items,
    );
  }

  static Future<void> logPurchase({
    required String transactionId,
    required double value,
    required String currency,
    required List<AnalyticsEventItem> items,
    double? tax,
    double? shipping,
  }) async {
    await _analytics.logPurchase(
      currency: currency,
      value: value,
      transactionId: transactionId,
      tax: tax,
      shipping: shipping,
      items: items,
    );
  }

  // Search event
  static Future<void> logSearch(String searchTerm) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  // Authentication events
  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  static Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  // Share event
  static Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
  }

  // Custom events
  static Future<void> logCustomEvent(
    String eventName, {
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  // Subscription events
  static Future<void> logSubscriptionPurchase({
    required String planId,
    required String planName,
    required double price,
    required int days,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_purchase',
      parameters: {
        'plan_id': planId,
        'plan_name': planName,
        'price': price,
        'days': days,
        'currency': 'USD',
      },
    );
  }

  static Future<void> logSubscriptionView({
    required String planId,
    required String planName,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_view',
      parameters: {
        'plan_id': planId,
        'plan_name': planName,
      },
    );
  }

  // Order events
  static Future<void> logOrderPlaced({
    required String orderId,
    required double totalAmount,
    required int itemCount,
    required String paymentMethod,
  }) async {
    await _analytics.logEvent(
      name: 'order_placed',
      parameters: {
        'order_id': orderId,
        'total_amount': totalAmount,
        'item_count': itemCount,
        'payment_method': paymentMethod,
        'currency': 'USD',
      },
    );
  }

  // Wishlist events
  static Future<void> logAddToWishlist({
    required String productId,
    required String productName,
    required double price,
  }) async {
    await _analytics.logAddToWishlist(
      currency: 'USD',
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productName,
          price: price,
        ),
      ],
    );
  }

  // App events
  static Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  static Future<void> logTutorialBegin() async {
    await _analytics.logTutorialBegin();
  }

  static Future<void> logTutorialComplete() async {
    await _analytics.logTutorialComplete();
  }
}
