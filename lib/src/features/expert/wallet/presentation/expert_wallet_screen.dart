import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/core/bloc/auth/auth.dart';
import 'package:da1/src/features/expert/dashboard/presentation/widgets/expert_bottom_nav.dart';
import 'package:da1/src/features/shared/wallet/data/wallet_repository.dart';
import 'package:da1/src/features/shared/wallet/data/transaction_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart'; // Thêm import này cho Clipboard
import 'package:url_launcher/url_launcher.dart'; // Thêm import này cho url_launcher

class ExpertWalletScreen extends StatefulWidget {
  const ExpertWalletScreen({super.key});

  @override
  State<ExpertWalletScreen> createState() => _ExpertWalletScreenState();
}

class _ExpertWalletScreenState extends State<ExpertWalletScreen> {
  int _bottomNavIndex = 2;
  int _tabIndex = 0;

  final WalletRepository _walletRepo = WalletRepository();
  bool _isLoading = true;
  int _balance = 0;
  List<TransactionModel> _transactions = [];

  int _earningsThisMonth = 0;
  int _earningsLastMonth = 0;
  int _totalConsults = 0;
  int _consultsThisWeek = 0;

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    try {
      final wallet = await _walletRepo.getWalletBalance();
      final txs = await _walletRepo.getTransactions(limit: 100);

      if (mounted) {
        setState(() {
          _balance = wallet?.balance ?? 0;
          _transactions = txs;
          _calculateStats();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading wallet data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _calculateStats() {
    final now = DateTime.now();
    for (var tx in _transactions) {
      if (tx.type == 'credit' && tx.status == 'success') {
        _totalConsults++;

        if (tx.createdAt.month == now.month && tx.createdAt.year == now.year) {
          _earningsThisMonth += tx.amount;
        } else if (tx.createdAt.month ==
                (now.month == 1 ? 12 : now.month - 1) &&
            tx.createdAt.year == (now.month == 1 ? now.year - 1 : now.year)) {
          _earningsLastMonth += tx.amount;
        }

        if (now.difference(tx.createdAt).inDays <= 7) {
          _consultsThisWeek++;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/welcome');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 48,
                          left: 24,
                          right: 24,
                          bottom: 24,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFA9500), Color(0xFFFF8C00)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Wallet & Income',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Available Balance',
                                    style: TextStyle(
                                      color: Color(0xFFFFEDD4),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              '${NumberFormat('#,###').format(_balance)} ',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 36,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: 'Tokens',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'This Month',
                                            style: TextStyle(
                                              color: Color(0xFFFFEDD4),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '+${NumberFormat('#,###').format(_earningsThisMonth)} T',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Last Month',
                                            style: TextStyle(
                                              color: Color(0xFFFFEDD4),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '+${NumberFormat('#,###').format(_earningsLastMonth)} T',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Statistics Cards
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    '📞',
                                    '$_totalConsults',
                                    'Consults',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    '📅',
                                    '$_consultsThisWeek',
                                    'This Week',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Withdraw Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Tính năng rút tiền đang được phát triển!',
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Withdraw Tokens',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Tabs
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECECF0),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap:
                                          () => setState(() => _tabIndex = 0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              _tabIndex == 0
                                                  ? Colors.white
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Earnings',
                                            style: TextStyle(
                                              color: Color(0xFF0A0A0A),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap:
                                          () => setState(() => _tabIndex = 1),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              _tabIndex == 1
                                                  ? Colors.white
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Withdrawals',
                                            style: TextStyle(
                                              color: Color(0xFF0A0A0A),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Recent Consultations
                            Text(
                              _tabIndex == 0
                                  ? 'Recent Earnings'
                                  : 'Recent Withdrawals',
                              style: const TextStyle(
                                color: Color(0xFF364153),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._buildConsultationsList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        bottomNavigationBar: ExpertBottomNav(
          currentIndex: _bottomNavIndex,
          onTap: (index) {
            setState(() {
              _bottomNavIndex = index;
            });
            _handleNavigation(context, index);
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1.25,
            color: Colors.black.withValues(alpha: 0.10),
          ),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6A7282),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConsultationsList() {
    final targetType = _tabIndex == 0 ? 'credit' : 'debit';
    final filteredTxs =
        _transactions.where((tx) => tx.type == targetType).toList();

    if (filteredTxs.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              'No transactions found.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ];
    }

    return List.generate(filteredTxs.length, (index) {
      final tx = filteredTxs[index];

      final isCredit = tx.type == 'credit';
      final isSuccess = tx.status == 'success';
      final title =
          tx.note?.isNotEmpty == true
              ? tx.note!
              : (isCredit ? 'Consultation' : 'Withdrawal');
      final dateStr = DateFormat('MMM d, yyyy • HH:mm').format(tx.createdAt);
      final tokensStr = '${isCredit ? '+' : '-'}${tx.amount} T';
      final color =
          isSuccess
              ? (isCredit ? const Color(0xFF00A63E) : Colors.red)
              : Colors.grey;

      return GestureDetector(
        onTap: () => _showTransactionDetails(tx),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1.25,
                color: Colors.black.withValues(alpha: 0.10),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                isCredit
                                    ? const Color(0xFFFFEDD4)
                                    : Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCredit ? Icons.video_call : Icons.account_balance,
                            color: isCredit ? Colors.orange : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: const Color(0xFF101828),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  decoration:
                                      isSuccess
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  color: Color(0xFF6A7282),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        tokensStr,
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          decoration:
                              isSuccess
                                  ? TextDecoration.none
                                  : TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSuccess ? 'Success' : 'Failed',
                        style: TextStyle(
                          color:
                              isSuccess ? const Color(0xFF6A7282) : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF3F4F6), thickness: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSuccess
                              ? const Color(0xFFF0FDF4)
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isSuccess ? 'Completed' : 'Failed',
                      style: TextStyle(
                        color:
                            isSuccess
                                ? const Color(0xFF00A63E)
                                : Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showTransactionDetails(TransactionModel tx) {
    final isCredit = tx.type == 'credit';
    final isSuccess = tx.status == 'success';
    final dateStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(tx.createdAt);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  '${isCredit ? '+' : '-'}${tx.amount} T',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color:
                        isSuccess
                            ? (isCredit ? Colors.green : Colors.red)
                            : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSuccess ? 'Transaction Successful' : 'Transaction Failed',
                  style: TextStyle(
                    color: isSuccess ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(height: 32),
                _buildDetailRow('Time', dateStr),
                _buildDetailRow(
                  'Description',
                  tx.note ??
                      (isCredit ? 'Consultation Earnings' : 'Withdrawal'),
                ),
                _buildDetailRow(
                  'Transaction Type',
                  isCredit ? 'Received Tokens' : 'Withdrawn Tokens',
                ),

                if (tx.txHash != null) ...[
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Blockchain Tx Hash',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Row(
                        children: [
                          Text(
                            '${tx.txHash!.substring(0, 6)}...${tx.txHash!.substring(tx.txHash!.length - 4)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.copy,
                              size: 16,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: tx.txHash!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Hash copied!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final url = Uri.parse(
                          'https://sepolia.etherscan.io/tx/${tx.txHash}',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('View on Etherscan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/expert/dashboard');
        break;
      case 1:
        context.go('/expert/schedule');
        break;
      case 2:
        break;
      case 3:
        context.go('/expert/settings');
        break;
    }
  }
}
