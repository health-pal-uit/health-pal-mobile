import 'package:da1/src/features/shared/wallet/data/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final WalletRepository _walletRepo = WalletRepository();

  final List<Map<String, dynamic>> _topUpPackages = [
    {'tokens': 50, 'price': '49.000đ', 'bonus': null},
    {'tokens': 100, 'price': '99.000đ', 'bonus': null},
    {'tokens': 200, 'price': '189.000đ', 'bonus': 'Save 5%'},
    {'tokens': 500, 'price': '449.000đ', 'bonus': 'Save 10%'},
    {'tokens': 1000, 'price': '849.000đ', 'bonus': 'Best Value'},
    {'tokens': 2000, 'price': '1.599.000đ', 'bonus': 'Pro Pack'},
  ];

  Future<void> _handlePurchase(int tokenAmount) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(color: Colors.orange),
                SizedBox(width: 16),
                Expanded(child: Text("Đang kết nối Google Play...")),
              ],
            ),
          ),
    );

    try {
      await Future.delayed(const Duration(seconds: 2));

      await _walletRepo.topUpTokens(tokenAmount);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Success! You have topped up $tokenAmount Tokens!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred while processing payment: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Token Store',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Special Offer!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Get 2x Tokens on your first top-up of the month (applies to packages of 500 Tokens or more).',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Choose a package',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: _topUpPackages.length,
              itemBuilder: (context, index) {
                final package = _topUpPackages[index];
                final hasBonus = package['bonus'] != null;

                return InkWell(
                  onTap: () => _handlePurchase(package['tokens'] as int),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: hasBonus ? Colors.orange : Colors.grey.shade300,
                        width: hasBonus ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: hasBonus ? Colors.orange.shade50 : Colors.white,
                    ),
                    child: Stack(
                      children: [
                        if (hasBonus)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(14),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                package['bonus'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.monetization_on,
                                  color: Colors.orange,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${package['tokens']}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const Text(
                                'Tokens',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      hasBonus
                                          ? Colors.orange
                                          : Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  package['price'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
