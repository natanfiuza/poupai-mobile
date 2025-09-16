import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';
import 'auth_provider.dart'; 
import '../services/sync_service.dart'; 


class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  AuthProvider? _authProvider;

  // Getter para as receitas
  double get totalReceipts {
    return _transactions
        .where((tx) => tx.type == 'receipt')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Getter para as despesas
  double get totalExpenses {
    return _transactions
        .where((tx) => tx.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Getter para o balanço
  double get balance => totalReceipts - totalExpenses;

  // Getter para as 10 transações mais recentes
  List<TransactionModel> get recentTransactions {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    return _transactions.take(10).toList();
  }

  // Getter para as top 5 categorias de despesa
  List<Map<String, dynamic>> get topSpendingCategories {
    Map<String, double> categoryMap = {};
    _transactions.where((tx) => tx.type == 'expense').forEach((tx) {
      categoryMap.update(
        tx.category,
        (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    });

    var sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedCategories
        .take(5)
        .map((e) => {'category': e.key, 'amount': e.value})
        .toList();
  }

  /// Carrega todas as transações da base de dados local.
  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();
    _transactions = await DatabaseHelper.instance.getAllTransactions();
    _isLoading = false;
    notifyListeners();
  }

  /// Este método será chamado pelo ChangeNotifierProxyProvider
  void update(AuthProvider authProvider) {
    // Verifica se o estado de autenticação mudou para "logado"
    if (_authProvider?.isAuthenticated != true &&
        authProvider.isAuthenticated == true) {
      print('Usuário logado! Iniciando sincronização e carregamento de dados.');
      // Carrega os dados iniciais e depois inicia a sincronização em segundo plano
      fetchAndSync();
    }
    _authProvider = authProvider;
  }
  /// Nova função que carrega os dados locais e depois sincroniza
  Future<void> fetchAndSync() async {
    await fetchTransactions(); // Carrega os dados locais imediatamente para a UI
    final dataChanged = await SyncService()
        .sync(); // Sincroniza em segundo plano
    if (dataChanged) {
      // Se a sincronização alterou os dados, busca novamente para atualizar a UI
      await fetchTransactions();
    }
  }
}
