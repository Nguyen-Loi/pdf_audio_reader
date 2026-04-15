import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pdf_audio_reader/core/utils/logger.dart';
import 'package:pdf_audio_reader/features/subscription/domain/entities/entitlement.dart';

// Product IDs — update to match App Store Connect / Google Play
const _kBackgroundPlayProductId = 'pdf_readcloud_background_play';

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(const SubscriptionState()) {
    _init();
  }

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  Future<void> _init() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      AppLogger.w('In-app purchase not available on this device');
      return;
    }

    // Listen to purchase stream
    _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (e) => AppLogger.e('Purchase stream error', e),
    );

    // Load products
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await InAppPurchase.instance.queryProductDetails(
        {_kBackgroundPlayProductId},
      );
      state = state.copyWith(
        isLoading: false,
        availableProducts: response.productDetails,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> purchasePremium() async {
    final products = state.availableProducts.cast<ProductDetails>();
    if (products.isEmpty) {
      state = state.copyWith(error: 'No products available');
      return;
    }
    final param = PurchaseParam(productDetails: products.first);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
  }

  Future<void> purchase() => purchasePremium();

  Future<void> restore() async {
    await InAppPurchase.instance.restorePurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID == _kBackgroundPlayProductId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          state = state.copyWith(isPremium: true);
          InAppPurchase.instance.completePurchase(purchase);
        } else if (purchase.status == PurchaseStatus.error) {
          state = state.copyWith(
            error: purchase.error?.message ?? 'Purchase failed',
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>(
  (_) => SubscriptionNotifier(),
);

class PremiumService {
  const PremiumService(this.ref);

  final Ref ref;

  bool get isPremium => ref.read(subscriptionProvider).isPremium;

  Future<void> purchasePremium() {
    return ref.read(subscriptionProvider.notifier).purchasePremium();
  }

  Future<void> restorePurchase() {
    return ref.read(subscriptionProvider.notifier).restore();
  }
}

final premiumServiceProvider = Provider<PremiumService>(
  (ref) => PremiumService(ref),
);
