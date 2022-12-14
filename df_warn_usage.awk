# Script awk para procesar el output del comando _df_  y
# para advertir si algún filesystem está ocupado por encima
# del _límite_ definido.

# Dependiendo la versión de _df_ instalada en el sistema, puede
# ser necesario utilizar la opción -P (use the POSIX output format)
# o las opciones -tk en versiones non-POSIX.

# Ejemplo de uso:
# ssh -xq ${USR}@${IP} 'df -P' | awk -f df_warn_usage.awk LIMIT=80 2>/dev/null 1>reporte_diario.log

# EXPECTED INPUT:
# 1ra línea:
# Filesystem	1024-blocks	Used	Available	Capacity	Mounted on

# https://github.com/oliver-almaraz/awk_parse_df/


BEGIN {
    # Definir el porcentaje de uso que se considera alto:
    if (ARGC != 2)
        LIMIT=90

    advertencias=0
}

NR == 1 {
    if ($1 != "Filesystem" || $5 != "Capacity" || $6 !~ /Mounted([:space:]on)?/){
        printf "Formato de entrada no habitual.\n¿Esta versión de _df_ es POSIX-compliant? ¿_df_ fue invocado con la opción -P?)\n\n" > "/dev/stderr"
	advertencias++
        exit 42
    }
}

NR > 1 {
    sub("%","",$5)
    if ($5 >= LIMIT){
        print "Advertencia: "$5"% usado en filesystem "$1" montado en "$6
        advertencias++
    }
}

END {
    if (advertencias == 0)
        print "Espacio en filesystems OK"
}
