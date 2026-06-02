# Fedora Post-Installation

Script interativo de pós-instalação para Fedora 44.

## Uso

```bash
chmod +x post-install-fedora.sh
./post-install-fedora.sh
```

## Seções

O script possui 15 seções opcionais e interativas:

1. Otimização do DNF5
2. Configuração do hostname
3. Atualização de firmware (fwupd)
4. Repositórios (RPM Fusion, COPR, Flathub)
5. Codecs GPU (VA-API, freeworld)
6. Aplicativos (Flatpak e RPM)
7. Neovim
8. Temas GTK e ícones
9. Fontes
10. Configurações GNOME
11. VS Code
12. Fish Shell
13. Ferramentas CLI
14. Rust (rustup)
15. Limpeza do sistema

## Observações

- Todas as seções são idempotentes: verificam antes de instalar ou modificar.
- Seções com dependências externas falham de forma graciosa sem interromper o script.
