# Pandora Snap

* **Autor:** Maurice Golin Soares dos Santos

### Sobre o Projeto

O Pandora Snap é um aplicativo full-stack desenvolvido para a comunidade da UTFPR, com o objetivo de facilitar a coleta de fotos dos cães do campus. Utilizadores podem capturar e enviar imagens dos cães, contribuindo para um banco de dados que será utilizado em futuras pesquisas e projetos de monitoramento.

### Funcionalidades Implementadas

- **Autenticação de Utilizadores:** Sistema de login e registo com confirmação por e-mail via Supabase.
- **Câmera Integrada:** Funcionalidade de câmera para tirar fotos diretamente na aplicação.
- **Marcação de Imagens:** Ferramenta para desenhar uma caixa de marcação (`bounding box`) ao redor do cão na foto.
- **Galeria Pessoal:**
    - **Coleção:** Visualização de todos os cães, destacando os que já foram capturados pelo utilizador.
    - **Calendário:** Navegação mensal para ver os dias em que foram tiradas fotos.
- **Visualização Detalhada:** Grades de fotos por cão ou por dia, com visualização em ecrã inteiro.
- **Gestão de Fotos:** O utilizador pode apagar as suas próprias fotos.

### Arquitetura e Tecnologias

- **Frontend (Mobile):**
    - **Framework:** Flutter & Dart
    - **Gestão de Estado:** Provider
    - **Navegação:** Go Router

- **Backend (BaaS):**
    - **Plataforma:** Supabase
    - **Serviços:** Autenticação, Base de Dados (PostgreSQL) e Storage.

- **Servidor de Análise (Backend Secundário):**
    - **Linguagem:** Python com Flask
    - **Funcionalidade:** Recebe as imagens e metadados, e utiliza o **Playwright** para automatizar o processo de upload para o **Edge Impulse**.
    - **Hosting:** O servidor está publicado na nuvem através do **Google Cloud Run**, utilizando uma imagem **Docker**.

### Melhorias Futuras

- **Reportar Novos Cães:** Implementar uma funcionalidade que permita aos utilizadores reportar a presença de um novo cão na universidade.
- **Dashboard do Site:** Integrar a visualização da dashboard do comedouro dos cães diretamente na aplicação.