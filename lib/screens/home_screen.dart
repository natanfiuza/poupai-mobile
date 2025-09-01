// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pacote para formatação de moeda
import 'package:fl_chart/fl_chart.dart'; // Pacote para o gráfico
import 'package:provider/provider.dart';
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
        children: const [
          SizedBox(height: 24),
          Text(
            'Vamos cuidar do seu bolso hoje?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: AppColors.secondaryColor,
            ),
          ),
          SizedBox(height: 24),
          _SummaryCard(), // Widget do Card de Resumo
          SizedBox(height: 16),
          _CategoriesChart(), // Widget do Gráfico de Categorias
          SizedBox(
            height: 80,
          ), // Espaço extra para não ser coberto pela barra inferior
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

/// WIDGET PRIVADO PARA O CARD DE RESUMO
class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    // Usando o intl para formatar como moeda local (R$)
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    // DADOS FICTÍCIOS (MOCK DATA) - Substituir com dados reais do Provider
    final double balance = 1200.00;
    final double expenses =
        201.00; // Mockup tinha X$.20,100, interpretei como despesa

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(balance),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: AppColors.secondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.arrow_downward,
                  color: AppColors.expense,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${currencyFormat.format(expenses)} em despesas',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// WIDGET PRIVADO PARA O GRÁFICO DE CATEGORIAS
class _CategoriesChart extends StatelessWidget {
  const _CategoriesChart();

  @override
  Widget build(BuildContext context) {
    // DADOS FICTÍCIOS (MOCK DATA)
    final Map<String, double> categoryData = {
      'Alimentação': 40.0,
      'Transporte': 25.0,
      'Lazer': 15.0,
      'Moradia': 20.0,
    };

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categorias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4, // Espaço entre as seções
                  centerSpaceRadius:
                      40, // Raio do buraco no centro (para virar donut)
                  sections: _generateChartSections(categoryData),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            // TODO: Adicionar uma legenda para as categorias
          ],
        ),
      ),
    );
  }

  // Função auxiliar para gerar as seções do gráfico a partir dos dados
  List<PieChartSectionData> _generateChartSections(Map<String, double> data) {
    final colors = [
      const Color(0xFF023E8A), // Azul Escuro
      const Color(0xFF0096C7), // Azul Claro
      const Color(0xFFF77F00), // Laranja
      const Color(0xFFd90429), // Vermelho
    ];
    int colorIndex = 0;

    return data.entries.map((entry) {
      final section = PieChartSectionData(
        color: colors[colorIndex++ % colors.length],
        value: entry.value,
        title: '', // Título vazio para um visual minimalista
        radius: 50,
      );
      return section;
    }).toList();
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
