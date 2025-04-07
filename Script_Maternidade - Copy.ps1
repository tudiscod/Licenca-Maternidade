# Obter todos os usuários do Active Directory que estão com o extencionAttribute2 = 'Licença Maternidade'
$usuarios = Get-ADUser -Filter { extensionAttribute2 -eq 'Licença Maternidade' }

foreach ($usuario in $usuarios) {

    # Verificar se esses usuários estão no grupo G-Maternidade
    $usuarioNoGrupoMaternidade = Get-ADUser $usuario -Properties MemberOf | Select-Object -ExpandProperty MemberOf | Where-Object {$_ -like "*G-Maternidade*"}
    
    if ($usuarioNoGrupoMaternidade) {
        Write-Output "Usuário $($usuario.SamAccountName) já está no grupo G-Maternidade. Nenhuma ação necessária."
    } else {
        # Array para armazenar todas as ações que serão agendadas para este usuário
        $actions = @()

        # Remover o usuário de todos os grupos que começam com O365Perfil*
        $gruposO365 = Get-ADGroup -Filter {Name -like "O365Perfil*"}
        
        foreach ($grupo in $gruposO365) {

            if (Get-ADGroupMember -Identity $grupo -Recursive | Where-Object {$_.SamAccountName -eq $usuario.SamAccountName}) {

                Remove-ADGroupMember -Identity $grupo -Members $usuario -Confirm:$false

                Write-Output "Usuário $($usuario.SamAccountName) removido do grupo $($grupo.Name)."

                # Preparar ação para adicionar o usuário de volta após 150 dias
                $actionAdd = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-Command `"Add-ADGroupMember -Identity '$($grupo.Name)' -Members '$($usuario.SamAccountName)'`""
                
                # Adicionar a ação ao array de ações
                $actions += $actionAdd
            }

        }
     
        # Adicionar o usuário ao grupo G-Maternidade
        Add-ADGroupMember -Identity "G-Maternidade" -Members $usuario.SamAccountName
        Write-Output "Usuário $($usuario.SamAccountName) adicionado ao grupo G-Maternidade."

        # Preparar ação para remover o usuário após 150 dias do grupo G-Maternidade
        $actionRemove = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-Command `"Remove-ADGroupMember -Identity 'G-Maternidade' -Members '$($usuario.SamAccountName)' -Confirm:`$false`""

        # Adicionar a ação ao array de ações
        $actions += $actionRemove

        # Criar o gatilho para ocorrer uma vez daqui a 150 dias
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddDays(150)

        # Registrar a tarefa agendada com todas as ações e o gatilho para este usuário
        Register-ScheduledTask -TaskName "Remover Maternidade de $($usuario.SamAccountName)" `
            -Action $actions `
            -Trigger $trigger `
            -TaskPath "\Usuarios_Maternidade"

        Write-Output "Tarefa agendada para remover e adicionar o usuário $($usuario.SamAccountName) após 150 dias na pasta '\Usuarios_Maternidade'."
    }
}
