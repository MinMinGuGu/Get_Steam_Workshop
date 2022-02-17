$ErrorActionPreference = "Stop"
# Steam App Search: https://steamdb.info/search/
$steamAppId = "108600"

function getSteamPath {
    try {
        $steamPath = (Get-Item "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -ErrorAction "SilentlyContinue").GetValue("InstallPath")
        if ([String]::IsNullOrEmpty($steamPath) ) {
            $steamPath = Read-Host "无法获取Steam安装位置, 请手动指定Steam安装位置"
        }
    }
    catch {
        $steamPath = Read-Host "无法获取Steam安装位置, 请手动指定Steam安装位置"
    }
    return $steamPath
}

function getSavePath {
    $savePath = Read-Host "请输入Mod提取后保存的路径"
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
    while (($workshopIds = Read-Host "输入Workshop ID(支持英文分号分割 输入q退出)") -ne "q") {
        $basePath = [System.IO.Path]::Combine($steamPath, "steamapps", "workshop", "content")
        if (![System.IO.Directory]::Exists($basePath)) {
            $steamPath = Read-Host "$basePath 不存在 请手动指定存储了创意工坊的Steam目录"
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
    Write-Host "欢迎使用Steam获取创意工坊Mod脚本"
    $savePath = getSavePath | Select-Object -Last 1
    $steamPath = getSteamPath
    if (![System.IO.Directory]::Exists($steamPath)) {
        Write-Warning "Steam的路径无效"
        pause
        return
    }
    getSteamItem $savePath $steamPath
}

main