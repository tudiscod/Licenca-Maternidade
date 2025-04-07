# 👩‍🍼 Script PowerShell - Gerenciamento de Licença Maternidade no Active Directory

Este script em PowerShell foi criado para **automatizar o controle de permissões no Active Directory** para colaboradoras em **licença maternidade**. Ele realiza verificações, movimentações de grupos e agendamentos de retorno de forma segura e organizada.

---

## 📌 O que esse script faz?

🔍 Ele busca todos os usuários do AD que estão com o atributo:

```powershell
extensionAttribute2 = 'Licença Maternidade'


🌀 Para cada usuário encontrado, o script:

Verifica se o usuário já está no grupo G-Maternidade

✅ Se já estiver, nenhuma ação é feita.

🚫 Se não estiver, ele segue com as próximas etapas:

Remove o usuário de todos os grupos que começam com O365Perfil*

Exemplo: O365PerfilMarketing, O365PerfilTI, etc.

📝 Cria uma tarefa agendada para readicioná-lo ao grupo após 150 dias.

Adiciona o usuário ao grupo G-Maternidade

📝 Cria uma tarefa agendada para removê-lo desse grupo após 150 dias.

Registra a tarefa agendada no Windows com:

✅ Todas as ações (remover/adicionar grupos)

⏰ Um gatilho para execução após 150 dias

🗂️ Exemplo prático
Suponha que a colaboradora Maria esteja com o atributo extensionAttribute2 = Licença Maternidade. O script irá:

Remover Maria de grupos como O365PerfilVendas

Adicioná-la ao grupo G-Maternidade

Agendar a readição ao O365PerfilVendas após 150 dias

Agendar a remoção do grupo G-Maternidade também após 150 dias

⚙️ Requisitos
PowerShell rodando com permissões de administrador

Módulo ActiveDirectory habilitado (normalmente já incluso em controladores de domínio)

Permissão para manipular usuários e grupos no AD

Permissão para registrar tarefas agendadas no Windows

🚀 Execução
Abra o PowerShell como Administrador

Execute o script:
.\ScriptLicencaMaternidade.ps1

📁 Onde as tarefas são salvas?
As tarefas agendadas ficam salvas na pasta do Agendador de Tarefas:

\Usuarios_Maternidade

💡 Dica
Você pode adaptar esse script para outros tipos de afastamentos, como:

Licença Paternidade

Afastamento médico

Férias

Basta alterar o valor do extensionAttribute2 e os grupos envolvidos.

📞 Suporte
Dúvidas ou sugestões? Abra uma issue ou envie um pull request! 🤝
