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
  "editor.tabSize": 2,
  "editor.fontSize": 11, //18,
  "editor.lineHeight": 16, //24,
  "editor.fontFamily": "Fira Code",
  "editor.fontLigatures": true,
  "editor.renderLineHighlight": "gutter",
  "editor.rulers": [80, 120],
  "editor.parameterHints.enabled": false,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": { "source.fixAll.eslint": true },

  "window.zoomLevel": 1,
  "breadcrumbs.enabled": true,
  "terminal.integrated.fontSize": 12,
  "extensions.ignoreRecommendations": true,
  "explorer.confirmDragAndDrop": false,
  "explorer.confirmDelete": false,

  "eslint.packageManager": "yarn",
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],

  "files.associations": {
    ".sequelizerc": "javascript"
  },

  "workbench.iconTheme": "material-icon-theme",
  "workbench.startupEditor": "newUntitledFile",
  "workbench.activityBar.visible": true,

  "emmet.syntaxProfiles": {
    "javascript": "jsx"
  },
  "emmet.includeLanguages": {
    "javascript": "javascriptreact"
  },

  "git.enableSmartCommit": true,
  "gitlens.codeLens.recentChange.enabled": false,
  "gitlens.codeLens.authors.enabled": false,
  "gitlens.codeLens.enabled": false,

  "javascript.updateImportsOnFileMove.enabled": "never",
  "typescript.updateImportsOnFileMove.enabled": "never",
  "javascript.suggest.autoImports": false,
  "typescript.suggest.autoImports": false,
  "typescript.tsserver.log": "verbose"
}
' > ~/.config/Code/User/settings.json
