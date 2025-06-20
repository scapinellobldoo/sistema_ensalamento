````markdown
# Sistema de Ensalamento

Um sistema completo de gerenciamento de ensalamento desenvolvido em Flutter, com backend em Supabase, projetado para facilitar a organização de aulas, salas, professores e disciplinas. Ele oferece diferentes interfaces para administradores, professores e alunos, garantindo uma gestão eficiente e acesso rápido às informações.

## 📚 Índice

* [Sobre o Projeto](#-sobre-o-projeto)
    * [Funcionalidades](#funcionalidades)
* [Tecnologias Utilizadas](#-tecnologias-utilizadas)
* [Pré-requisitos](#-pré-requisitos)
* [Primeiros Passos](#-primeiros-passos)
    * [Clonando o Repositório](#clonando-o-repositório)
    * [Configuração do Supabase](#configuração-do-supabase)
    * [Configuração do Flutter](#configuração-do-flutter)
    * [Executando a Aplicação](#executando-a-aplicação)
* [Estrutura do Banco de Dados (Supabase)](#estrutura-do-banco-de-dados-supabase)
* [Autenticação e Papéis (Roles)](#autenticação-e-papéis-roles)
* [Contribuição](#-contribuição)
* [Licença](#-licença)

---

## 🚀 Sobre o Projeto

O Sistema de Ensalamento é uma aplicação intuitiva e robusta para otimizar o processo de agendamento e visualização de aulas em instituições de ensino. Ele aborda os desafios de gerenciar recursos como salas e professores, minimizando conflitos de agendamento e fornecendo informações claras para todos os usuários envolvidos.

### Funcionalidades

* **Autenticação de Usuários:** Login e Registro de usuários com autenticação via e-mail e senha.
* **Controle de Acesso Baseado em Papéis (RBAC):** Diferentes dashboards e permissões para usuários com papéis de Administrador, Professor e Aluno.
* **Dashboard do Administrador:**
    * **Gerenciamento de Aulas:** Visualização em calendário, cadastro, edição e exclusão de aulas, com validação de conflitos (mesma sala ou professor no mesmo horário/dia).
    * **Gerenciamento de Salas:** Cadastro, edição e exclusão de salas, incluindo número, bloco, capacidade e recursos.
    * **Gerenciamento de Professores:** Cadastro, edição e exclusão de informações de professores (nome, e-mail, telefone, disciplinas lecionadas).
    * **Gerenciamento de Disciplinas:** Cadastro, edição e exclusão de disciplinas, que são usadas em um dropdown no formulário de aulas.
* **Dashboard do Professor:** Visualização das aulas agendadas especificamente para o professor logado.
* **Dashboard do Aluno:** Visualização de todas as aulas cadastradas no sistema.
* **Experiência do Usuário (UI/UX):**
    * Design moderno com esquema de cores personalizável (verde, laranja, branco).
    * Notificações claras de sucesso (verde) e erro (vermelho) para feedback imediato ao usuário.
    * Remoção de sombras em botões para um visual mais clean.
    * Background com transparência de 13% para ícones de listas e marcadores de calendário.
    * Localização em Português do Brasil para o calendário.
    * Remoção da faixa "DEBUG" em ambientes de desenvolvimento.

---

## 🛠️ Tecnologias Utilizadas

* **Frontend:**
    * [Flutter](https://flutter.dev/) (Framework de UI em Dart)
    * [Dart](https://dart.dev/) (Linguagem de Programação)
* **Backend:**
    * [Supabase](https://supabase.io/) (Backend-as-a-Service: Banco de Dados PostgreSQL, Autenticação)
* **Pacotes Flutter:**
    * [`supabase_flutter`](https://pub.dev/packages/supabase_flutter): Integração com o Supabase.
    * [`table_calendar`](https://pub.dev/packages/table_calendar): Componente de calendário personalizável.
    * [`intl`](https://pub.dev/packages/intl): Para internacionalização e formatação de datas.
    * [`flutter_localizations`](https://pub.dev/packages/flutter_localizations): Suporte a localização do Flutter.

---

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter os seguintes softwares instalados:

* [Flutter SDK](https://flutter.dev/docs/get-started/install) (versão compatível com o projeto).
* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
* Uma conta e um projeto configurado no [Supabase](https://supabase.io/).

---

## 🚀 Primeiros Passos

Siga estas instruções para configurar e executar o projeto em sua máquina local.

### Clonando o Repositório

```bash
git clone <URL_DO_SEU_REPOSITORIO>
cd sistema_ensalamento
````

### Configuração do Supabase

1.  **Crie um novo projeto no Supabase.**
2.  **Obtenha suas Chaves:** No painel do seu projeto Supabase, vá em `Project Settings > API` e copie sua **Project URL** e `anon public` **key**.
3.  **Atualize `lib/main.dart`:** Cole suas chaves nos respectivos campos:
    ```dart
    // lib/main.dart
    await Supabase.initialize(
      url: 'SUA_PROJECT_URL_AQUI',
      anonKey: 'SUA_ANON_PUBLIC_KEY_AQUI',
    );
    ```

### Configuração do Flutter

1.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```
2.  **Adicione a logo ao projeto:**
      * Salve sua imagem de logo (`image_c01ca3.png`) como `logo_main.png` dentro da pasta `assets/` do projeto.
      * Certifique-se de que `assets/logo_main.png` esteja declarado no seu `pubspec.yaml` (já feito se você seguiu os passos anteriores).

### Executando a Aplicação

1.  **Inicie um emulador ou conecte um dispositivo físico.**
2.  **Execute o aplicativo:**
    ```bash
    flutter run
    ```
    Ou, para iniciar com o modo de depuração desativado (sem a faixa "DEBUG"):
    ```bash
    flutter run --release
    ```
    *(Nota: A faixa "DEBUG" é removida automaticamente pelo `debugShowCheckedModeBanner: false` no `MaterialApp` durante o desenvolvimento. `--release` é para builds de produção.)*

-----

## 🗄️ Estrutura do Banco de Dados (Supabase)

O sistema utiliza as seguintes tabelas no Supabase (schema `public`):

1.  **`profiles`**:

      * Armazena informações adicionais dos usuários (relacionado à autenticação do Supabase).
      * Colunas essenciais: `id` (UUID, PK, FK para `auth.users`), `nome_completo` (TEXT), `role` (TEXT - ex: 'admin', 'professor', 'aluno').

2.  **`professores`**:

      * Informações detalhadas sobre os professores.
      * Colunas essenciais: `id` (UUID, PK), `nome` (TEXT), `email` (TEXT, UNIQUE), `telefone` (TEXT), `disciplinas_lecionadas` (TEXT - pode ser alterado para relação futura).

3.  **`salas`**:

      * Cadastro das salas disponíveis.
      * Colunas essenciais: `id` (UUID, PK), `numero` (TEXT, UNIQUE), `bloco` (TEXT), `capacidade` (INT), `recursos` (TEXT).

4.  **`disciplinas`**:

      * Cadastro das disciplinas oferecidas.
      * Colunas essenciais: `id` (UUID, PK), `nome` (TEXT, UNIQUE), `created_at` (TIMESTAMP).

    <!-- end list -->

    ```sql
    CREATE TABLE public.disciplinas (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        nome text NOT NULL UNIQUE,
        created_at timestamp with time zone DEFAULT now()
    );

    ALTER TABLE public.disciplinas ENABLE ROW LEVEL SECURITY;
    CREATE POLICY "Enable read access for all users" ON public.disciplinas
    FOR SELECT USING (true);
    CREATE POLICY "Enable insert for authenticated users only" ON public.disciplinas
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');
    CREATE POLICY "Enable update for authenticated users only" ON public.disciplinas
    FOR UPDATE USING (auth.role() = 'authenticated');
    CREATE POLICY "Enable delete for authenticated users only" ON public.disciplinas
    FOR DELETE USING (auth.role() = 'authenticated');
    ```

5.  **`aulas`**:

      * Registro das aulas agendadas.
      * Colunas essenciais: `id` (UUID, PK), `data_aula` (DATE), `horario` (TEXT), `id_disciplina` (UUID, FK para `disciplinas.id`), `id_sala` (UUID, FK para `salas.id`), `id_professor` (UUID, FK para `professores.id`).

    Para adicionar a coluna `id_disciplina` e sua chave estrangeira na tabela `aulas`:

    ```sql
    ALTER TABLE public.aulas
    ADD COLUMN id_disciplina uuid;

    ALTER TABLE public.aulas
    ADD CONSTRAINT aulas_id_disciplina_fkey
    FOREIGN KEY (id_disciplina) REFERENCES public.disciplinas(id);

    -- Se a coluna 'disciplina' antiga ainda existir e for NOT NULL, remova-a ou torne-a anulável
    -- ALTER TABLE public.aulas DROP COLUMN disciplina;
    -- OU
    -- ALTER TABLE public.aulas ALTER COLUMN disciplina DROP NOT NULL;
    ```

    **Importante:** Certifique-se de que todas as políticas de Row Level Security (RLS) para as tabelas `professores`, `salas`, `aulas` estejam configuradas corretamente no Supabase, similar às da tabela `disciplinas`, para permitir as operações de leitura, inserção, atualização e exclusão conforme necessário para cada papel de usuário.

-----

## 🔒 Autenticação e Papéis (Roles)

O sistema utiliza a funcionalidade de autenticação do Supabase e gerencia papéis de usuário através da tabela `profiles`.

  * **Registro:** Novos usuários se registram com e-mail, senha e nome completo. Por padrão, são atribuídos à `role: 'aluno'`.
  * **Login:** Após o login, o sistema consulta a `role` do usuário na tabela `profiles` e o redireciona para o dashboard correspondente (`/admin_dashboard`, `/professor_dashboard`, ou `/aluno_dashboard`).
  * **Atribuição de Papéis:** Atualmente, a atribuição inicial de papel é 'aluno'. A modificação do papel para 'admin' ou 'professor' deve ser feita manualmente no banco de dados Supabase (tabela `profiles`) após o registro.

-----

## 🤝 Contribuição

Contribuições são bem-vindas\! Se você tiver sugestões, relatórios de bugs ou quiser adicionar novas funcionalidades, sinta-se à vontade para:

1.  Fork o projeto.
2.  Crie uma nova branch (`git checkout -b feature/sua-feature`).
3.  Commit suas mudanças (`git commit -m 'feat: adiciona nova funcionalidade'`).
4.  Push para a branch (`git push origin feature/sua-feature`).
5.  Abra um Pull Request.

-----

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](https://www.google.com/search?q=LICENSE) para detalhes. (Assumindo que você terá um arquivo https://www.google.com/search?q=LICENSE com a licença MIT).

```
```
