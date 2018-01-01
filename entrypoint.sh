#!/bin/sh
Q3DIR="/home/ioq3srv/ioquake3/"
#Q3DIR="/home/root/ioquake3/"
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
#	./ioq3ded.x86_64 +set dedicated 2 +set fs_basepath "$Q3DIR" +set fs_cdpath "$Q3DIR" +set sv_maxclients 16 +set com_hunkmegs 96 +set fs_game excessiveplus +set vm_game 0
	./ioquake3/ioq3ded.x86_64 +exec server.cfg +exec levels.cfg +exec bots.cfg
    ;;
sh)
    "/bin/sh" "${@:2}"
    ;;
*)
    echo "Entrypoint: Unknown command" 1>&2
    exit 1
    ;;
esac
