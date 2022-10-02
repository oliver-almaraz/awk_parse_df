# Script awk para procesar el output del comando _df_  y
# para advertir si algún filesystem está ocupado por encima
# del _límite_ definido.
#
# Dependiendo la versión de _df_ instalada en el sistema, puede
# ser necesario utilizar la opción -P (use the POSIX output format)
# o las opciones -tk en versiones non-POSIX.

# EXPECTED INPUT:
# 1ra línea:
# Filesystem	1024-blocks	Used	Available	Capacity	Mounted on


BEGIN {
    # Definir el porcentaje de uso que se considera alto:
    limite=90

    advertencias=0
}

NR == 1 {
    if ($5 != "Capacity" || $6 !~ /Mounted([:space:]on)?/){
        printf "(parece que el formato de _df_ cambió, revisa el script awk)\n\n"
	system("df -h")
	advertencias++
        exit
    }
}

NR > 1 {
    sub("%","",$5)
    if ($5 >= limite){
        print "Advertencia: "$5"% usado en filesystem "$1" montado en "$6
        advertencias++
    }
}

END {
    if (advertencias == 0)
        print "Espacio en filesistems OK"
}
