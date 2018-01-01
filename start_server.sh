#!/bin/sh
echo "Edit this script to change the path to ioquake3's dedicated server executable and which binary if you aren't on x86_64."
echo "Set the sv_dlURL setting to a url like http://yoursite.com/ioquake3_path for ioquake3 clients to download extra data."

# sv_dlURL needs to have quotes escaped like \"http://yoursite.com/ioquake3_path\" or it will be set to "http:" in-game.

#~/ioquake3/ioq3ded.x86_64 +set dedicated 2 +set sv_allowDownload 1 +set sv_dlURL \"\" +set com_hunkmegs 64 "$@"

# quick starting a quake 3 dedicated server
# /usr/lib/ioquake3/ioq3ded +exec server.cfg +exec levels.cfg +exec bots.cfg

~/ioquake3/ioq3ded.x86_64 +exec server.cfg +exec levels.cfg +exec bots.cfg
