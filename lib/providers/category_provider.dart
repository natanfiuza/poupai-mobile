import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../services/database_helper.dart';
import 'auth_provider.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final dbHelper = DatabaseHelper.instance;

  List<CategoryModel> _expenseCategories = [];
  List<CategoryModel> _receiptCategories = [];
  bool _isLoading = false;

  List<CategoryModel> get expenseCategories => _expenseCategories;
  List<CategoryModel> get receiptCategories => _receiptCategories;
  bool get isLoading => _isLoading;

  // Método chamado pelo ProxyProvider quando o AuthProvider muda
  void update(AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      loadCategories();
    } else {
      _expenseCategories = [];
      _receiptCategories = [];
    }
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    // Tenta carregar do banco de dados primeiro
    _expenseCategories = await dbHelper.getCategories('expense');
    _receiptCategories = await dbHelper.getCategories(
      'income',
    ); // Assumindo 'income' no JSON

    // Se estiver vazio, busca da API
    if (_expenseCategories.isEmpty || _receiptCategories.isEmpty) {
      final apiCategories = await _categoryService.fetchUserCategories();
      if (apiCategories.isNotEmpty) {
        await dbHelper.saveCategories(apiCategories);
        // Recarrega do banco de dados para garantir consistência
        _expenseCategories = await dbHelper.getCategories('expense');
        _receiptCategories = await dbHelper.getCategories('income');
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}
