#!/bin/sh
NAME="Open Speedtest"
PKG_DIR="/usr/local/AppCentral/Open-speedtest"
PIDFILE="${PKG_DIR}/var/httpd.pid"

case "$1" in
    start)
        echo "Starting $NAME"
        python3 "${PKG_DIR}/bin/httpd.py" 39876 "${PKG_DIR}/webman" \
            > "${PKG_DIR}/var/httpd.log" 2>&1 &
        echo $! > "$PIDFILE"
    ;;
    stop)
        echo "Stopping $NAME"
        if [ -f "$PIDFILE" ]; then
            kill $(cat "$PIDFILE") 2>/dev/null
            rm -f "$PIDFILE"
        fi
        # Safety net in case pidfile is missing or stale
        pkill -f "httpd.py" 2>/dev/null
    ;;
    restart|force-reload)
        $0 stop
        sleep 2
        $0 start
    ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 2
        ;;
esac
exit 0
