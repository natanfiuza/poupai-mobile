import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../services/database_helper.dart';
import 'add_transaction_screen.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  // Função auxiliar para formatar os cabeçalhos de data
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Hoje';
    } else if (date == yesterday) {
      return 'Ontem';
    } else {
      // Usar 'pt_BR' para garantir o formato correto do mês
      return DateFormat('d \'de\' MMMM', 'pt_BR').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos um Consumer para ouvir as alterações no TransactionProvider
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Transações')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.transactions.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma transação encontrada.',
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
              ),
            );
          }

          return GroupedListView<TransactionModel, DateTime>(
            elements: provider.transactions, // A lista de transações
            // Agrupa os elementos pela data (ignorando a hora)
            groupBy: (transaction) => DateTime(
              transaction.date.year,
              transaction.date.month,
              transaction.date.day,
            ),
            // Ordena os grupos pela data mais recente primeiro
            groupComparator: (date1, date2) => date2.compareTo(date1),
            // Constrói o cabeçalho para cada grupo de data
            groupSeparatorBuilder: (DateTime date) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                _formatDateHeader(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
              ),
            ),
            // Constrói cada item da lista de transações
            itemBuilder: (context, transaction) {
              final isIncome = transaction.type == 'receipt';
              final currencyFormat = NumberFormat.currency(
                locale: 'pt_BR',
                symbol: 'R\$',
              );

              return Dismissible(
                key: ValueKey(transaction.uuid),

                // Fundo para o deslize da ESQUERDA PARA A DIREITA (Editar)
                background: Container(
                  color: AppColors.successColor, // Fundo verde
                  padding: const EdgeInsets.only(left: 20.0),
                  alignment: Alignment.centerLeft,
                  child: const Icon(Icons.edit, color: Colors.white),
                ),

                // Fundo para o deslize da DIREITA PARA A ESQUERDA (Excluir)
                secondaryBackground: Container(
                  color: AppColors.expense, // Fundo vermelho
                  padding: const EdgeInsets.only(right: 20.0),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                // confirmDismiss é chamado antes de o item ser removido da tela.
                // Usamos ele para decidir qual ação tomar.
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // --- AÇÃO DE EDITAR ---
                    // Se deslizar para a direita, abre a tela de edição
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => AddTransactionScreen(
                              transactionToEdit: transaction,
                            ),
                          ),
                        )
                        .then((_) {
                          // Após voltar da tela de edição, atualiza a lista
                          Provider.of<TransactionProvider>(
                            context,
                            listen: false,
                          ).fetchTransactions();
                        });
                    // Retorna 'false' para que o item NÃO desapareça da lista
                    return false;
                  } else {
                    // --- AÇÃO DE EXCLUIR ---
                    // Se deslizar para a esquerda, executa a lógica de exclusão
                    await DatabaseHelper.instance.markTransactionAsDeleted(
                      transaction.id!,
                    );
                    Provider.of<TransactionProvider>(
                      context,
                      listen: false,
                    ).fetchTransactions();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${transaction.description} removido.'),
                      ),
                    );
                    // Retorna 'true' para que o item desapareça da lista
                    return true;
                  }
                },

                // O Card e o ListTile continuam a ser o conteúdo visível
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isIncome
                          ? AppColors.successColor
                          : AppColors.expense,
                      child: Icon(
                        isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      transaction.description,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(transaction.category),
                    trailing: Text(
                      '${isIncome ? "+" : "-"} ${currencyFormat.format(transaction.amount.abs())}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isIncome
                            ? AppColors.successColor
                            : AppColors.expense,
                      ),
                    ),
                    onTap: () {
                      // O onTap agora pode ser um atalho para a edição também
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) => AddTransactionScreen(
                                transactionToEdit: transaction,
                              ),
                            ),
                          )
                          .then((_) {
                            Provider.of<TransactionProvider>(
                              context,
                              listen: false,
                            ).fetchTransactions();
                          });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
