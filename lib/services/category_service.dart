import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/category_model.dart';
import 'database_helper.dart';

class CategoryService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));

  Future<List<CategoryModel>> fetchUserCategories() async {
    final dbHelper = DatabaseHelper.instance;
    final token = await dbHelper.getToken();
    if (token == null) return [];

    try {
      final response = await _dio.get(
        '/app/user/categories',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['data'] is List) {
        final List<dynamic> categoryList = response.data['data'];
        return categoryList.map((json) => CategoryModel.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar categorias: $e');
      return [];
    }
  }
}
