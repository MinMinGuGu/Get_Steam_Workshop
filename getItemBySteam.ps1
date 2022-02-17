$ErrorActionPreference = "Stop"
# Steam App Search: https://steamdb.info/search/
$steamAppId = "108600"

function getSteamPath {
    try {
        $steamPath = (Get-Item "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -ErrorAction "SilentlyContinue").GetValue("InstallPath")
        if ([String]::IsNullOrEmpty($steamPath) ) {
            $steamPath = Read-Host "�޷���ȡSteam��װλ��, ���ֶ�ָ��Steam��װλ��"
        }
    }
    catch {
        $steamPath = Read-Host "�޷���ȡSteam��װλ��, ���ֶ�ָ��Steam��װλ��"
    }
    return $steamPath
}

function getSavePath {
    $savePath = Read-Host "������Mod��ȡ�󱣴��·��"
    if (![System.IO.Directory]::Exists($savePath)) {
        [System.IO.Directory]::CreateDirectory($savePath)
    }
    return [System.Io.Path]::GetFullPath($savePath)
}

function getSteamItem {
    param(
        $savePath,
        $steamPath
    )
    while (($workshopIds = Read-Host "����Workshop ID(֧��Ӣ�ķֺŷָ� ����q�˳�)") -ne "q") {
        $basePath = [System.IO.Path]::Combine($steamPath, "steamapps", "workshop", "content")
        if (![System.IO.Directory]::Exists($basePath)) {
            $steamPath = Read-Host "$basePath ������ ���ֶ�ָ���洢�˴��⹤����SteamĿ¼"
        }
        foreach ($workshopId in $workshopIds.Split(";")) {
            $modRootPath = [System.IO.Path]::Combine($steamPath, "steamapps", "workshop", "content", $steamAppId, $workshopId)
            foreach ($modItem in $(get-childitem $modRootPath)) {
                $modPath = [System.IO.Path]::Combine($modRootPath, $modItem)
                copy-item -Recurse -Force $modPath $savePath
            }
        }
    }
}

function main {
    Write-Host "��ӭʹ��Steam��ȡ���⹤��Mod�ű�"
    $savePath = getSavePath | Select-Object -Last 1
    $steamPath = getSteamPath
    if (![System.IO.Directory]::Exists($steamPath)) {
        Write-Warning "Steam��·����Ч"
        pause
        return
    }
    getSteamItem $savePath $steamPath
}

main