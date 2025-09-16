
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';

class SyncService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
  final dbHelper = DatabaseHelper.instance;
  bool _isSyncing = false;

  SyncService() {
    // Adicionar interceptador para incluir o token de autenticação nas requisições
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Busca o token do banco de dados local
          final token = await dbHelper.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<bool> sync() async {
    if (_isSyncing) {
      print('Sincronização já está em andamento.');
      return false;
    }
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print('Sem conexão com a internet. Sincronização cancelada.');
      return false;
    }

    bool dataChanged = false; // Flag para controlar se houve mudanças

    _isSyncing = true;
    print('--- Iniciando Sincronização ---');

    try {
      final bool uploaded =
          await _uploadLocalChanges(); // Envia as alterações locais primeiro
      final bool downloaded =
          await _downloadRemoteChanges(); // Depois, descarrega as alterações do servidor
      dataChanged = uploaded || downloaded;    
      print('--- Sincronização Concluída ---');
    } catch (e) {
      print('Erro durante a sincronização: $e');
    } finally {
      _isSyncing = false;
    }
    return dataChanged;
  }


  /// Envia as transações locais (criadas, editadas, deletadas) para o servidor.
  Future<bool> _uploadLocalChanges() async {
    final unsyncedTransactions = await dbHelper.getUnsyncedTransactions();
    if (unsyncedTransactions.isEmpty) return false;
    print('${unsyncedTransactions.length} transações locais para sincronizar.');

    for (final tx in unsyncedTransactions) {
      try {
        switch (tx.syncStatus) {
          case 'new':
            await _dio.post('/transactions', data: tx.toMap());
            break;
          case 'edited':
            await _dio.put('/transactions/${tx.uuid}', data: tx.toMap());
            break;
          case 'deleted':
            await _dio.delete('/transactions/${tx.uuid}');
            // Se a exclusão no servidor for bem-sucedida, removemos o registro localmente
            await dbHelper.deleteTransactionPermanently(tx.id!);
            continue; // Pula para a próxima iteração
        }

        // Se a operação foi bem-sucedida, atualiza o status local para 'synced'
        await dbHelper.updateTransactionStatus(tx.id!, 'synced');
      } catch (e) {
        print('Falha ao sincronizar a transação ${tx.uuid}: $e');
        // Continua para a próxima transação mesmo se uma falhar
      }
    }
    return true; 
  }

   /// Descarrega as transações do servidor e guarda-as localmente.
  Future<bool> _downloadRemoteChanges() async {
    print('A descarregar alterações do servidor...');
    try {
      // NOTA: Numa app em produção, adicionaríamos um parâmetro como ?since={lastSyncTimestamp}
      // para descarregar apenas os dados mais recentes. Por agora, descarregamos tudo.
      final response = await _dio.get('/transactions');

      if (response.statusCode == 200 && response.data['data'] is List) {
        final List<dynamic> remoteTransactions = response.data['data'];
        if (remoteTransactions.isEmpty) return false;
        print('Recebidas ${remoteTransactions.length} transações do servidor.');

        for (final txData in remoteTransactions) {
          // Marcamos os dados como 'synced' antes de os guardarmos localmente
          txData['syncStatus'] = 'synced';
          final transaction = TransactionModel.fromMap(txData);
          await dbHelper.upsertTransaction(transaction);
        }
        return true;
      }
    } catch (e) {
      print('Falha ao descarregar as alterações do servidor: $e');
    }
    return false;
  }
}
