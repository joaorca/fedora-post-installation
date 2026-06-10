# Fedora Post-Installation

Script interativo de pós-instalação para Fedora 44.

## Uso

```bash
chmod +x post-install-fedora.sh
./post-install-fedora.sh
```

O script exibe um dialog zenity para selecionar as seções desejadas antes de iniciar. Use o botão toggle para marcar/desmarcar tudo.

## Seções

O script possui 30 seções opcionais e interativas. Cada uma pode ser incluída ou pulada individualmente:

| Seção | Descrição | Método |
|---|---|---|
| dnf5 | Otimizar o DNF5 (velocidade e cores) | DNF |
| wifi | Desabilitar WiFi power save (reduz latência) | NetworkManager |
| bluetooth | Ativar Bluetooth automático no boot (AutoEnable + FastConnectable) | bluetoothd |
| sysupdate | Atualizar sistema | DNF |
| rpmfusion | Habilitar RPM Fusion | DNF |
| flathub | Habilitar Flathub | Flatpak |
| firmware | Atualizar firmware do hardware | fwupd |
| chrome | Google Chrome | RPM |
| 1password | 1Password | RPM |
| neovim | Neovim | DNF |
| vscode | Visual Studio Code | RPM |
| toolbox | JetBrains Toolbox | tarball |
| tweaks | GNOME Tweaks | DNF |
| extmgr | Gerenciador de Extensões GNOME | DNF |
| extensions | Extensões GNOME (5 extensões) | GNOME Extensions |
| discord | Discord | RPM |
| spotify | Spotify | Flatpak |
| temas | Temas e ícones (Yaru-dark e Breeze cursor) | DNF |
| fontes | Fonte JetBrains Mono Nerd Font | download |
| gnome | Configurações de interface do GNOME | gsettings |
| fish | Fish Shell (padrão + plugins) | DNF |
| clitools | Ferramentas CLI (bat, eza, btop) | DNF |
| podman | Podman (Docker compat + rootless + socket) | systemd |
| claudecode | Claude Code | Node.js |
| codex | Codex (OpenAI) | Node.js |
| manutencao | Manutenção completa (Flatpak + extensões + limpeza) | multi |
| limpeza | Limpeza do sistema (autoremove) | DNF |
| hostname | Definir hostname da máquina | sistema |
| mx2s | MX Anywhere 2S — botões laterais para workspace | input-remapper |
| mx3s | MX Anywhere 3S — botões laterais para workspace + swap middle/smartshift | input-remapper + Solaar |

## Observações

- Todas as seções são idempotentes: verificam antes de instalar ou modificar.
- Seções com dependências externas falham de forma graciosa sem interromper o script.
- Requer execução como usuário normal (não root).
