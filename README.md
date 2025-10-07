# Pandora Snap

* **Em criação por:** Maurice Golin Soares dos Santos
* Este projeto é um aplicativo desenvolvido para a comunidade da UTFPR, com o objetivo de facilitar a coleta de fotos dos cães do campus. 
* Usuários poderão capturar imagens dos cães, contribuindo para um banco de dados que será utilizado em futuras pesquisas e projetos.

### Atividades Desenvolvidas

* Desenvolvimento full-stack do aplicativo.
* Estruturação do projeto e arquitetura.
* Implementação da interface de usuário (UI).
* Configuração e integração com o Supabase (banco de dados e autenticação).
* Gerenciamento de estado com Provider e navegação com Go Router.
* Implementação das funcionalidades de câmera, galeria, e visualização de fotos.

### Melhorias Restantes

* **Redirecionamento de Login Inválido:** Quando o usuário insere credenciais de login inválidas, ele é redirecionado para a tela de boas-vindas (`welcome_screen`), em vez de permanecer na tela de login.
* **Deletar Imagens do Storage do Supabase:** Ao deletar as imagens no aplicativo, elas são removidas apenas da Base de Dados do Supabase, mas elas continuam no Storage, em vez de também ser removida.

* **Cache Local de Imagens:** Adicionar um sistema de cache local para as imagens. Isso, combinado com o uso do `notifyListeners` do Provider, irá agilizar a exibição de novas fotos na galeria do usuário.
* **Servidor Local para Edge Impulse:**  A integração com os servidores do Edge Impulse foi implementada de forma apenas local, sendo necessário um possível deploy em uma ferramenta de hosting.

* **Reportar Novos Cães:** Implementar uma funcionalidade que permita aos usuários reportar a presença de um novo cão na universidade.
