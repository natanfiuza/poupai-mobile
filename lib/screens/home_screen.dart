import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pacote para formatação de moeda
// import 'package:fl_chart/fl_chart.dart'; // Pacote para o gráfico
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:smart_hbar_chart/smart_hbar_chart.dart';
import '../config/app_colors.dart';
import '../providers/auth_provider.dart';
import 'splash_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {},
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
                    backgroundImage: NetworkImage(user.photoUrl),
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
       body: ListView(
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
          // Colocamos os 3 cards dentro da mesma Row para que fiquem lado a lado
          const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Alinha os cards pelo topo
            children: [
              _MetricCard(
                title: 'Receitas',
                amount: 4500.00,
                percentageChange: 5.2,
                icon: Icons.trending_up,
                color: AppColors.successColor,
              ),
              SizedBox(width: 8),
              _MetricCard(
                title: 'Despesas',
                amount: 2950.00,
                percentageChange: 8.1,
                icon: Icons.trending_down,
                color: AppColors.expense,
              ),
              SizedBox(width: 8), // Adiciona um espaço entre os cards
              _MetricCard(
                title: 'Balanço',
                amount: 1550.00,
                percentageChange: -2.5,
                icon: Icons.account_balance_wallet,
                color: AppColors.secondaryColor,
              ),
            ],
          ),       
          const SizedBox(height: 16),
          const _RecentTransactionsList(),
          const SizedBox(height: 16),
          const _CategoriesBarChart(),
          const SizedBox(height: 80),
        ],
      ),
      // Botão flutuante para adicionar despesas
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar para a tela de Adicionar Despesa/Receita
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
          padding: const EdgeInsets.fromLTRB(16.0,16.0,16.0,16.0),
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
  const _CategoriesBarChart();

  @override
  Widget build(BuildContext context) {
    // DADOS FICTÍCIOS - Adaptados para a estrutura do Syncfusion
    final List<_ChartData> topExpensesData = [
      _ChartData('Saúde', 150.75),
      _ChartData('Lazer', 210.0),
      _ChartData('Transporte', 320.50),
      _ChartData('Moradia', 450.0),
      _ChartData('Alimentação', 850.45),
    ];

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
                    dataSource: topExpensesData,
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
  const _RecentTransactionsList();

  @override
  Widget build(BuildContext context) {
    // DADOS FICTÍCIOS
    final List<Map<String, dynamic>> transactions = [
      {'desc': 'Supermercado do Mês', 'cat': 'Alimentação', 'amount': -850.45},
      {'desc': 'Salário', 'cat': 'Salário', 'amount': 4500.00},
      {'desc': 'Conta de Internet', 'cat': 'Moradia', 'amount': -99.90},
      // Adicione mais 7 transações se desejar...
    ];
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
              final isIncome = tx['amount'] >= 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx['desc'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tx['cat'],
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isIncome ? "+" : "-"} ${currencyFormat.format(tx['amount'].abs())}',
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
