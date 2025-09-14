# **Plano de Implementação: Suporte Offline com SQLite**

**Objetivo:** Permitir que os dados do utilizador e das transações sejam armazenados localmente, possibilitando o uso da aplicação mesmo sem conexão com a internet.

---

### **Fase 1: 🏛️ Fundação - Configuração do Banco de Dados**

Nesta fase, adicionaremos as ferramentas necessárias e criaremos a classe que irá gerir o nosso banco de dados.

* **Passo 1.1: Adicionar Dependências:**
    * Adicionar os pacotes `sqflite` e `path_provider` ao `pubspec.yaml`. O `sqflite` é a biblioteca para interagir com o SQLite, e o `path_provider` ajuda-nos a encontrar o local correto no sistema de ficheiros do dispositivo para guardar o banco de dados.

* **Passo 1.2: Criar o `DatabaseHelper`:**
    * Criar uma classe singleton chamada `DatabaseHelper` (ex: `lib/services/database_helper.dart`).
    * Esta classe será a única responsável por todas as operações do banco de dados (abrir, criar tabelas, inserir, consultar, etc.).
    * Implementar o método `_initDatabase()` para criar e/ou abrir o ficheiro do banco de dados (`poupai.db`).
    * Implementar o método `_onCreate()` que será executado apenas uma vez, na primeira vez que a aplicação for aberta. É aqui que definiremos o esquema inicial do banco de dados com `CREATE TABLE`.

---

### **Fase 2: 📝 Modelagem e Integração dos Dados**

Agora que temos o "gestor" do banco de dados, vamos definir as "prateleiras" (tabelas) e as operações para guardar e ler os dados.

* **Passo 2.1: Definir o Esquema das Tabelas:**
    * No método `_onCreate()` do `DatabaseHelper`, criaremos as tabelas iniciais:
        * **`user`:** Para guardar os dados do utilizador logado (uuid, nome, e-mail, photoUrl). Só haverá sempre uma linha nesta tabela.
        * **`session`:** Uma tabela simples para guardar o token de autenticação.

* **Passo 2.2: Implementar as Operações CRUD (Create, Read, Update, Delete):**
    * Criar métodos no `DatabaseHelper` para cada operação que precisaremos inicialmente:
        * `saveUser(UserModel user)`: Insere ou atualiza os dados do utilizador na tabela `user`.
        * `getUser()`: Lê os dados do utilizador da tabela `user`.
        * `saveToken(String token)`: Guarda o token na tabela `session`.
        * `getToken()`: Lê o token da tabela `session`.
        * `clearAllTables()`: Limpa todos os dados das tabelas (será usado no logout).

---

### **Fase 3: 🔄 Refatoração do Fluxo de Autenticação**

Com o banco de dados pronto para guardar e fornecer dados, vamos alterar a lógica de autenticação para que ela priorize o banco de dados local.

* **Passo 3.1: Modificar o `AuthService`:**
    * O `AuthService` continuará a ser o responsável por comunicar com a API.
    * Nos métodos `login` e `register`, após uma resposta bem-sucedida da API, os dados do utilizador e o token recebidos serão guardados no banco de dados local através do `DatabaseHelper`, em vez de no `flutter_secure_storage`.

* **Passo 3.2: Modificar o `AuthProvider` (A Lógica "Offline-First"):**
    * O `AuthProvider` será alterado para ler os dados *primeiro* do banco de dados local.
    * No método `checkAuthStatus` (que é chamado quando a aplicação inicia), a lógica será:
        1.  Tentar carregar o utilizador e o token do `DatabaseHelper`.
        2.  Se encontrar dados, o estado da aplicação é imediatamente definido como "autenticado", permitindo que o utilizador aceda à `HomeScreen` instantaneamente, mesmo offline.
    * O método `logout` irá agora chamar `DatabaseHelper.clearAllTables()` para limpar a sessão local.

---

### **Fase 4: 🌐 Estratégia de Sincronização (Visão de Futuro)**

Esta fase define como iremos lidar com os dados criados offline quando a aplicação voltar a ter internet.

* **Passo 4.1: Adaptar os Modelos de Dados:**
    * Quando criarmos a tabela de transações (`transactions`), ela precisará de colunas extras para controlar o estado de sincronização, como `isSynced` (booleano) e `lastModified` (timestamp).

* **Passo 4.2: Criar um `SyncService`:**
    * Este serviço será responsável por:
        1.  Verificar se há conexão com a internet.
        2.  Encontrar todos os registos locais marcados como `isSynced = false`.
        3.  Enviar esses registos para a API do back-end.
        4.  Após a confirmação do servidor, marcar os registos como `isSynced = true` no banco de dados local.
        5.  Descarregar quaisquer novas informações que possam ter sido criadas noutras plataformas (como a aplicação web).

