APP_NAME=platform-discovery
VPS_HOME=/opt/vps
APP_FOLDER="$VPS_HOME"/"$APP_NAME"
SERVICE_NAME=vps-"$APP_NAME"d
PATH_JAR="$APP_FOLDER"/bin/"$APP_NAME".jar
OLD_SERVICE=registermgrd

[ -d "/etc/systemd/system" ] && SYSTEMD="1"
echo $SYSTEMD

if [ -z "$SYSTEMD" ]; then
        service $OLD_SERVICE status
        if [ $? = 0 ]; then
                service "$OLD_SERVICE" status > /dev/null && service "$OLD_SERVICE" stop
                chkconfig $OLD_SERVICE off
                chkconfig --del $OLD_SERVICE
                rm -rif /etc/init.d/$OLD_SERVICE
        fi
        service "$SERVICE_NAME" status > /dev/null && service "$SERVICE_NAME" stop
else
        systemctl is-active --quiet $SERVICE_NAME && systemctl stop $SERVICE_NAME
fi

[ ! -d "$APP_FOLDER" ] && mkdir -p "$APP_FOLDER"
scp -r bin "$APP_FOLDER"/
echo "INFORMACION: Recursos ejecutables copiados ..."

chown -R root.root "$APP_FOLDER"
chmod -R 755 "$APP_FOLDER"
chmod 500 "$PATH_JAR"
echo "INFORMACION: permisos de ejecución asignados ..."

if [ -z "$SYSTEMD" ]; then
        ln -s "$PATH_JAR" /etc/init.d/"$SERVICE_NAME"
        chkconfig --add $SERVICE_NAME
        service "$SERVICE_NAME" start
        echo "INFORMACION: servicio instalado y configurado ... SYSV "
else
        scp -r "$APP_FOLDER"/bin/"$SERVICE_NAME".service /etc/systemd/system/
        systemctl enable "$SERVICE_NAME".service
        systemctl daemon-reload
        systemctl start $SERVICE_NAME
        echo "INFORMACION: servicio instalado y configurado ... SYSTEMD "
fi
echo "Finalizado"