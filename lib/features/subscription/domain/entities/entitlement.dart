import 'package:equatable/equatable.dart';

class SubscriptionState extends Equatable {
  final bool isPremium;
  final bool isLoading;
  final String? error;
  final List<dynamic> availableProducts; // in_app_purchase ProductDetail

  const SubscriptionState({
    this.isPremium = false,
    this.isLoading = false,
    this.error,
    this.availableProducts = const [],
  });

  SubscriptionState copyWith({
    bool? isPremium,
    bool? isLoading,
    String? error,
    List<dynamic>? availableProducts,
  }) =>
      SubscriptionState(
        isPremium: isPremium ?? this.isPremium,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        availableProducts: availableProducts ?? this.availableProducts,
      );

  @override
  List<Object?> get props => [isPremium, isLoading, error];
}
