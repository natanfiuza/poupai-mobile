// lib/services/transaction_service.dart
import 'package:dio/dio.dart';
import '../config/app_config.dart';
// import '../models/transaction_model.dart'; // Criaremos este modelo em breve

class TransactionService {
  final Dio _dio;

  TransactionService() : _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Aqui vamos pegar o token do flutter_secure_storage no futuro
          // final token = await getToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
          );
          return handler.next(e);
        },
      ),
    );
  }

  // Exemplo de como seria uma função para buscar transações
  Future<void> fetchTransactions() async {
    // Retorno será List<TransactionModel> no futuro
    try {
      final response = await _dio.get(AppConfig.endpointTransactions);

      if (response.statusCode == 200) {
        // Aqui faremos o parse da lista de transações
        print('Transações carregadas com sucesso!');
        // return (response.data['data'] as List)
        //   .map((json) => TransactionModel.fromJson(json))
        //   .toList();
      }
    } on DioException catch (e) {
      // Tratar erros de forma mais robusta
      print('Erro ao buscar transações: $e');
    }
  }
}
