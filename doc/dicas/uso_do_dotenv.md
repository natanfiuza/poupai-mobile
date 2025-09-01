# Duvidas sobre o uso do dotenv

### 1. Qual `.env` o VS Code usa ao rodar com F5 (ou Alt+F5) e como configurar?

Por padrão, se você usar `await dotenv.load();` ou `await dotenv.load(fileName: ".env");` no seu `main.dart`, o `flutter_dotenv` vai procurar por um arquivo chamado exatamente `.env` na raiz do seu projeto quando você rodar o app, independentemente de como o iniciou (F5, terminal, etc.).

**Para ter flexibilidade e escolher qual arquivo `.env` carregar (ex: `.env.development`, `.env.production`) ao rodar pelo VS Code (com F5), você não precisará rodar o comando manualmente no terminal toda vez.** A maneira correta é configurar o arquivo `launch.json` do VS Code.

**Como configurar o `launch.json`:**

1.  **Crie/Abra o `launch.json`:**
    * No VS Code, vá para a aba "Run and Debug" (Executar e Depurar - geralmente um ícone de play com um bug).
    * Se você não tiver um `launch.json`, clique em "create a launch.json file" e escolha "Dart & Flutter". Isso criará um arquivo `.vscode/launch.json` no seu projeto.

2.  **Defina Configurações de Inicialização:**
    Você pode criar múltiplas configurações, uma para cada ambiente. A estratégia que sugeri anteriormente (usar `--dart-define` para passar o nome do ambiente) funciona muito bem aqui.

    Exemplo de `.vscode/launch.json`:
    ```json
    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Cultivve (Development)", // Nome que aparecerá na lista de debug
                "request": "launch",
                "type": "dart",
                "flutterMode": "debug",
                "args": [
                    "--dart-define=ENVIRONMENT=development" // Passa a variável de ambiente
                ]
            },
            {
                "name": "Cultivve (Production)",
                "request": "launch",
                "type": "dart",
                "flutterMode": "release", // Ou "profile" para testar performance
                "args": [
                    "--dart-define=ENVIRONMENT=production"
                ]
            },
            {
                "name": "Cultivve (Staging)", // Exemplo de um terceiro ambiente
                "request": "launch",
                "type": "dart",
                "flutterMode": "debug", // Ou profile
                "args": [
                    "--dart-define=ENVIRONMENT=staging"
                ]
            }
        ]
    }
    ```

3.  **Adapte seu `main.dart` para usar a variável `ENVIRONMENT`:**
    Como sugeri antes, seu `main.dart` carregaria o arquivo `.env` correspondente:
    ```dart
    // lib/main.dart
    import 'package:flutter/material.dart';
    import 'package:flutter_dotenv/flutter_dotenv.dart';

    Future<void> main() async {
      WidgetsFlutterBinding.ensureInitialized();

      // Lê a variável de ambiente 'ENVIRONMENT' definida pelo --dart-define
      // O valor padrão é 'development' se nenhuma variável for passada
      const String environment = String.fromEnvironment(
        'ENVIRONMENT',
        defaultValue: 'development',
      );

      // Carrega o arquivo .env correspondente ao ambiente
      // Ex: .env.development, .env.production, .env.staging
      await dotenv.load(fileName: ".env.$environment"); 
      // Certifique-se de ter os arquivos: .env.development, .env.production, .env.staging na raiz do projeto.

      runApp(const MyApp());
    }
    // ...
    ```

4.  **Rodando com F5:**
    * Agora, na aba "Run and Debug" do VS Code, você verá um menu dropdown no topo (geralmente ao lado do botão de play verde). Lá você poderá selecionar qual configuração usar: "Cultivve (Development)", "Cultivve (Production)", etc.
    * Escolha a configuração desejada e pressione F5 (ou clique no play). O VS Code passará o `--dart-define` correspondente, e seu app carregará o arquivo `.env` correto.

Assim, você não precisa digitar o comando no terminal toda vez.

---

### 2. Geração de APK e arquivos `.env`

* **O `.env` vai junto no APK?**
    * **Não, e não deveria.** Os arquivos `.env` (ex: `.env.development`, `.env.production`) **não são e não devem ser incluídos/empacotados diretamente no seu APK ou App Bundle.** Eles contêm as configurações para o seu *ambiente de desenvolvimento e compilação*.
    * O que acontece é que o pacote `flutter_dotenv` lê o arquivo `.env` especificado *durante a inicialização do seu aplicativo em Dart* (no `main.dart`). Os valores lidos (como `BASE_URL`, `API_KEY`) são então carregados na memória do aplicativo (no objeto `dotenv.env`). Seu código Dart (ex: `AppConfig.baseUrl`) então acessa esses valores da memória.
    * **É crucial que você adicione `.env*` ao seu arquivo `.gitignore`** para garantir que esses arquivos, especialmente se contiverem chaves de API de produção ou outros segredos, não sejam enviados para o seu repositório Git.

* **Tem um comando para compilar usando o `.env` que eu quero?**
    * Sim! A mesma estratégia usada no `launch.json` com `--dart-define` se aplica aos comandos de build.
    * Seu `main.dart` já está configurado para carregar `.env.$ENVIRONMENT` baseado na variável `ENVIRONMENT`. Então, para compilar para um ambiente específico:

        * **Para gerar um APK de Produção (usando `.env.production`):**
            ```bash
            flutter build apk --release --dart-define=ENVIRONMENT=production
            ```
            (O `--release` é para otimizar o build para produção)

        * **Para gerar um APK de Desenvolvimento (usando `.env.development`):**
            ```bash
            flutter build apk --debug --dart-define=ENVIRONMENT=development
            ```
            (O `--debug` é para um build de depuração)

        * **Para App Bundles (recomendado para Play Store):**
            ```bash
            flutter build appbundle --release --dart-define=ENVIRONMENT=production
            ```

    * Quando o aplicativo gerado por esses comandos for instalado e iniciado no dispositivo, o código em `main.dart` lerá a variável `ENVIRONMENT` que foi "embutida" no momento da compilação e carregará as configurações do arquivo `.env.$ENVIRONMENT` correspondente que *você tem localmente no seu ambiente de desenvolvimento/build*. As *configurações* são carregadas, não o arquivo em si.

**Em Resumo:**

* Use `launch.json` no VS Code com `--dart-define=ENVIRONMENT=<nome_do_ambiente>` para selecionar qual `.env.<nome_do_ambiente>` seu app carrega ao rodar com F5.
* Os arquivos `.env` **não são incluídos no APK**. O app carrega os *valores* deles na memória em tempo de execução.
* Use `flutter build <tipo> --dart-define=ENVIRONMENT=<nome_do_ambiente>` para compilar seu app (APK, App Bundle, IPA) com as configurações do ambiente desejado.

Essa abordagem combinada (`flutter_dotenv` + `--dart-define` para selecionar o ambiente) é bastante robusta e flexível para gerenciar suas configurações!