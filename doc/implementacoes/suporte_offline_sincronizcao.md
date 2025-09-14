# **Plano de Implementação: Fase 4 - Estratégia de Sincronização**

**Objetivo:** Permitir que o utilizador crie, edite e apague transações financeiras offline e que essas alterações sejam sincronizadas com o servidor de forma segura e consistente quando a aplicação estiver online.

---

### **Parte 1: Modificações na Base de Dados Local**

Para que a sincronização funcione, as nossas tabelas na base de dados SQLite precisam de mais informações. Usaremos a futura tabela `transactions` como exemplo.

* **1.1. Novas Colunas na Tabela `transactions`:**
    Além das colunas de dados (descrição, valor, categoria, etc.), adicionaremos colunas de controlo:
    * **`uuid` (TEXT NOT NULL UNIQUE):** Um identificador único universal. Quando uma transação for criada localmente, geraremos um UUID. Este mesmo UUID será enviado para o servidor, garantindo que o registo seja o mesmo em ambos os locais e evitando duplicados.
    * **`syncStatus` (TEXT NOT NULL):** Um campo de texto para controlar o estado do registo. Terá um dos seguintes valores:
        * `'new'`: Criado localmente, precisa de ser enviado para o servidor.
        * `'edited'`: Um registo existente foi modificado localmente e precisa de ser atualizado no servidor.
        * `'synced'`: O registo está sincronizado com o servidor.
        * `'deleted'`: Um registo foi marcado para ser apagado localmente e a exclusão precisa de ser comunicada ao servidor.
    * **`lastModified` (INTEGER NOT NULL):** Um carimbo de data/hora (timestamp) que regista a última vez que o registo foi alterado no dispositivo. Isto é vital para a resolução de conflitos.

---

### **Parte 2: O Serviço de Sincronização (`SyncService`)**

Criaremos uma nova classe, `SyncService`, cuja única responsabilidade será gerir o processo de sincronização.

* **2.1. Gatilhos da Sincronização (Quando Sincronizar?):**
    A sincronização será acionada automaticamente nos seguintes momentos:
    1.  **Ao Iniciar a Aplicação:** Se houver conexão com a internet, a primeira coisa que a aplicação fará é tentar sincronizar.
    2.  **Ao Retomar a Conexão:** A aplicação irá monitorizar o estado da rede. Assim que a conexão for restabelecida, o processo de sincronização será iniciado. (Usaremos um pacote como o `connectivity_plus` para isto).

* **2.2. O Processo de Sincronização (Como Sincronizar?):**
    O `SyncService` seguirá um fluxo de duas vias:

    **A. Upload de Alterações Locais (Dispositivo -> Servidor):**
    1.  O serviço irá procurar na base de dados local por todos os registos com `syncStatus` diferente de `'synced'`.
    2.  Para cada registo encontrado:
        * Se o status for `'new'`, fará um pedido `POST` para a API.
        * Se o status for `'edited'`, fará um pedido `PUT` ou `PATCH`.
        * Se o status for `'deleted'`, fará um pedido `DELETE`.
    3.  Após cada pedido bem-sucedido, o serviço atualizará o `syncStatus` do registo local para `'synced'`.

    **B. Download de Alterações Remotas (Servidor -> Dispositivo):**
    1.  Após o upload das alterações locais, a aplicação precisa de obter quaisquer dados que tenham sido alterados noutras plataformas (como na aplicação web).
    2.  O `SyncService` fará um pedido `GET` à API, pedindo todos os registos que foram atualizados desde a última sincronização bem-sucedida. (Ex: `GET /api/transactions?since={timestamp_da_ultima_sincronizacao}`).
    3.  A aplicação irá percorrer os dados recebidos do servidor e fará um "upsert" (insere se for novo, atualiza se já existir, usando o `uuid` como chave) na base de dados local, marcando estes registos como `'synced'`.
    4.  No final, a aplicação guarda o `timestamp` desta sincronização para usar no próximo pedido.

---

### **Parte 3: Estratégia para Resolução de Conflitos**

Este é um ponto importante a ser considerado. O que acontece se um utilizador editar uma transação offline e, ao mesmo tempo, essa mesma transação for alterada na web?

* **Estratégia "Last Write Wins" (A Última Escrita Vence):**
    Esta é a abordagem mais simples e comum. Tanto o cliente (aplicação) quanto o servidor irão comparar o carimbo de data/hora `lastModified`. A versão do registo com o carimbo de data/hora mais recente irá sobrepor-se à mais antiga. Esta regra precisa de ser implementada de forma consistente tanto na aplicação quanto na API do back-end.

