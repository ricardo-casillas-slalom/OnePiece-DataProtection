#!/bin/bash
# Script para limpiar credenciales de Git y GitHub

echo "🔐 Limpiando credenciales de Git y GitHub..."
echo ""

# 1. Limpiar credential helpers de Git
echo "1. Limpiando Git credential helpers..."
git config --global --unset-all credential.helper 2>/dev/null
echo "   ✅ Credential helpers limpiados"

# 2. Limpiar credenciales de GitHub del Keychain (método más robusto)
echo ""
echo "2. Limpiando credenciales de GitHub del Keychain..."

# Buscar todas las entradas de GitHub en el Keychain
GITHUB_KEYS=$(security dump-keychain 2>/dev/null | grep -i "github" | grep -i "acct" | awk -F'"' '{print $4}' | sort -u)

if [ -z "$GITHUB_KEYS" ]; then
    echo "   ℹ️  No se encontraron credenciales de GitHub en el Keychain"
else
    echo "   Encontradas credenciales para:"
    for key in $GITHUB_KEYS; do
        echo "   - $key"
        # Intentar eliminar cada entrada
        security delete-internet-password -s github.com -a "$key" 2>/dev/null && echo "     ✅ Eliminada" || echo "     ⚠️  No se pudo eliminar (puede requerir permisos)"
    done
fi

# Método alternativo: buscar por servicio
echo ""
echo "3. Intentando eliminar por servicio..."
security delete-internet-password -s github.com 2>/dev/null && echo "   ✅ Credenciales de github.com eliminadas" || echo "   ℹ️  No se encontraron credenciales para github.com"

# También buscar en git:https://github.com
security delete-internet-password -s "git:https://github.com" 2>/dev/null && echo "   ✅ Credenciales de git:https://github.com eliminadas" || echo "   ℹ️  No se encontraron credenciales para git:https://github.com"

# 4. Limpiar cache de credenciales de Git
echo ""
echo "4. Limpiando cache de credenciales de Git..."
git credential-cache exit 2>/dev/null && echo "   ✅ Cache limpiado" || echo "   ℹ️  No hay cache activo"

# 5. Limpiar credenciales usando git credential reject
echo ""
echo "5. Rechazando credenciales almacenadas..."
printf "host=github.com\nprotocol=https\n" | git credential reject 2>/dev/null && echo "   ✅ Credenciales rechazadas" || echo "   ℹ️  No hay credenciales almacenadas"

# 6. Verificar configuración actual
echo ""
echo "6. Configuración actual de Git:"
echo "   Credential helpers:"
git config --global --get-all credential.helper 2>/dev/null | sed 's/^/     - /' || echo "     (ninguno configurado)"
echo ""
echo "   Usuario:"
git config --global user.name 2>/dev/null | sed 's/^/     - /' || echo "     (no configurado)"
echo ""
echo "   Email:"
git config --global user.email 2>/dev/null | sed 's/^/     - /' || echo "     (no configurado)"

echo ""
echo "✅ Proceso completado!"
echo ""
echo "💡 Próximos pasos:"
echo "   1. La próxima vez que hagas git push/pull, Git te pedirá credenciales"
echo "   2. Puedes usar un Personal Access Token como contraseña"
echo "   3. O configurar SSH keys para autenticación"
echo ""
echo "   Para crear un Personal Access Token:"
echo "   https://github.com/settings/tokens"
