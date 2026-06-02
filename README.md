# Fedora Post-Installation

Script interativo de pós-instalação para Fedora 44.

## Uso

```bash
chmod +x post-install-fedora.sh
./post-install-fedora.sh
```

## Seções

O script possui seções opcionais e interativas. Cada uma pode ser incluída ou pulada individualmente:

| Seção | Descrição | Método |
|---|---|---|
| dnf5 | Otimizar o DNF5 (velocidade e cores) | DNF |
| sysupdate | Atualizar sistema | DNF |
| rpmfusion | Habilitar RPM Fusion | DNF |
| flathub | Habilitar Flathub | Flatpak |
| firmware | Atualizar firmware do hardware | fwupd |
| codecs | Codecs de hardware para GPU | RPM Fusion |
| chrome | Google Chrome | RPM |
| 1password | 1Password | RPM |
| neovim | Neovim | DNF |
| vscode | Visual Studio Code | RPM |
| toolbox | JetBrains Toolbox | tarball |
| tweaks | GNOME Tweaks | DNF |
| extmgr | Gerenciador de Extensões GNOME | DNF |
| discord | Discord | Flatpak |
| spotify | Spotify | Flatpak |
| flatseal | Flatseal | Flatpak |
| temas | Temas e ícones (Yaru-dark e Breeze cursor) | DNF |
| fontes | Fonte JetBrains Mono Nerd Font | download |
| gnome | Configurações de interface do GNOME | gsettings |
| fish | Fish Shell (padrão + plugins) | DNF |
| clitools | Ferramentas CLI (bat, eza, bottom) | DNF |
| claudecode | Claude Code | Node.js |
| codex | Codex (OpenAI) | Node.js |
| hostname | Definir hostname da máquina | sistema |
| limpeza | Limpeza do sistema (autoremove) | DNF |

## Observações

- Todas as seções são idempotentes: verificam antes de instalar ou modificar.
- Seções com dependências externas falham de forma graciosa sem interromper o script.
