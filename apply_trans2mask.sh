#!/bin/bash
scriptsdir=/data/ywu94/Final_template/scripts


if [ $# -lt 6 ];then
	echo "Usage: `basename $0` uid.list original_mask_folder transformation_folder out_folder target_template mode"
	exit
fi

uidlist=${1} #uid.list
maskdir=${2}
#transdir=${3}
deformeddir=${3}
zigzag=${4}
target=${5}
mode=${6}


jobdir="${deformeddir}/jobdir_mask_apply"
if [ -d ${jobdir} ]; then
 rm -rf ${jobdir}
 mkdir -p ${jobdir}
else
 mkdir -p ${jobdir}
fi

count=0
joblist="${jobdir}/job.list"
rm -f ${joblist}

for uid in `cat ${uidlist}`
do
	mask="${maskdir}/${uid}_*.nii*"
	trans=`bash ${scriptsdir}/Get_previous_transformations.sh ${uid} ${zigzag} ${mode}`
	deformed="${deformeddir}/${uid}_mask_deformed.nii.gz"

	cmd="antsApplyTransforms -i ${mask} -o ${deformed} -r ${target} ${trans} -n GenericLabel"

	jobname="applymask_${count}"
	jobscript="${jobdir}/job_${jobname}_qsub.sh"
	

	echo "#!/bin/bash" >${jobscript}
	echo "${cmd}" >> ${jobscript}
	echo "${jobname}" >> ${joblist}

	let count=count+1
done

bash /data/ywu94/Final_template/scripts/zz_FOD/utils/submit_jobs_v9_wait ${joblist} 24:00:00 8G 1 ${jobdir} 101
