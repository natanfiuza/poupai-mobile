# **Guia Rápido: Corrigindo o Erro No MaterialLocalizations found**

Para que os componentes do Flutter, como o calendário, apareçam em português, precisamos configurar a localização em todo o aplicativo.

#### **Passo 1: Adicionar o Pacote de Localização**

Primeiro, precisamos adicionar o pacote flutter\_localizations ao seu projeto. Ele contém as traduções para os widgets padrão do Material e Cupertino.

**Ação:** Abra seu arquivo pubspec.yaml e adicione a seguinte linha dentro da seção dependencies:

dependencies:  
  flutter:  
    sdk: flutter  
    
  \# ADICIONE A LINHA ABAIXO JUNTO COM SUAS OUTRAS DEPENDÊNCIAS  
  flutter\_localizations:   
    sdk: flutter

  \# ... suas outras dependências (cupertino\_icons, dio, etc.) ...

Depois de adicionar a linha, **salve o arquivo** e execute o seguinte comando no seu terminal para instalar o pacote:

flutter pub get

#### **Passo 2: Configurar o MaterialApp**

Agora, vamos dizer ao seu MaterialApp para usar as traduções em português do Brasil.

**Ação:** No seu arquivo lib/main.dart, vamos adicionar as propriedades localizationsDelegates e supportedLocales ao widget MaterialApp.

Abaixo está o código completo e corrigido para o seu main.dart.