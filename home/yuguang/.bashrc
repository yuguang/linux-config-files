# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi


# Put your fun stuff here.
#alias ssh_start='for i in {10..59}; do ssh -f -N -L 30$i:10.10.10.$i:22 root@datamill.uwaterloo.ca; done; for i in {3..9}; do ssh -f -N -L 300$i:10.10.10.$i:22 root@datamill.uwaterloo.ca; done'

msql() {
    if [[ $1 == "--csv" ]]; then
        shift
        ssh cube "cd /var/www/localhost/wsgi/eval-lab/master; echo \" COPY ( $@ ) TO STDOUT  WITH CSV HEADER \" | ./manage.py dbshell "
    else
        ssh cube "cd /var/www/localhost/wsgi/eval-lab/master; echo \" $@ \" | ./manage.py dbshell "
    fi
}

tunnel() {

    read -r -d '' HELP <<EOF
Usage: cubetunnel [options] hostname

Create a tunnel to, and ssh into a given hostname that's hooked up to
DataMill.

    Command options:
    -h, --help, -?    Print this help documentation.
    --kill            Kill the tunnel if it already exists.
EOF
    
    local kill_old_tunnel=
    while :
    do
        case $1 in
            --help | -h | -\? )
                echo "$HELP"
                shift
                return
                ;;
            --kill )
                kill_old_tunnel=true
                shift
                ;;
            -- )
                shift
                break
                ;;
            -* )
                printf >&2 'WARN: Unknown option (ignored): %s\n' "$1"
                shift
                ;;
            * )
                break
                ;;
        esac
    done

    local hostname=$1
    if [[ -z $1 ]]; then
        echo "Empty hostname,  pass a valid hostname as the first argument."
        return
    fi
    local target_ip=$(msql --csv "select ip from datamill_website_worker where hostname = '${hostname}' order by last_update" | tail -n 1)
    local port_bits=$(printf "%0*d\n" 2 ${target_ip##*.})
    

    if pgrep -f "ssh.*${target_ip}.*cube"; then

        echo "Old tunnel found..."
 
        if [[ $kill_old_tunnel == "true" ]]; then
            echo "Killing old tunnel..."
            pkill -f "ssh.*${target_ip}.*cube"
            ssh -f -N -L 30${port_bits}:${target_ip}:22 cube
        else
            echo "Using old tunnel..."
        fi

    else
        echo "Creating tunnel..."
        ssh -f -N -L 30${port_bits}:${target_ip}:22 cube
    fi
    
    ssh -p 30${port_bits} root@localhost

}
