# Dotfiles
* OS: [Debian Sid](https://www.debian.org)
* WM: [Awesome](https://awesomewm.org)
* compositor: [picom](https://github.com/yshui/picom)
* Launcher: [rofi](https://github.com/davatorium/rofi)

# instalação
### Instale as dependências:
```bash
sudo apt install rofi picom fonts-firacode fonts-noto xfce4-power-manager nm-tray flameshot
```
### clone o repositório
```bash
git clone --depth 1 https://github.com/murilo-menezes/dotfiles && cd dotfiles
```
### faça backup em sua configuração atual
```bash
mv ~/.config/awesome ~/.config/awesome.backup
mv ~/.config/rofi ~/.config/rofi.backup
mv ~/.config/picom.conf ~/.config/picom.conf.backup
```
### mova a nova configuração para o diretório
```bash
cp -r ./config/* ~/.config
```
