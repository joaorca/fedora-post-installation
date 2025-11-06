#!/usr/bin/env bash

TITLE_COLOR='\033[1;31m'
NC='\033[0m'

VSCODE_EXTENSIONS=(
  "esbenp.prettier-vscode"
  "dbaeumer.vscode-eslint"
  "eamodio.gitlens"
  "naumovs.color-highlight"
  "pkief.material-icon-theme"
  "editorconfig.editorconfig"
  "mikestead.dotenv"
  "barrsan.reui"
  "christian-kohler.npm-intellisense"
  "ms-azuretools.vscode-docker"
  "ms-vscode.vscode-typescript-next"
  "redhat.vscode-yaml"
  "ritwickdey.liveserver"
)

rm -rf ~/.vscode

for CODE_EXTENSION in ${VSCODE_EXTENSIONS[@]}
do
  echo -e "\n${TITLE_COLOR}Instalando extensão ${CODE_EXTENSION} ${NC}"
  code --install-extension ${CODE_EXTENSION}
done

echo '{
  "editor.tabSize": 2,
  "editor.fontSize": 16,
  "editor.lineHeight": 20,
  "editor.fontFamily": "Ubuntu Mono",
  "editor.fontLigatures": true,
  "editor.renderLineHighlight": "gutter",
  "editor.rulers": [100, 120],
  "editor.parameterHints.enabled": false,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },

  "breadcrumbs.enabled": true,
  "terminal.integrated.fontSize": 14,
  "terminal.integrated.fontFamily": "Source Code Pro",
  "extensions.ignoreRecommendations": true,
  "explorer.confirmDragAndDrop": false,
  "explorer.confirmDelete": false,
  "workbench.startupEditor": "newUntitledFile",
  "workbench.activityBar.visible": true,
  "workbench.iconTheme": "material-icon-theme",
  "workbench.colorTheme": "ReUI Default Bordered (react)",

  "eslint.packageManager": "yarn",
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "html"
  ],

  "files.associations": {
    ".sequelizerc": "javascript"
  },

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
  "javascript.suggest.autoImports": false,

  "typescript.updateImportsOnFileMove.enabled": "never",
  "typescript.suggest.autoImports": false,
  "typescript.tsserver.log": "verbose",

  "liveServer.settings.donotShowInfoMsg": true
}
' > ~/.config/Code/User/settings.json
