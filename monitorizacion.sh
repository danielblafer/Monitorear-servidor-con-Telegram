#!/bin/bash


# conexion con el bot y chat

TOKENBOT="<TOKEN_DEL_BOT>"
IDCHAT="<ID_DEL_CHAT>"


#funciones para monitorear el sistema

CargaPromedio=`uptime | sed 's/.*: //'`
EspacioDisponible=`df -h / | grep / | tr -s " " | cut -d " " -f 3`


mensaje+="Reporte `date +%d/%m/%Y`

"

mensaje+="La carga promedio de CPU es de *$CargaPromedio*
"
mensaje+="Quedan *$EspacioDisponible Disponibles* en el sistema

"


function Comprobar_estado_servicio(){

        estadoServicio=`systemctl status "$1" 2> /dev/null | grep Active: | cut -d " " -f 5`


        if [ ! -z "$estadoServicio" ];then

                mensaje+="El *servicio $1* está *$estadoServicio*
"

        fi


}

function Comprobar_consumo_proceso(){

        consumoCPU=`ps -aux | tr -s " " | grep "$1" | grep -v "grep" | cut -d " " -f 3 | sed 's/\./,/'`
        consumoMEM=`ps -aux | tr -s " " | grep "$1" | grep -v "grep" | cut -d " " -f 4 | sed 's/\./,/'`


        if [ ! -z "$consumoCPU" ] && [ ! -z "$consumoMEM" ] ;then

                mensaje+="El *proceso $1* esta consumiendo de CPU *$consumoCPU %* y de Memoria *$consumoMEM %*
"

        fi

}



# llamadas para comprobar servicios

Comprobar_estado_servicio "mariadb"
Comprobar_estado_servicio "apache2"

mensaje+="
"

# llamadas para comprobar procesos
Comprobar_consumo_proceso "mysqld"
Comprobar_consumo_proceso "Xorg"



# envio de mensaje
curl -s -X POST "https://api.telegram.org/bot${TOKENBOT}/sendMessage" -F chat_id=${IDCHAT} -F parse_mode="MarkdownV2" -F text="${mensaje}"
