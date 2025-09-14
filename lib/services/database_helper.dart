import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  static const _databaseName = "poupai.db";
  static const _databaseVersion = 1;

  // Torna esta classe um singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Tem apenas uma referência à base de dados
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Inicia a base de dados pela primeira vez
    _database = await _initDatabase();
    return _database!;
  }

  // Abre a base de dados (e cria-a se não existir)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Comando SQL para criar a base de dados
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY,
        uuid TEXT NOT NULL,
        name TEXT NOT NULL,
        firstName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        photoUrl TEXT NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE session (
        id INTEGER PRIMARY KEY DEFAULT 1,
        token TEXT NOT NULL
      )
      ''');

    // --- ADICIONE O CÓDIGO ABAIXO ---
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL UNIQUE,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date INTEGER NOT NULL,
        type TEXT NOT NULL,
        syncStatus TEXT NOT NULL,
        lastModified INTEGER NOT NULL
      )
      ''');
  }

  /// Guarda ou atualiza o utilizador na base de dados.
  /// Usamos o ConflictAlgorithm.replace para uma lógica de "upsert" (update or insert).
  Future<int> saveUser(UserModel user) async {
    Database db = await instance.database;
    final userData = user.toJson();
    userData['id'] =
        1; // Garante que estamos sempre a trabalhar com a mesma linha
    return await db.insert(
      'user',
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Recupera o utilizador da base de dados.
  Future<UserModel?> getUser() async {
    Database db = await instance.database;
    final maps = await db.query('user', where: 'id = ?', whereArgs: [1]);
    if (maps.isNotEmpty) {
      return UserModel.fromJson(maps.first);
    }
    return null;
  }

  /// Guarda ou atualiza o token na base de dados.
  Future<int> saveToken(String token) async {
    Database db = await instance.database;
    return await db.insert('session', {
      'id': 1,
      'token': token,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Recupera o token da base de dados.
  Future<String?> getToken() async {
    Database db = await instance.database;
    final maps = await db.query('session', where: 'id = ?', whereArgs: [1]);
    if (maps.isNotEmpty) {
      return maps.first['token'] as String?;
    }
    return null;
  }

  /// Limpa todos os dados do utilizador e da sessão (usado no logout).
  Future<void> clearAllTables() async {
    Database db = await instance.database;
    await db.delete('user');
    await db.delete('session');
    print('Base de dados local limpa.');
  }

    /// Cria uma nova transação no banco de dados local.
  Future<TransactionModel> createTransaction(
    TransactionModel transaction,
  ) async {
    final db = await instance.database;
    // Insere a transação na tabela e o `insert` retorna o ID local gerado.
    final id = await db.insert('transactions', transaction.toMap());
    // Retorna uma nova instância do modelo com o ID local atribuído.
    return TransactionModel(
      id: id,
      uuid: transaction.uuid,
      description: transaction.description,
      amount: transaction.amount,
      category: transaction.category,
      date: transaction.date,
      type: transaction.type,
      syncStatus: transaction.syncStatus,
      lastModified: transaction.lastModified,
    );
  }

  /// Lê todas as transações do banco de dados que não foram marcadas como 'deleted'.
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    // Query para buscar todas as transações onde o status não é 'deleted',
    // ordenadas pela data mais recente primeiro.
    final result = await db.query(
      'transactions',
      where: 'syncStatus != ?',
      whereArgs: ['deleted'],
      orderBy: 'date DESC',
    );
    // Converte a lista de Maps para uma lista de TransactionModel.
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  /// Atualiza uma transação existente.
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?', // Usa o ID local para a atualização.
      whereArgs: [transaction.id],
    );
  }

  /// Marca uma transação para ser apagada (soft delete).
  /// Em vez de apagar o registo, apenas atualizamos o seu status.
  /// Isso permite que a alteração seja sincronizada com o servidor.
  Future<int> markTransactionAsDeleted(int id) async {
    final db = await instance.database;
    return db.update(
      'transactions',
      {
        'syncStatus': 'deleted',
        'lastModified': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Busca todas as transações que ainda não foram sincronizadas com o servidor.
  /// Este método será crucial para o nosso SyncService.
  Future<List<TransactionModel>> getUnsyncedTransactions() async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'syncStatus != ?',
      whereArgs: ['synced'],
    );
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }
}
