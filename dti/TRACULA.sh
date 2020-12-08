#!/bin/sh

sub_id=$1

#preprocessing analysis
#trac-all -prep -c /data/jux/mackey_group/austin/TRACULA/config_files/${sub_id}/${sub_id}_config_file.txt

#ball & stick bed-post analysis
#trac-all -bedp -c /data/jux/mackey_group/austin/TRACULA/config_files/${sub_id}/${sub_id}_config_file.txt

#pathway reconstruction analysis
#trac-all -path -c /data/jux/mackey_group/austin/TRACULA/config_files/${sub_id}/${sub_id}_config_file.txt

#assemble pathway measures from multiple subjects
trac-all -stat -c /data/jux/mackey_group/austin/TRACULA/scripts/BPD_TRACULA_config_file.txt
