#!/bin/sh
NAME="Open Speedtest"
PKG_DIR="/usr/local/AppCentral/Open-speedtest"
PIDFILE="${PKG_DIR}/var/httpd.pid"

case "$1" in
    start)
        if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
            echo "$NAME is already running"
            exit 0
        fi
        echo "Starting $NAME"
        busybox httpd -p 39877 -h "${PKG_DIR}/webman" -f \
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
        # Kill only the instance bound to our port
        pkill -f "busybox httpd -p 39877" 2>/dev/null
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
