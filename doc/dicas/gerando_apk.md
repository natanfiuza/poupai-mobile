# Tutorial: Gerando um APK para Testes no Flutter

Existem dois tipos principais de APKs que você pode gerar: **Debug** e **Release**.

  * **Debug APK:** É mais fácil de gerar, maior em tamanho, inclui informações de depuração e não requer configuração complexa de assinatura. **Ideal para testes rápidos e desenvolvimento.**
  * **Release APK:** É otimizado, menor e precisa ser assinado com uma chave de lançamento. É o tipo de APK que você eventualmente enviaria para a Google Play Store.

Para instalar em um celular para testes, um **Debug APK** geralmente é o mais simples e suficiente.

### Passo 1: Prepare seu Ambiente

1.  **Verifique sua Configuração Flutter:**
    Abra o terminal e rode `flutter doctor`. Certifique-se de que não há problemas críticos, especialmente na seção "Android toolchain".
2.  **Navegue até a Pasta do Projeto:**
    No terminal, certifique-se de que você está na pasta raiz do seu projeto Cultivve Gestão.

### Passo 2: Escolha o Ambiente de Build (Usando `.env` e `--dart-define`)

Se você configurou seu aplicativo para usar diferentes arquivos `.env` para diferentes ambientes (como discutimos, ex: `.env.development`, `.env.staging`, `.env.production`) usando a flag `--dart-define=ENVIRONMENT=<nome_do_ambiente>`, você vai querer especificar qual ambiente usar para este APK de teste.

Por exemplo, se você tem um `.env.staging` para um ambiente de teste/homologação:

  * A variável a ser passada seria `ENVIRONMENT=staging`.

### Passo 3: Gerando um Debug APK

Este APK é assinado com uma chave de debug padrão do Android SDK, facilitando a instalação para testes.

1.  **Abra o Terminal** na raiz do seu projeto.

2.  **Execute o Comando:**

    ```bash
    flutter build apk --debug 
    ```

      * Se você estiver usando a flag `--dart-define` para carregar um arquivo `.env` específico (como `.env.staging`):
        ```bash
        flutter build apk --debug --dart-define=ENVIRONMENT=staging
        ```
        Substitua `staging` pelo nome do ambiente que você deseja usar para este APK de teste. Se você não usar `--dart-define`, ele usará o `defaultValue` que você configurou no `main.dart` para a variável `ENVIRONMENT` (que geralmente definimos como `development`, carregando `.env.development`).

3.  **Aguarde a Compilação:** O Flutter vai compilar seu código Dart e os assets, e então o Gradle construirá o APK. Isso pode levar alguns minutos, especialmente na primeira vez.

4.  **Localize o APK Gerado:**
    Após a conclusão, o Flutter mostrará o caminho para o APK gerado. Geralmente, ele estará em:
    `build/app/outputs/flutter-apk/app-debug.apk`

      * `build/`: É uma pasta na raiz do seu projeto.
      * `app-debug.apk`: Este é o arquivo que você precisa.

### Passo 4: Gerando um Release APK (Alternativa para Testes Mais Próximos da Produção)

Se você quiser testar um APK mais próximo do que seria enviado para a loja (otimizado e menor), você pode gerar um Release APK. **No entanto, isso requer que você configure a assinatura do aplicativo.**

1.  **Configure a Assinatura do Aplicativo:**

      * Isso envolve criar um "keystore" (um arquivo que contém suas chaves de assinatura).
      * Configurar o arquivo `android/key.properties` com as informações do keystore.
      * Ajustar o arquivo `android/app/build.gradle` para usar essas informações de assinatura para builds de release.
      * **Referência Oficial:** Siga o guia detalhado do Flutter sobre como assinar seu app: [Build and release an Android app - Flutter documentation](https://www.google.com/search?q=https://docs.flutter.dev/deployment/android%23signing-the-app)

2.  **Execute o Comando de Build (após configurar a assinatura):**

    ```bash
    flutter build apk --release
    ```

      * Ou com `--dart-define` para um ambiente específico:
        ```bash
        flutter build apk --release --dart-define=ENVIRONMENT=production 
        ```

3.  **Localize o APK Gerado:**
    Geralmente em:
    `build/app/outputs/flutter-apk/app-release.apk`

    *Se você não configurar a assinatura corretamente, o comando `flutter build apk --release` pode falhar ou gerar um APK que não pode ser instalado ou atualizado corretamente.*

### Passo 5: Instalando o APK no seu Celular Android

1.  **Permitir Fontes Desconhecidas:**

      * No seu celular Android, você precisa permitir a instalação de aplicativos de "fontes desconhecidas". Essa opção geralmente está em:
          * `Configurações > Segurança`
          * Ou `Configurações > Aplicativos > Acesso especial a apps > Instalar apps desconhecidos` (o caminho pode variar um pouco dependendo da versão do Android e do fabricante).
      * Você precisará dar essa permissão para o aplicativo "Gerenciador de Arquivos" ou para o navegador que você usará para abrir o APK.

2.  **Transfira o Arquivo APK para o Celular:**

      * **Cabo USB:** Conecte seu celular ao computador via cabo USB. Copie o arquivo `.apk` (ex: `app-debug.apk`) do seu computador para uma pasta no seu celular (ex: pasta "Downloads").
      * **Outros Métodos:** Você também pode usar Google Drive, Dropbox, e-mail, WhatsApp, etc., para transferir o arquivo para o celular.

3.  **Instale o APK:**

      * No seu celular, use um aplicativo "Gerenciador de Arquivos" para navegar até a pasta onde você salvou o APK.
      * Toque no arquivo `.apk`. O sistema Android perguntará se você deseja instalar o aplicativo.
      * Confirme a instalação.

4.  **Alternativa (via ADB - Android Debug Bridge):**

      * Se você tem o ADB configurado no seu computador e o celular está conectado via USB com a depuração USB ativada:
        1.  Abra o terminal no seu computador.
        2.  Navegue até a pasta onde o APK foi gerado (ex: `build/app/outputs/flutter-apk/`).
        3.  Execute o comando:
            ```bash
            adb install app-debug.apk 
            ```
            (Ou `app-release.apk` se for o caso).

### Dica: APKs Divididos por Arquitetura (`--split-per-abi`)

Por padrão, `flutter build apk` (especialmente para release) pode gerar um "fat APK" que contém código para múltiplas arquiteturas de CPU (ARM, ARM64, x86, etc.), tornando o arquivo maior. Para testes, isso geralmente não é um problema.

Se você precisar de APKs menores para distribuição ou testes mais específicos, pode usar a flag `--split-per-abi`:

```bash
flutter build apk --debug --split-per-abi --dart-define=ENVIRONMENT=development
flutter build apk --debug --split-per-abi --dart-define=ENVIRONMENT=staging
flutter build apk --release --split-per-abi --dart-define=ENVIRONMENT=production
```

Isso gerará múltiplos APKs menores, cada um para uma arquitetura específica (ex: `app-armeabi-v7a-debug.apk`, `app-arm64-v8a-debug.apk`). Você então instalaria o APK correspondente à arquitetura do seu dispositivo de teste. Para a maioria dos celulares modernos, `arm64-v8a` é o mais comum.

-----

Para seus testes iniciais, Natan, recomendo começar com o **Debug APK** (`flutter build apk --debug`), pois é o mais simples de gerar e instalar. Lembre-se de usar o `--dart-define` se precisar apontar o app para um backend de teste específico\!