#!/bin/bash

SUCCESS='\033[0;32m'
ERROR='\033[0;31m'
INFO='\033[0;36m'
WARNING='\033[0;33m'
BASE='\033[0m'

# configuraciones
success() {
    local message="$1"
    echo -e "${SUCCESS}Success: ${message}${BASE}"
}
error() {
    local message="$1"
    echo -e "${ERROR}Error: ${message}${BASE}"
}
info() {
    local message="$1"
    echo -e "${INFO}Info: ${message}${BASE}"
}
warning() {
    local message="$1"
    echo -e "${WARNING}Warning: ${message}${BASE}"
}
mostrar_titulos() {
    local titulos=($1)
    local funciones=($2)
    local opcion

    info "===================================="
    info "          Seleccione una opción      "
    info "===================================="
    for ((i = 0; i < ${#titulos[@]}; i++)); do
        info "$(($i + 1)). ${titulos[$i]}"
    done
    info "===================================="

    read -p "Ingrese el número de la opción: " opcion

    if ((opcion >= 1 && opcion <= ${#titulos[@]})); then
        clear
        ${funciones[$opcion - 1]}
        warning "Presiona Enter para continuar..."
        read
        clear
    else
        error "Opción no válida. Inténtelo de nuevo."
    fi
}
header() {
    local name="$1"
    local description="$2"
    local color="$3"
    local line_color=""
    case $color in
        "success")
            line_color="$SUCCESS" 
            ;;
        "warning")
            line_color="$WARNING"
            ;;
        "error")
            line_color="$ERROR"
            ;;
        "info")
            line_color="$INFO"
            ;;
        *)
            line_color="$BASE"
            ;;
    esac
    warning "$line_color"
    warning "----------------------------------------------------"
    warning "$name"
    if [ -n "$description" ]; then
        warning "$description"
    fi
    warning "----------------------------------------------------"
    warning "$BASE"
}

# funciones del escript
install_husky() {
  header "Instalando husky" "Husky ejecuta comandos antes o durante los commits" "info"
  npm install -D husky
  npx husky init
  chmod ug+x .husky/*

  echo 'echo "-------------------- Start Linter 1st --------------------"' > .husky/pre-commit
  echo "npx lint-staged"  >> .husky/pre-commit
  echo 'echo "-------------------- End Linter 1st ----------------------"'  >> .husky/pre-commit
  success "husky instalacion finalizada"
}

install_lint_staged() {
  header "Instalando LINT-STAGED" "Revisa con el linter solo los archivos modificados .ts .tsx" "info"
  npm install -D lint-staged

  echo '{' > .lintstagedrc
  echo '  "*.ts": "eslint",' >> .lintstagedrc
  echo '  "*.tsx": "eslint"' >> .lintstagedrc
  echo '}' >> .lintstagedrc
  success "LINT-STAGED Instalacion finalizada"
}

install_conventional_commit() {
  header "Instalando COMMITIZEN" "Utiliza conventional commit para la descripcion en los commits" "info"
  npm install -D commitizen
  npx commitizen init cz-conventional-changelog --save-dev --save-exact

  echo 'echo ""' > .husky/prepare-commit-msg
  echo 'echo "-------------------- Start Commitizen 2nd --------------------"' >> .husky/prepare-commit-msg 
  echo 'echo "---------------- Conventional commit messages ----------------"' >> .husky/prepare-commit-msg 
  echo 'exec < /dev/tty && node_modules/.bin/cz --hook || true' >> .husky/prepare-commit-msg 
  echo 'echo "-------------------- End Commitizen 2nd ----------------------"' >> .husky/prepare-commit-msg 
  
  success "COMMITIZEN Instalacion finalizada"
}

install_commit_lint() {
  header "Instalando COMMIT LINT" "Revisa si el commit cumple con conventional commit para la descripcion en los commits" "info"
  npm install -D @commitlint/{cli,config-conventional}
  echo "export default { extends: ['@commitlint/config-conventional'] };" > commitlint.config.mjs

  echo 'echo ""' > .husky/commit-msg
  echo 'echo "-------------------- Start Commit Lint 3th --------------------"' >> .husky/commit-msg
  echo 'npx --no -- commitlint --edit $1' >> .husky/commit-msg
  echo 'echo "-------------------- End Commit Lint 3th ----------------------"' >> .husky/commit-msg
  
  succes "COMMIT LINT Instalacion finalizada"
}

install_release_it() {
    local archivo="import fs from 'fs'
    const add = {
      'release-it': {
        git: {
          commitMessage: 'chore: release v\${version}'
        },
        github: {
          release: true
        },
        npm: {
          publish: false
        },
        plugins: {
          '@release-it/conventional-changelog': {
            infile: 'CHANGELOG.md',
            preset: {
              name: 'conventionalcommits',
              types: [
                {
                  type: 'feat',
                  section: 'Features'
                },
                {
                  type: 'fix',
                  section: 'Bug Fixes'
                },
                {
                  type: 'chore',
                  section: 'Chore'
                },
                {
                  type: 'docs',
                  section: 'Document'
                },
                {
                  type: 'style',
                  section: 'Style'
                },
                {
                  type: 'refactor',
                  section: 'Refactor'
                },
                {
                  type: 'perf',
                  section: 'Performance'
                },
                {
                  type: 'test',
                  section: 'Test'
                }
              ]
            }
          }
        }
      }
    }
    fs.readFile('package.json', 'utf8', (err, data) => {
      if (err) {
        console.error('Error al leer el archivo:', err)
        return
      }
      try {
        const jsonData = JSON.parse(data)
        jsonData.scripts.release = 'release-it'
        const join = { ...jsonData, ...add }
        const newData = JSON.stringify(join, null, 2)
        fs.writeFile('package.json', newData, err => {
          if (err) {
            console.error('Error al escribir el archivo:', err)
            return
          }
          console.log('Archivo actualizado con éxito.')
        })
      } catch (error) {
        console.error('Error al parsear el JSON:', error)
      }
    })"

    header "instalando RELEASE IT" "" "info"
    npm install -D release-it
    npm install -D @release-it/conventional-changelog

    echo "$archivo" > configuraciones.mjs
    node configuraciones.mjs
    rm configuraciones.mjs

    success "RELEASE IT intalacion finalizada"
}

config_prettier() {
  echo '{' > .prettierrc.json
  echo '  "printWidth": 120,' >> .prettierrc.json
  echo '  "trailingComma": "none",' >> .prettierrc.json
  echo '  "tabWidth": 2,' >> .prettierrc.json
  echo '  "semi": false,' >> .prettierrc.json
  echo '  "singleQuote": true,' >> .prettierrc.json
  echo '  "arrowParens": "avoid",' >> .prettierrc.json
  echo '  "endOfLine": "auto"' >> .prettierrc.json
  echo '}' >> .prettierrc.json

  local file="import fs from 'fs'
    fs.readFile('package.json', 'utf8', (err, data) => {
      if (err) {
        console.error('Error al leer el archivo:', err)
        return
      }
      try {
        const jsonData = JSON.parse(data)
        jsonData.scripts.format = 'prettier --write \"src/**/*.ts\" \"test/**/*.ts\"'
        const newData = JSON.stringify(jsonData, null, 2)
        fs.writeFile('package.json', newData, err => {
          if (err) {
            console.error('Error al escribir el archivo:', err)
            return
          }
          console.log('Archivo actualizado con éxito.')
        })
      } catch (error) {
        console.error('Error al parsear el JSON:', error)
      }
    })"
  
  header "Instalando PRETTIER" "Formateo de los archivos" "info"
  echo "$file" > configuraciones.mjs
  node configuraciones.mjs
  rm configuraciones.mjs
  npm run format
  succes "PRETTIER Instalacion finalizada"
}

todos() {
  install_husky
  install_lint_staged
  install_conventional_commit
  install_commit_lint
  install_release_it
  config_prettier
}

salir() {
  break
}

menu() {
  _all="todos"
  _husky="install_husky"
  _listStaged="install_lint_staged"
  _commitizen="install_conventional_commit"
  _commitLint="install_commit_lint"
  _releaseIt="install_release_it"
  _prettier="config_prettier"
  _salir="salir"

  echo ""
  warning "-------------------------------------------------------"
  warning "| * Realize un commit antes de continuar              |"
  warning "-------------------------------------------------------"

  echo ""
  options=("$_all" "$_husky" "$_listStaged" "$_commitizen" "$_commitLint" "$_releaseIt" "$_prettier" "$_salir")
  while true; do
    mostrar_titulos "${options[*]}" "${options[*]}"
  done
}

# -----------------------------------------------------------------------------------
# Verifica si el sistema operativo es Windows
if [ "$(uname)" == "Darwin" ]; then

    menu
else
    # Comando para Linux
    echo "Hola desde Linux"
fi
