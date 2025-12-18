class TransactionModel {
  int? id;
  int accountId;
  int? categoryId; // Nullable for transfer
  int? transferAccountId; // For transfer
  double amount;
  String date; // ISO8601 string
  String note;
  String type; // 'income', 'expense', 'transfer'
  String createdAt;

  TransactionModel({
    this.id,
    required this.accountId,
    this.categoryId,
    this.transferAccountId,
    required this.amount,
    required this.date,
    required this.note,
    required this.type,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json["id"],
        accountId: json["account_id"],
        categoryId: json["category_id"],
        transferAccountId: json["transfer_account_id"],
        amount: json["amount"].toDouble(),
        date: json["date"],
        note: json["note"],
        type: json["type"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "account_id": accountId,
    "category_id": categoryId,
    "transfer_account_id": transferAccountId,
    "amount": amount,
    "date": date,
    "note": note,
    "type": type,
    "created_at": createdAt,
  };
}
