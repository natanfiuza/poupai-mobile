import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pacote para formatação de moeda
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../config/app_colors.dart';
import '../providers/auth_provider.dart';
import 'splash_screen.dart';
import 'add_transaction_screen.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'transaction_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Garante que o build inicial seja concluído ANTES de chamar o fetchTransactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    // A barra de navegação inferior com o botão "+" centralizado
    final bottomAppBar = BottomAppBar(
      shape: const CircularNotchedRectangle(), // Cria o recorte para o botão
      notchMargin: 8.0,
      color: AppColors.cardBackground,
      elevation: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: AppColors.primaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.list_alt, color: AppColors.textSecondary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TransactionHistoryScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 48), // Espaço para o botão central
          IconButton(
            icon: const Icon(Icons.analytics, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        // Acessa o AuthProvider para obter os dados do usuário
        title: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.currentUser;
            if (user != null) {
              // Se o usuário estiver carregado, mostra a foto e o nome
              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    // Usa o CachedNetworkImageProvider para carregar e guardar a imagem em cache
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                    // Mostra um ícone padrão enquanto a imagem carrega ou se houver erro
                    onBackgroundImageError: (exception, stackTrace) {
                      print('Erro ao carregar a imagem: $exception');
                    },
                    backgroundColor: AppColors.backgroundColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    user.firstName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.secondaryColor,
                      fontSize: 18,
                    ),
                  ),
                ],
              );
            }
            // Fallback enquanto o usuário carrega ou se houver erro
            return const SizedBox.shrink();
          },
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: AppColors.secondaryColor),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: const _AppDrawer(),
      body: transactionProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                const SizedBox(height: 14),
                const Text(
                  'Vamos cuidar do seu bolso hoje?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: AppColors.secondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetricCard(
                      title: 'Receitas',
                      amount:
                          transactionProvider.totalReceipts, // <-- DADO REAL
                      percentageChange: 0, // TODO: Implementar lógica de %
                      icon: Icons.trending_up,
                      color: AppColors.successColor,
                    ),
                    const SizedBox(width: 8),
                    _MetricCard(
                      title: 'Despesas',
                      amount:
                          transactionProvider.totalExpenses, // <-- DADO REAL
                      percentageChange: 0, // TODO: Implementar lógica de %
                      icon: Icons.trending_down,
                      color: AppColors.expense,
                    ),
                    const SizedBox(width: 8),
                    _MetricCard(
                      title: 'Balanço',
                      amount: transactionProvider.balance, // <-- DADO REAL
                      percentageChange: 0, // TODO: Implementar lógica de %
                      icon: Icons.account_balance_wallet,
                      color: AppColors.secondaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Passa os dados reais para os widgets filhos
                _RecentTransactionsList(
                  transactions:
                      transactionProvider.recentTransactions, // <-- DADO REAL
                ),
                const SizedBox(height: 16),
                _CategoriesBarChart(
                  topExpensesData: transactionProvider
                      .topSpendingCategories, // <-- DADO REAL
                ),
                const SizedBox(height: 80),
              ],
            ),
      // Botão flutuante para adicionar despesas
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(),
                ),
              )
              .then((_) {
                // Esta função é executada quando voltamos da tela AddTransactionScreen
                // e força a atualização da lista de transações.
                Provider.of<TransactionProvider>(
                  context,
                  listen: false,
                ).fetchTransactions();
              });
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: bottomAppBar,
    );
  }
}

/// Widget privado para o menu lateral (DRAWER)
class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.backgroundColor),
            child: Row(
              children: [
                Image.asset('assets/images/logo_poupai.png', height: 40),
                const SizedBox(width: 16),
                const Text(
                  'Poupaí',
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontSize: 24,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Minha Conta'),
            onTap: () {
              // TODO: Navegar para a tela de Perfil
              Navigator.pop(context); // Fecha o menu
            },
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Categorias'),
            onTap: () {
              // TODO: Navegar para a tela de Categorias
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configurações'),
            onTap: () {
              // TODO: Navegar para a tela de Configurações
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () async {
              // Lógica de Logout
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.logout();

              if (context.mounted) {
                // Navega para a SplashScreen e remove todas as telas anteriores
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ADICIONE ESTES TRÊS NOVOS WIDGETS NO FINAL DO ARQUIVO home_screen.dart

/// WIDGET PARA OS CARDS DE MÉTRICAS (RECEITAS, DESPESAS, BALANÇO)
class _MetricCard extends StatelessWidget {
  final String title;
  final double amount;
  final double percentageChange;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.amount,
    required this.percentageChange,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      //symbol: 'R\$',
      symbol: '',
    );
    final isPositive = percentageChange >= 0;

    return Flexible(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  // Text(
                  //   title,
                  //   style: const TextStyle(
                  //     fontSize:9,
                  //     fontWeight: FontWeight.bold,
                  //     color: AppColors.textSecondary,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                currencyFormat.format(amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${isPositive ? '+' : ''}${percentageChange.toStringAsFixed(1)}% ',
                style: TextStyle(
                  color: isPositive
                      ? AppColors.successColor
                      : AppColors.expense,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// WIDGET PARA O GRÁFICO DE BARRAS DE CATEGORIAS
class _CategoriesBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> topExpensesData;
  const _CategoriesBarChart({required this.topExpensesData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top 5 Despesas por Categoria',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220, // Altura ajustada para o gráfico horizontal
              child: SfCartesianChart(
                // Propriedade que inverte o gráfico para horizontal
                isTransposed: true,

                // Remove as bordas do gráfico
                plotAreaBorderWidth: 0,

                // Eixo X (agora vertical) para as categorias
                primaryXAxis: const CategoryAxis(
                  majorGridLines: MajorGridLines(width: 0),
                  majorTickLines: MajorTickLines(size: 0),
                  axisLine: AxisLine(width: 0),
                ),

                // Eixo Y (agora horizontal) para os valores
                primaryYAxis: NumericAxis(
                  isVisible:
                      false, // Esconde o eixo dos valores para um visual mais limpo
                  majorGridLines: MajorGridLines(width: 0),
                ),

                series: <CartesianSeries>[
                  // Define as barras do gráfico
                  BarSeries<_ChartData, String>(
                    dataSource: topExpensesData
                        .map(
                          (data) =>
                              _ChartData(data['category'], data['amount']),
                        )
                        .toList(),
                    xValueMapper: (_ChartData data, _) => data.category,
                    yValueMapper: (_ChartData data, _) => data.value,
                    // Customização visual das barras
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                    width: 0.6, // Espessura relativa das barras
                    // Habilita os rótulos de dados (valores em R$) em cada barra
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      textStyle: const TextStyle(
                        color: AppColors.cardBackground,
                        fontWeight: FontWeight.bold,
                      ),
                      // Formata o valor como moeda
                      builder:
                          (
                            dynamic data,
                            dynamic point,
                            dynamic series,
                            int pointIndex,
                            int seriesIndex,
                          ) {
                            final currencyFormat = NumberFormat.currency(
                              locale: 'pt_BR',
                              symbol: '',
                            );
                            // Envolvemos a string formatada em um widget Text
                            return Text(
                              currencyFormat.format((data as _ChartData).value),
                            );
                          },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Classe auxiliar para estruturar os dados para o gráfico
class _ChartData {
  _ChartData(this.category, this.value);
  final String category;
  final double value;
}

/// WIDGET PARA A LISTA DE TRANSAÇÕES RECENTES
class _RecentTransactionsList extends StatelessWidget {
  final List<TransactionModel> transactions;
  const _RecentTransactionsList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Últimas Atividades',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...transactions.map((tx) {
              final isIncome = tx.type == 'receipt';
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.description,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tx.category,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isIncome ? "+" : "-"} ${currencyFormat.format(tx.amount.abs())}',
                      style: TextStyle(
                        color: isIncome
                            ? AppColors.successColor
                            : AppColors.expense,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
