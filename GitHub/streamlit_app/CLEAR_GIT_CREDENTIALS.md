# 🔐 Limpiar Configuración de Git para Re-autenticación con GitHub

Esta guía te ayudará a limpiar tu configuración actual de Git para poder autenticarte nuevamente con GitHub.

## 📋 Comandos para Ejecutar

### ⚡ Método Rápido: Usar el Script Automatizado

```bash
# Navegar al directorio donde está el script
cd "/Users/ricardo.casillas/Library/CloudStorage/OneDrive-Slalom/Documents/GitHub/streamlit_app"

# Ejecutar el script
./clear_git_credentials.sh
```

Este script hace todo automáticamente y te muestra qué encontró y qué limpió.

### 🔧 Método Manual: Paso a Paso

### Paso 1: Limpiar Credential Helpers

```bash
# Limpiar todos los credential helpers
git config --global --unset-all credential.helper

# Si usas Git Credential Manager (macOS/Windows)
git credential-manager-core erase https://github.com
git credential-manager-core erase https://github.com/your-username

# Si usas macOS Keychain
git credential-osxkeychain erase
printf "host=github.com\nprotocol=https\n" | git credential reject

# Limpiar cache de credenciales
git credential-cache exit
```

### Paso 2: Limpiar Configuración de Usuario (Opcional)

Si quieres cambiar tu usuario/email también:

```bash
# Limpiar usuario actual
git config --global --unset user.name
git config --global --unset user.email

# O configurar nuevos valores
git config --global user.name "Tu Nombre"
git config --global user.email "tu-email@ejemplo.com"
```

### Paso 3: Limpiar Credenciales del Sistema

#### En macOS:

**Opción A: Usar el script automatizado (Recomendado)**
```bash
# Ejecutar el script que creamos
./clear_git_credentials.sh
```

**Opción B: Método manual más robusto**
```bash
# Buscar credenciales de GitHub primero
security find-internet-password -s github.com 2>&1

# Si encuentra credenciales, eliminarlas con el account específico
# (reemplaza "tu-usuario" con tu usuario de GitHub)
security delete-internet-password -s github.com -a "tu-usuario" 2>/dev/null

# O eliminar todas las entradas relacionadas con git
security delete-generic-password -s "github.com" 2>/dev/null
security delete-generic-password -s "git:https://github.com" 2>/dev/null
```

**Opción C: Usar Keychain Access (GUI) - Más fácil y seguro**
1. Abre **Keychain Access** (Cmd + Space, escribe "Keychain Access")
2. En la barra de búsqueda, busca **"github.com"** o **"git"**
3. Selecciona todas las entradas relacionadas
4. Click derecho > **Delete** o presiona **Delete**
5. Confirma la eliminación

**Opción D: Limpiar todo el Keychain de login (Cuidado - elimina todas las credenciales guardadas)**
```bash
# Solo si quieres limpiar TODO (no recomendado a menos que sea necesario)
# security delete-generic-password -l "github.com" ~/Library/Keychains/login.keychain-db
```

#### En Windows (Git Bash):
```bash
# Limpiar Windows Credential Manager
cmdkey /list | grep -i git
cmdkey /delete:git:https://github.com

# O usar el Panel de Control:
# 1. Panel de Control > Credential Manager
# 2. Windows Credentials
# 3. Busca entradas de "git:https://github.com"
# 4. Elimínalas
```

### Paso 4: Limpiar SSH Keys (Si usas SSH)

```bash
# Verificar si tienes SSH keys configuradas
ls -la ~/.ssh

# Si quieres eliminar una clave SSH específica de GitHub:
# (Solo si estás seguro de que quieres eliminarla)
# rm ~/.ssh/id_rsa_github
# rm ~/.ssh/id_rsa_github.pub
```

### Paso 5: Verificar que se Limpió Todo

```bash
# Ver configuración actual
git config --global --list

# Intentar una operación que requiera autenticación
git ls-remote https://github.com/tu-usuario/tu-repo.git
```

## 🔄 Re-autenticación con GitHub

### Opción 1: Personal Access Token (Recomendado)

1. **Crear un Personal Access Token:**
   - Ve a GitHub.com > Settings > Developer settings > Personal access tokens > Tokens (classic)
   - Click "Generate new token (classic)"
   - Selecciona los scopes necesarios (repo, workflow, etc.)
   - Copia el token

2. **Usar el token:**
   ```bash
   # Cuando Git te pida credenciales:
   # Username: tu-usuario-de-github
   # Password: [pega tu personal access token aquí]
   ```

3. **Configurar para que use el token automáticamente:**
   ```bash
   git config --global credential.helper store
   # La próxima vez que ingreses credenciales, se guardarán
   ```

### Opción 2: SSH Keys

1. **Generar nueva SSH key:**
   ```bash
   ssh-keygen -t ed25519 -C "tu-email@ejemplo.com" -f ~/.ssh/id_ed25519_github
   ```

2. **Agregar al SSH agent:**
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519_github
   ```

3. **Copiar la clave pública:**
   ```bash
   cat ~/.ssh/id_ed25519_github.pub
   # Copia el output
   ```

4. **Agregar a GitHub:**
   - Ve a GitHub.com > Settings > SSH and GPG keys
   - Click "New SSH key"
   - Pega la clave pública

5. **Configurar Git para usar SSH:**
   ```bash
   git config --global url."git@github.com:".insteadOf "https://github.com/"
   ```

### Opción 3: GitHub CLI (gh)

```bash
# Instalar GitHub CLI si no lo tienes
brew install gh  # macOS
# o
winget install GitHub.cli  # Windows

# Autenticarse
gh auth login

# Seguir las instrucciones en pantalla
```

## ✅ Verificación

Después de re-autenticarte, verifica que funciona:

```bash
# Clonar un repo privado (si tienes acceso)
git clone https://github.com/tu-usuario/tu-repo-privado.git

# O hacer push a un repo
git push origin main
```

## 🛠️ Troubleshooting

### Error: "Authentication failed"

- Verifica que el token/credenciales sean correctos
- Asegúrate de que el token tenga los permisos necesarios
- Verifica que no haya credenciales antiguas en cache

### Error: "Permission denied (publickey)"

- Verifica que tu SSH key esté agregada a GitHub
- Verifica que el SSH agent esté corriendo: `ssh-add -l`

### Error: "Repository not found"

- Verifica que tengas acceso al repositorio
- Verifica que el nombre del usuario/repo sea correcto

## 📚 Referencias

- [Git Credential Storage](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [GitHub SSH Keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
