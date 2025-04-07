# Obter todos os usu�rios do Active Directory que est�o com o extencionAttribute2 = 'Licen�a Maternidade'
$usuarios = Get-ADUser -Filter { extensionAttribute2 -eq 'Licen�a Maternidade' }

foreach ($usuario in $usuarios) {

    # Verificar se esses usu�rios est�o no grupo G-DEN-GD-Maternidade
    $usuarioNoGrupoMaternidade = Get-ADUser $usuario -Properties MemberOf | Select-Object -ExpandProperty MemberOf | Where-Object {$_ -like "*G-Maternidade*"}
    
    if ($usuarioNoGrupoMaternidade) {
        Write-Output "Usu�rio $($usuario.SamAccountName) j� est� no grupo G-Maternidade. Nenhuma a��o necess�ria."
    } else {
        # Array para armazenar todas as a��es que ser�o agendadas para este usu�rio
        $actions = @()

        # Remover o usu�rio de todos os grupos que come�am com O365Perfil*
        $gruposO365 = Get-ADGroup -Filter {Name -like "O365Perfil*"}
        
        foreach ($grupo in $gruposO365) {

            if (Get-ADGroupMember -Identity $grupo -Recursive | Where-Object {$_.SamAccountName -eq $usuario.SamAccountName}) {

                Remove-ADGroupMember -Identity $grupo -Members $usuario -Confirm:$false

                Write-Output "Usu�rio $($usuario.SamAccountName) removido do grupo $($grupo.Name)."

                # Preparar a��o para adicionar o usu�rio de volta ap�s 150 dias
                $actionAdd = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-Command `"Add-ADGroupMember -Identity '$($grupo.Name)' -Members '$($usuario.SamAccountName)'`""
                
                # Adicionar a a��o ao array de a��es
                $actions += $actionAdd
            }

        }
     
        # Adicionar o usu�rio ao grupo G-DEN-GD-Maternidade
        Add-ADGroupMember -Identity "G-Maternidade" -Members $usuario.SamAccountName
        Write-Output "Usu�rio $($usuario.SamAccountName) adicionado ao grupo G-Maternidade."

        # Preparar a��o para remover o usu�rio ap�s 150 dias do grupo G-DEN-GD-Maternidade
        $actionRemove = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-Command `"Remove-ADGroupMember -Identity 'G-Maternidade' -Members '$($usuario.SamAccountName)' -Confirm:`$false`""

        # Adicionar a a��o ao array de a��es
        $actions += $actionRemove

        # Criar o gatilho para ocorrer uma vez daqui a 150 dias
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddDays(150)

        # Registrar a tarefa agendada com todas as a��es e o gatilho para este usu�rio
        Register-ScheduledTask -TaskName "Remover Maternidade de $($usuario.SamAccountName)" `
            -Action $actions `
            -Trigger $trigger `
            -TaskPath "\Usuarios_Maternidade"

        Write-Output "Tarefa agendada para remover e adicionar o usu�rio $($usuario.SamAccountName) ap�s 150 dias na pasta '\Usuarios_Maternidade'."
    }
}
