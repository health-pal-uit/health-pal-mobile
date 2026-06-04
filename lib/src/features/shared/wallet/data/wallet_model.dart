class WalletModel {
  final String address;
  final int balance;
  final int balanceCache;

  WalletModel({
    required this.address,
    required this.balance,
    required this.balanceCache,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      address: json['address'] ?? '',
      balance: int.tryParse(json['balance'].toString()) ?? 0,
      balanceCache: json['balance_cache'] ?? 0,
    );
  }
}
