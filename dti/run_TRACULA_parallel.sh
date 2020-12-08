#!/bin/sh

data_dir=/data/jux/mackey_group/austin
sub_list=$(cat ${data_dir}/TRACULA/scripts/sublist.txt)

for i in ${sub_list}; do
	sub_id=$(echo ${i})
	qsub -V -cwd -l h_vmem=7.1G,s_vmem=7G ${data_dir}/TRACULA/scripts/TRACULA.sh ${sub_id}
done
