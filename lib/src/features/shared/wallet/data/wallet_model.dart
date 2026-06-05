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
    final balanceStr = json['balance']?.toString() ?? '0';
    final parsedBalance = double.tryParse(balanceStr)?.toInt() ?? 0;

    return WalletModel(
      address: json['address']?.toString() ?? '',
      balance: parsedBalance,
      balanceCache: (json['balance_cache'] as num?)?.toInt() ?? 0,
    );
  }
}
