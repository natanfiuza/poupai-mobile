# Como configurar o icone da aplicação

Existe uma forma muito mais fácil e profissional de fazer isso usando um pacote que automatiza todo o processo. Vamos usar o pacote mais popular para isso, o flutter_launcher_icons.

Aqui está um guia passo a passo completo.


## Pré-requisito: A Imagem do Ícone

Antes de começarmos, você precisa ter a imagem que será o seu ícone.

  * **Formato:** PNG é o mais recomendado.
  * **Dimensões:** Deve ser um quadrado perfeito. O ideal é ter uma resolução alta, como **1024x1024 pixels**, para que o pacote possa redimensioná-la para todos os tamanhos necessários sem perder qualidade.
  * **Transparência:** O arquivo PNG pode ter fundo transparente. O Android irá lidar com isso (especialmente para os ícones adaptativos).

-----

## Passo 1: Adicionar a Dependência ao Projeto

Primeiro, vamos adicionar o pacote `flutter_launcher_icons` como uma "dependência de desenvolvimento". Isso significa que ele é uma ferramenta para nos ajudar a construir o app, mas não fará parte do código final do aplicativo.

**Instruções:**

1.  Abra o terminal na pasta raiz do seu projeto (`poupai_mobile`).

2.  Execute o seguinte comando:

    ```bash
    flutter pub add flutter_launcher_icons --dev
    ```

Isso adicionará o pacote na seção `dev_dependencies` do seu arquivo `pubspec.yaml`.

-----

## Passo 2: Preparar a Imagem do Ícone

Agora, vamos colocar a sua imagem de ícone no projeto, em um lugar organizado.

**Instruções:**

1.  Na raiz do seu projeto, crie uma pasta chamada `assets` (se ainda não existir).
2.  Dentro de `assets`, crie outra pasta chamada `icon`.
3.  Coloque o seu arquivo de imagem (ex: `icon.png`) dentro da pasta `assets/icon/`.

Sua estrutura ficará assim:

```
poupai_mobile/
├── assets/
│   └── icon/
│       └── icon.png  <-- SUA IMAGEM DE ALTA RESOLUÇÃO
└── lib/
└── ...
```

-----

## Passo 3: Configurar o Pacote no `pubspec.yaml`

Precisamos dizer ao pacote onde encontrar sua imagem e como ele deve gerar os ícones.

**Instruções:**

1.  Abra o arquivo `pubspec.yaml`.

2.  Adicione a seguinte seção no final do arquivo. **Preste muita atenção à indentação** (use dois espaços, não tabs).

    ```yaml
    # Adicione esta seção ao seu pubspec.yaml
    flutter_launcher_icons:
      # Configuração para Android
      android: "launcher_icon"
      
      # Configuração para iOS (true para habilitar)
      ios: true
      
      # Caminho para a sua imagem principal
      image_path: "assets/icon/icon.png"
      
      # Opcional: Necessário para gerar Ícones Adaptativos no Android
      # Ícones adaptativos permitem que o ícone mude de forma (círculo, quadrado, etc.)
      min_sdk_android: 21 
    ```

**Documentação Rápida:**

  * `android: "launcher_icon"`: Define o nome do ícone para Android. Você pode deixar o padrão.
  * `ios: true`: Habilita a geração de ícones para iOS.
  * `image_path:`: O caminho para a sua imagem-mestra que acabamos de adicionar.
  * `min_sdk_android: 21`: Se você quer que seu app tenha ícones adaptativos no Android (altamente recomendado), você precisa especificar a SDK mínima como 21 ou superior.

-----

## Passo 4: Executar o Pacote para Gerar os Ícones

Com tudo configurado, agora vem a mágica. Vamos executar um comando que irá ler essas configurações e gerar todos os arquivos de ícone necessários.

**Instruções:**

1.  No seu terminal, na raiz do projeto, execute o seguinte comando:

    ```bash
    flutter pub run flutter_launcher_icons
    ```

2.  Você verá uma série de mensagens no terminal indicando que os ícones para Android e iOS estão sendo gerados e substituídos.

**O que este comando faz?**
Ele pega sua imagem de `assets/icon/icon.png` e cria todas as versões necessárias (`hdpi`, `xhdpi`, `xxhdpi`, etc., para Android, e o `AppIcon.appiconset` para iOS), colocando-as automaticamente nos locais corretos dentro das pastas `android` e `ios` do seu projeto.

-----

## Passo 5: Verificar e Executar o App

Para ver o resultado, você precisa reinstalar o aplicativo no seu emulador ou dispositivo.

**Instruções:**

1.  Execute seu aplicativo normalmente:
    ```bash
    flutter run
    ```
2.  Após a instalação, saia do aplicativo e vá para a tela inicial do seu celular ou emulador. Você deverá ver o novo ícone do "Poupaí"\!

**Dica:** Se o ícone não atualizar, especialmente em um dispositivo físico, tente desinstalar a versão antiga do app manualmente e depois executar o `flutter run` novamente. Às vezes, o sistema operacional mantém o ícone antigo em cache.

## Resumo

Parabéns\! Com um único pacote e um comando, você alterou o ícone do seu aplicativo para todas as plataformas, economizando um tempo enorme e garantindo um resultado profissional.