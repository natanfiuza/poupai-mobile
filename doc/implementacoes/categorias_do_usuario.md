# **Plano de Implementação: Carregamento e Gestão de Categorias**

**Objetivo:** Buscar as categorias de um utilizador a partir da API após o login/registo, guardá-las na base de dados SQLite local e usá-las dinamicamente na aplicação, como no ecrã de adicionar transações.

---
### **Fase 1: Preparação da Base de Dados e do Modelo de Dados**

Primeiro, precisamos de preparar a nossa aplicação para entender e armazenar os dados das categorias.

* **1.1. Criar o `CategoryModel`:**
    * Criaremos um novo arquivo `lib/models/category_model.dart`.
    * Esta classe irá representar uma categoria, com os campos `id`, `name`, `type`, `icon`, e `color`, correspondendo à estrutura do JSON.
    * Terá métodos `fromMap` (para ler da base de dados/JSON) e `toMap` (para gravar na base de dados).

* **1.2. Atualizar o `DatabaseHelper`:**
    * **Migração da Base de Dados:** Vamos aumentar a versão da base de dados (de 1 para 2) para acionar uma atualização.
    * **Nova Tabela:** Adicionaremos uma tabela `categories` ao nosso esquema SQLite para armazenar as categorias localmente.
    * **Novos Métodos:** Criaremos métodos no `DatabaseHelper` para gerir as categorias, como `saveCategories(List<CategoryModel> categories)` e `getCategories(String type)`.

---
### **Fase 2: Lógica de Negócios e Comunicação com a API**

Com a base de dados pronta, vamos criar a lógica para buscar e gerir o estado das categorias.

* **2.1. Criar o `CategoryService`:**
    * Criaremos um novo serviço em `lib/services/category_service.dart`.
    * Este serviço terá um método `fetchUserCategories()` que fará a chamada `GET` autenticada para o endpoint `/app/user/categories`, processará a resposta JSON e retornará uma lista de `CategoryModel`.

* **2.2. Criar o `CategoryProvider`:**
    * Criaremos um novo provider em `lib/providers/category_provider.dart`.
    * Este `ChangeNotifier` irá manter a lista de categorias em memória para acesso rápido pela UI.
    * Ele terá um método principal, `loadCategories()`, que irá:
        1.  Chamar o `CategoryService` para buscar as categorias da API.
        2.  Chamar o `DatabaseHelper` para guardar as categorias recebidas na base de dados local.
        3.  Carregar as categorias para o seu estado interno e notificar a UI.

---
### **Fase 3: Integração na Aplicação**

Finalmente, vamos ligar esta nova lógica ao fluxo existente da aplicação.

* **3.1. Acionar o Carregamento de Categorias:**
    * Modificaremos o `AuthProvider` nos métodos `login` e `register`. Após o sucesso da autenticação, ele irá acionar o `CategoryProvider.loadCategories()` para garantir que as categorias são sempre carregadas para um novo utilizador ou numa nova sessão.

* **3.2. Atualizar a Tela `AddTransactionScreen`:**
    * O `DropdownButtonFormField` de categorias, que atualmente usa uma lista fixa de strings, será alterado.
    * Ele passará a consumir a lista de `CategoryModel` do `CategoryProvider`, filtrando entre 'expense' (despesa) e 'receipt' (receita) com base na seleção do utilizador.

* **3.3. Adicionar o `CategoryProvider` em `main.dart`:**
    * Adicionaremos o novo `CategoryProvider` ao `MultiProvider` para que ele fique disponível em toda a aplicação.

