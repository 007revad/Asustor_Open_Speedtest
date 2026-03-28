#!/bin/sh

PKG_NAME="Open-speedtest"
PKG_ROOT="/usr/local/AppCentral/${PKG_NAME}"
BIN_DIR="${PKG_ROOT}/bin"
VAR_DIR="${PKG_ROOT}/var"
LOG_FILE="${VAR_DIR}/install.log"
ARCH="$(uname -m)"

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

# Create 30MB download test file
DOWNLOAD_FILE="${PKG_ROOT}/webman/downloading"
if dd if=/dev/zero of="$DOWNLOAD_FILE" bs=1M count=500 2>/dev/null; then
    log_message "Created 30MB downloading test file"
else
    log_message "Error: Failed to create downloading test file"
    exit 1
fi

# Create cgi-bin symlink for Python HTTP server CGI support
mkdir -p "${PKG_ROOT}/webman/cgi-bin"
ln -sf ../resize.cgi "${PKG_ROOT}/webman/cgi-bin/resize.cgi"
log_message "Created cgi-bin/resize.cgi symlink"

# Set execute permissions for scripts
chmod +x "${BIN_DIR}/httpd.py" 2>/dev/null && \
    log_message "Set +x on bin/httpd.py" || \
    { log_message "Warning: bin/httpd.py not found"; ERRORS=1; }
chmod +x "${PKG_ROOT}/webman/resize.cgi" 2>/dev/null && \
    log_message "Set +x on webman/resize.cgi" || \
    { log_message "Warning: webman/resize.cgi not found"; ERRORS=1; }

if [ -z "${ERRORS}" ]; then
    log_message "Post-installation completed successfully"
else
    log_message "Post-installation completed with warnings"
fi
echo >> "${LOG_FILE}"
exit 0
