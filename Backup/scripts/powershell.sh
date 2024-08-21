# Download the powershell '.tar.gz' archive
curl -L -o /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v7.4.4/powershell-7.4.4-linux-x64.tar.gz

# Create the target folder where powershell will be placed
sudo mkdir -p $HOME/.config/microsoft/powershell/7

# Expand powershell to the target folder
sudo tar zxf /tmp/powershell.tar.gz -C $HOME/.config/microsoft/powershell/7

# Set execute permissions
sudo chmod +x $HOME/.config/microsoft/powershell/7/pwsh

# Create the symbolic link that points to pwsh
sudo ln -s $HOME/.config/microsoft/powershell/7/pwsh $PREFIX/bin/pwsh