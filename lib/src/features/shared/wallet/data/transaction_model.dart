class TransactionModel {
  final String id;
  final String type;
  final int amount;
  final String status;
  final String? txHash;
  final String? referenceId;
  final String? note;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    this.txHash,
    this.referenceId,
    this.note,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'credit',
      amount: json['amount'] ?? 0,
      status: json['status'] ?? 'pending',
      txHash: json['tx_hash'],
      referenceId: json['reference_id'],
      note: json['note'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at']).toLocal()
              : DateTime.now(),
    );
  }
}
