import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/app_colors.dart';
import 'screens/splash_screen.dart'; 
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';


Future<void> main() async {
  // Garante que os bindings do Flutter foram inicializados antes de carregar o .env
  WidgetsFlutterBinding.ensureInitialized();

  // Define o ambiente com base no que foi passado na compilação, padrão 'development'
  const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // Carrega o arquivo .env correspondente
  await dotenv.load(fileName: ".env.$environment");

  // Inicializa a formatação de data para o padrão pt_BR
  await initializeDateFormatting('pt_BR', null);
  
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, TransactionProvider>(
          // Cria a instância inicial do TransactionProvider
          create: (context) => TransactionProvider(),
          // A função 'update' é chamada sempre que o AuthProvider notifica uma mudança
          update: (context, authProvider, previousTransactionProvider) {
            // Passamos o AuthProvider para o TransactionProvider
            return previousTransactionProvider!..update(authProvider);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TransactionProvider>(
          // Cria a instância inicial do TransactionProvider
          create: (context) => TransactionProvider(),
          // A função 'update' é chamada sempre que o AuthProvider notifica uma mudança
          update: (context, authProvider, previousTransactionProvider) {
            // Passamos o AuthProvider para o TransactionProvider
            return previousTransactionProvider!..update(authProvider);
          },
        ),
      ],
      child: const PoupaiApp(),
    ),
    );
}

class PoupaiApp extends StatelessWidget {
  const PoupaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poupaí',
      debugShowCheckedModeBanner: false,

      // Configuração de localização para Português (Brasil)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), 
      ],
      locale: const Locale('pt', 'BR'),

      // Tema global da aplicação
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        fontFamily: 'Inter', // Usando a fonte definida na identidade visual

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          iconTheme: IconThemeData(color: AppColors.cardBackground),
          titleTextStyle: TextStyle(
            color: AppColors.cardBackground,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(AppColors.primaryColor),
            foregroundColor: MaterialStateProperty.all(AppColors.cardBackground),
            textStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 14.0, horizontal: 28.0),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardBackground,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primaryColor, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.errorColor, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      // home: const SplashScreen(), // Descomente quando a tela de splash existir
      // Tela provisória enquanto não criamos a splash screen
       home: const SplashScreen(),
    );
  }
}