#!/bin/sh
Q3DIR="/home/ioq3srv/ioquake3/"
Q3PKPATH="$Q3DIR/baseq3/pak0.pk3"

# Test for the existence of the pak0.pk3 file
if [ ! -f "$Q3PKPATH" ]; then
    echo "!!! Pak0.pk3 is missing !!!" 1>&2
    echo "Please copy pak0.pk3 to the root of the container." 1>&2
    exit 1
fi

case $1 in
server)
	cd "$Q3DIR"
	./ioq3ded.x86_64 +exec server.cfg +exec levels.cfg +exec bots.cfg
    ;;
sh)
    "/bin/sh" "${@:2}"
    ;;
*)
    echo "Entrypoint: Unknown command" 1>&2
    exit 1
    ;;
esac
