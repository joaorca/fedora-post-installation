#!/usr/bin/env bash

TITLE_COLOR='\033[1;31m'
NC='\033[0m'

VSCODE_EXTENSIONS=(
  "dracula-theme.theme-dracula"
  "naumovs.color-highlight"
  "mikestead.dotenv"
  "editorconfig.editorconfig"
  "dbaeumer.vscode-eslint"
  "eamodio.gitlens"
  "pkief.material-icon-theme"
  "jpoissonnier.vscode-styled-components"
  "esbenp.prettier-vscode"
)

rm -rf ~/.vscode

for CODE_EXTENSION in ${VSCODE_EXTENSIONS[@]}
do
  echo -e "\n${TITLE_COLOR}Instalando extensão ${CODE_EXTENSION} ${NC}"
  code --install-extension ${CODE_EXTENSION}
done

echo '{
  "editor.fontSize": 11, //18,
  "editor.lineHeight": 16, //24,
  "editor.fontFamily": "Fira Code",
  "editor.fontLigatures": true,

  // Aplica linhas verticais para lembrar de quebrar linha em códigos muito grandes
  "editor.rulers": [80, 120],
  "editor.formatOnSave": false,

  "eslint.packageManager": "yarn",
  "eslint.autoFixOnSave": true,
  "eslint.validate": [
    {
      "language": "javascript",
      "autoFix": true
    },
    {
      "language": "javascriptreact",
      "autoFix": true
    },
    {
      "language": "typescript",
      "autoFix": true
    },
    {
      "language": "typescriptreact",
      "autoFix": true
    }
  ],

  "files.associations": {
    ".sequelizerc": "javascript"
  },

  // Aplica um sinal visual na esquerda da linha selecionada
  "editor.renderLineHighlight": "gutter",

  // Aumenta a fonte do terminal
  "terminal.integrated.fontSize": 12,

  // Define o tema dos ícones na sidebar
  "workbench.iconTheme": "material-icon-theme",
  "workbench.startupEditor": "newUntitledFile",
  "editor.tabSize": 2,
  "window.zoomLevel": 1,
  "extensions.ignoreRecommendations": true,
  "emmet.syntaxProfiles": {
    "javascript": "jsx",
  },
  "emmet.includeLanguages": {
    "javascript": "javascriptreact",
  },
  "javascript.updateImportsOnFileMove.enabled": "never",
  "gitlens.codeLens.recentChange.enabled": false,
  "gitlens.codeLens.authors.enabled": false,
  "gitlens.codeLens.enabled": false,
  "breadcrumbs.enabled": true,
  "git.enableSmartCommit": true,
  "editor.parameterHints.enabled": false,
  "typescript.updateImportsOnFileMove.enabled": "never",
  "terminal.integrated.shell.osx": "/bin/zsh",
  "explorer.confirmDragAndDrop": false,
  "liveshare.featureSet": "insiders",
  "explorer.confirmDelete": false,

  "typescript.tsserver.log": "verbose",
  "javascript.suggest.autoImports": false,
  "typescript.suggest.autoImports": false,
  "workbench.activityBar.visible": true
}' > ~/.config/Code/User/settings.json
