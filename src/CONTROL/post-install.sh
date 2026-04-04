#!/bin/sh

PKG_NAME="Open-speedtest"
PKG_ROOT="/usr/local/AppCentral/${PKG_NAME}"
VAR_DIR="${PKG_ROOT}/var"
LOG_FILE="${VAR_DIR}/install.log"

log_message() {
    mkdir -p "${VAR_DIR}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "${LOG_FILE}" 2>/dev/null || echo "$1"
}

log_message "Post-installation starting for package: ${PKG_NAME}"

# Create runtime var directory
if mkdir -p "${VAR_DIR}"; then
    log_message "Created var directory: ${VAR_DIR}"
    chmod 755 "${VAR_DIR}"
else
    log_message "Error: Failed to create var directory: ${VAR_DIR}"
    exit 1
fi

# Create 500MB download test file
DOWNLOAD_FILE="${PKG_ROOT}/webman/downloading"
if dd if=/dev/zero of="$DOWNLOAD_FILE" bs=1M count=500 2>/dev/null; then
    log_message "Created 500MB downloading test file"
else
    log_message "Error: Failed to create downloading test file"
    exit 1
fi

# Create lighttpd config
cat > "${VAR_DIR}/lighttpd.conf" << EOF
server.modules = ( "mod_cgi" )
server.document-root = "${PKG_ROOT}/webman"
server.port = 39877
server.pid-file = "${VAR_DIR}/lighttpd.pid"
server.errorlog = "${VAR_DIR}/httpd.log"
index-file.names = ( "index.html" )
cgi.assign = ( ".cgi" => "" )
static-file.exclude-extensions = ( ".cgi" )
EOF
chmod 644 "${VAR_DIR}/lighttpd.conf"
log_message "Created lighttpd.conf"

# Set execute permissions for scripts
chmod +x "${PKG_ROOT}/webman/resize.cgi" 2>/dev/null && \
    log_message "Set +x on webman/resize.cgi" || \
    { log_message "Warning: webman/resize.cgi not found"; ERRORS=1; }
chmod +x "${PKG_ROOT}/webman/upload.cgi" 2>/dev/null && \
    log_message "Set +x on webman/upload.cgi" || \
    { log_message "Warning: webman/upload.cgi not found"; ERRORS=1; }

if [ -z "${ERRORS}" ]; then
    log_message "Post-installation completed successfully"
else
    log_message "Post-installation completed with warnings"
fi
echo >> "${LOG_FILE}"
exit 0
