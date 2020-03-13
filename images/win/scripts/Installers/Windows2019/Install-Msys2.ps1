################################################################################
##  File:  Install-MSYS2.ps1
##  Desc:  Install MSYS2 and 64-bit gcc, cmake, & llvm (32-bit commented out)
################################################################################

# References
# https://github.com/msys2/MINGW-packages/blob/master/azure-pipelines.yml
# https://packages.msys2.org/group/

$env:orig_path = $env:PATH
$env:git_path  = "C:\Program Files\Git"

# get info from https://sourceforge.net/projects/msys2/files/Base/x86_64/
$msy2_uri  = "https://netix.dl.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20190524.tar.xz"
$msy2_file = "C:\Windows\Temp\msys2.tar.xz"

# Download the latest msys2 x86_64
Write-Host "Starting msys2 download..."
(New-Object System.Net.WebClient).DownloadFile($msy2_uri, $msy2_file)
Write-Host "Finished download"

$msy2_file_u = "/$msy2_file".replace(':', '')

# git has tar.exe in usr/bin, but xz.exe is in mingw64/bin
$env:PATH = "$env:git_path\mingw64\bin;$env:orig_path"
$tar      = "$env:git_path\usr\bin\tar.exe"

# extract tar.xz to C:\
Write-Host "Starting extraction..."
&$tar -Jxf $msy2_file_u -C /c/
Remove-Item $msy2_file

Write-Host "Finished extraction"

$env:PATH = "C:\msys64\mingw64\bin;C:\msys64\usr\bin;$env:orig_path"

Write-Host "bash.exe -c pacman-key --init"
bash.exe -c "pacman-key --init"

Write-Host "bash.exe -c pacman-key --populate msys2"
bash.exe -c "pacman-key --populate msys2"

Write-Host "pacman --noconfirm -Syyuu"
pacman.exe -Syyuu --noconfirm

# install msys2 packages
Write-Host "Install msys2 packages"
pacman.exe -S --noconfirm --needed --noprogressbar base-devel compression

# mingw package list
$tools = "___clang ___cmake ___llvm  ___toolchain ___ragel"

# install mingw64 packages
Write-Host "Install mingw64 packages"
$pre = "mingw-w64-x86_64-"
pacman.exe -S --noconfirm --needed --noprogressbar $tools.replace('___', $pre).split(' ')

# install mingw32 packages
Write-Host "Install mingw32 packages"
$pre = "mingw-w64-i686-"
pacman.exe -S --noconfirm --needed --noprogressbar $tools.replace('___', $pre).split(' ')

# clean all packages to decrease image size
Write-Host "Clean packages"
pacman.exe -Scc --noconfirm

Write-Host
Write-Host "Installed mingw64 packages"
pacman.exe -Qs --noconfirm mingw-w64-x86_64-

Write-Host
Write-Host "Installed mingw32 packages"
pacman.exe -Qs --noconfirm mingw-w64-i686-

Write-Host
Write-Host "Installed msys2 packages"
pacman.exe -Qs --noconfirm

exit 0