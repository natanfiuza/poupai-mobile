# Alterando o Nome e o Identificador (Domínio) de um App Flutter

Este guia mostra o método mais seguro e atual para alterar o nome de exibição e o identificador único de um aplicativo Flutter usando o pacote `rename`.

#### Conceitos Importantes:

  * **Nome da Aplicação:** O nome visível para o usuário (ex: "Poupaí").
  * **Identificador (Domínio):** O ID único do app nas lojas (ex: `br.com.poupai.app`), que segue o formato de domínio reverso.

-----

## Passo 1: Adicionar a Dependência de Desenvolvimento

Primeiro, adicionamos a ferramenta `rename` ao nosso projeto como uma dependência de desenvolvimento, pois ela nos auxilia durante a construção, mas não é incluída no app final.

**Instruções:**

1.  Abra um terminal na pasta raiz do seu projeto.

2.  Execute o seguinte comando para adicionar o pacote:

    ```bash
    dart pub add rename --dev
    ```

-----

## Passo 2: Executar os Comandos de Alteração

Com o pacote instalado, usamos dois comandos distintos para definir o nome e o identificador.

**Instruções:**

1.  **Para alterar o Nome da Aplicação:** Execute o comando abaixo, substituindo `"Poupaí"` pelo nome que desejar.

    ```bash
    dart run rename setAppName --value "Poupaí"
    ```

2.  **Para alterar o Identificador (Domínio):** Execute o segundo comando, substituindo pelo seu identificador único.

    ```bash
    dart run rename setBundleId --value "br.com.poupai.app"
    ```

Após executar cada comando, o pacote confirmará quais arquivos foram alterados com sucesso nas plataformas Android e iOS.

-----

## Passo 3: Verificar o Resultado

Para que as alterações tenham efeito e sejam visíveis, é crucial fazer uma reinstalação completa do aplicativo.

**Instruções:**

1.  **Desinstale completamente a versão anterior** do aplicativo do seu emulador ou dispositivo físico. Este passo é muito importante para limpar o cache do sistema.

2.  Execute o aplicativo novamente a partir do seu editor de código ou pelo terminal:

    ```bash
    flutter run
    ```

3.  Após a instalação, vá para a tela inicial do dispositivo. Você deverá ver o ícone do seu aplicativo com o novo nome ("Poupaí") exibido corretamente.

-----

## Resumo

Pronto\! Com este guia atualizado, você tem o método correto e mais recente para definir a identidade oficial do seu aplicativo Flutter. Este processo garante que todos os arquivos de configuração nativos sejam alterados de forma segura e consistente.