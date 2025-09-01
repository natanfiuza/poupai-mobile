# Configurando a versão do NDK

### O que é o NDK? 🧠

O **Android NDK (Native Development Kit)** é um conjunto de ferramentas que permite que partes de um aplicativo Android sejam escritas em linguagens nativas como C e C++.

Alguns plugins do Flutter, como o `flutter_secure_storage` que você está usando, utilizam código nativo para otimizar o desempenho ou acessar recursos de baixo nível do sistema. O aviso aparece porque seu projeto está configurado para usar uma versão mais antiga do NDK (26.x) do que a que seus plugins precisam (27.x). A solução é simplesmente atualizar a versão no seu projeto.

-----

## Passo a Passo para a Correção ✅

Siga estes passos para aplicar a correção que o próprio Flutter recomendou.

### 1\. Localize o Arquivo 📂

Abra seu projeto no VS Code ou Android Studio e navegue até o arquivo correto no seguinte caminho:

```
poupai_mobile/
└── android/
    └── app/
        └── build.gradle.kts  <-- É ESTE ARQUIVO
```

### 2\. Edite o Arquivo ✏️

Abra o arquivo `build.gradle.kts`. Você verá um bloco de código que começa com `android { ... }`. Você precisa adicionar a linha `ndkVersion = "27.0.12077973"` dentro deste bloco.

Procure pela seção `android { ... }` que se parece com isto:

```kotlin
// Exemplo do que você pode encontrar no arquivo
android {
    namespace = "br.app.poupai"
    compileSdk = flutter.compileSdkVersion
    // ... outras configurações
}
```

Agora, adicione a linha recomendada em qualquer lugar dentro desse bloco `android`. Uma boa posição é logo após a linha `compileSdk`.

**O código final deve ficar assim:**

```kotlin
android {
    namespace = "br.app.poupai"
    compileSdk = flutter.compileSdkVersion

    // ADICIONE ESTA LINHA AQUI
    ndkVersion = "27.0.12077973" 

    // ... o resto das configurações
}
```

### 3\. Salve e Reinicie ▶️

1.  **Salve** o arquivo `build.gradle.kts`.
2.  **Pare completamente** a execução do seu aplicativo, se ele ainda estiver rodando.
3.  **Execute o aplicativo novamente** com o comando `flutter run`.

Pronto\! O aviso do NDK não deve mais aparecer, e seu projeto estará corretamente configurado para usar a versão que seus plugins necessitam.