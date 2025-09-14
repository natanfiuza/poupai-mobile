class TransactionModel {
  final int? id; // ID local, pode ser nulo se ainda não foi guardado
  final String uuid;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final String type; // 'expense' ou 'receipt'
  final String syncStatus;
  final DateTime lastModified;

  TransactionModel({
    this.id,
    required this.uuid,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    required this.syncStatus,
    required this.lastModified,
  });

  /// Converte um objeto TransactionModel para um Map, pronto para ser inserido na base de dados.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date
          .millisecondsSinceEpoch, // Guarda a data como um timestamp inteiro
      'type': type,
      'syncStatus': syncStatus,
      'lastModified': lastModified.millisecondsSinceEpoch,
    };
  }

  /// Converte um Map (vindo da base de dados) para um objeto TransactionModel.
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      uuid: map['uuid'],
      description: map['description'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      type: map['type'],
      syncStatus: map['syncStatus'],
      lastModified: DateTime.fromMillisecondsSinceEpoch(map['lastModified']),
    );
  }
}
