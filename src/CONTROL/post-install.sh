#!/bin/sh

PKG_NAME="Open-speedtest"
PKG_ROOT="/usr/local/AppCentral/${PKG_NAME}"
BIN_DIR="${PKG_ROOT}/bin"
VAR_DIR="${PKG_ROOT}/var"
WWW_DIR="/usr/local/www/${PKG_NAME}"
RESULT_DIR="${WWW_DIR}/result"
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

# Create result directory
if mkdir -p "${RESULT_DIR}"; then
    log_message "Created result directory: ${RESULT_DIR}"
    chmod 755 "${RESULT_DIR}"
else
    log_message "Warning: Failed to create result directory: ${RESULT_DIR}"
    ERRORS=1
fi

# Create cgi-bin symlink for Python HTTP server CGI support
mkdir -p "${PKG_ROOT}/webman/cgi-bin"
ln -sf ../api.cgi "${PKG_ROOT}/webman/cgi-bin/api.cgi"
log_message "Created cgi-bin/api.cgi symlink"

# Set execute permissions for speedtest binaries
chmod +x "${BIN_DIR}/x86_64/speedtest"  2>/dev/null && \
    log_message "Set +x on bin/x86_64/speedtest" || \
    log_message "Warning: bin/x86_64/speedtest not found"
    ERRORS=1
chmod +x "${BIN_DIR}/aarch64/speedtest" 2>/dev/null && \
    log_message "Set +x on bin/aarch64/speedtest" || \
    log_message "Warning: bin/aarch64/speedtest not found"
    ERRORS=1

# Set execute permissions for bash binaries
chmod +x "${BIN_DIR}/x86_64/bash"  2>/dev/null && \
    log_message "Set +x on bin/x86_64/bash" || \
    log_message "Warning: bin/x86_64/bash not found"
    ERRORS=1
chmod +x "${BIN_DIR}/aarch64/bash" 2>/dev/null && \
    log_message "Set +x on bin/aarch64/bash" || \
    log_message "Warning: bin/aarch64/bash not found"
    ERRORS=1

# Set execute permissions for scripts
chmod +x "${BIN_DIR}/speedtest.sh" 2>/dev/null && \
    log_message "Set +x on bin/speedtest.sh" || \
    log_message "Warning: bin/speedtest.sh not found"
    ERRORS=1
chmod +x "${BIN_DIR}/httpd.py" 2>/dev/null && \
    log_message "Set +x on bin/httpd.py" || \
    log_message "Warning: bin/httpd.py not found"
    ERRORS=1
chmod +x "${PKG_ROOT}/webman/api.cgi" 2>/dev/null && \
    log_message "Set +x on webman/api.cgi" || \
    log_message "Warning: webman/api.cgi not found"
    ERRORS=1

# Setup logrotate
if cp "${PKG_ROOT}/webman/logrotate" /etc/logrotate.d/openspeedtest 2>/dev/null; then
    chmod 644 /etc/logrotate.d/openspeedtest
    log_message "Installed logrotate config"
else
    log_message "Note: No logrotate config found, skipping"
fi

# Set shebang in bash scripts
if [[ ! -f "${BIN_DIR}/${ARCH}/bash" ]]; then
    log_message "Error: No bash binary found for architecture: ${ARCH}"
    exit 1
else
    for script in "${BIN_DIR}"/*.sh; do
        sed -i "1s|.*|#!${BIN_DIR}/${ARCH}/bash|" "${script}"
        log_message "shebang in ${script} set to:"
        log_message "#!${BIN_DIR}/${ARCH}/bash|"
    done
fi

if [ -z "${ERRORS}" ]; then
    log_message "Post-installation completed successfully"
else
    log_message "Post-installation completed with warnings"
fi
echo >> "${LOG_FILE}"
exit 0
