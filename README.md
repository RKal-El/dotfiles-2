# Dotfiles
* OS: [Debian Sid](https://www.debian.org)
* WM: [Awesome](https://awesomewm.org)
* compositor: [picom](https://github.com/yshui/picom)
* Launcher: [rofi](https://github.com/davatorium/rofi)

# instalação
### Install the dependencies:
```bash
sudo apt install rofi picom fonts-firacode fonts-noto xfce4-power-manager nm-tray flameshot
```
### clone the repo
```bash
git clone --depth=1 https://github.com/murilo-menezes/dotfiles && cd dotfiles
```
### make a backup
```bash
mv ~/.config/awesome ~/.config/awesome.backup
mv ~/.config/rofi ~/.config/rofi.backup
mv ~/.config/picom.conf ~/.config/picom.conf.backup
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.xinitrc ~/.xinitrc.backup
```
### move the current config
```bash
cp -r ./.config/* ~/.config
cp ./.xinitrc ~/.xinitrc
```
