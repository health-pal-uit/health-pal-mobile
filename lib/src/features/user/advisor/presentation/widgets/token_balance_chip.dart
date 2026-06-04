import 'package:da1/src/features/shared/wallet/data/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TokenBalanceChip extends StatefulWidget {
  const TokenBalanceChip({super.key});

  @override
  State<TokenBalanceChip> createState() => _TokenBalanceChipState();
}

class _TokenBalanceChipState extends State<TokenBalanceChip> {
  final WalletRepository _walletRepo = WalletRepository();
  int _balance = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final wallet = await _walletRepo.getWalletBalance();
      if (mounted) {
        setState(() {
          _balance = wallet?.balance ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await context.push('/wallet');

        _loadBalance();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.shade300, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on, color: Colors.orange, size: 18),
            const SizedBox(width: 6),
            _isLoading
                ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.orange,
                  ),
                )
                : Text(
                  '$_balance',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
            const SizedBox(width: 4),
            const Icon(Icons.add_circle, color: Colors.orange, size: 16),
          ],
        ),
      ),
    );
  }
}
