#!/bin/bash
scriptsdir=/data/ywu94/Final_template/scripts
FOD_scripts_dir=/data/ywu94/Final_template/scripts/zz_FOD

if [ $# -lt 5 ];then
    echo "Usage: `basename $0` uid.list original_fod_folder transformation_folder out_folder target_template"
    exit
fi

uidlist=${1} #uid.list
filenum=$(wc -l < "$uidlist")

foddir=${2}
#transdir=${3}
deformeddir=${3}
zigzag=${4}
target=${5}


jobdir=${deformeddir}/job_dir
rm -rf ${jobdir}
mkdir -p ${jobdir}

############################################
count=0
joblist="${jobdir}/job.list"
rm -f ${joblist}

for uid in `cat ${uidlist}`
do
    fod="${foddir}/${uid}_fod.mif"
    trans=`bash ${scriptsdir}/Get_previous_transformations.sh ${uid} ${zigzag} FOD`
    deformed="${deformeddir}/${uid}_fod_deformed.mif"

    cmd="bash ${FOD_scripts_dir}/trans2fod.sh ${fod} \"${trans}\" ${target} ${deformed}"



    jobname="applyfod_${uid}_${count}"
    jobscript="${jobdir}/job_${jobname}_qsub.sh"
    

    echo "#!/bin/bash" >${jobscript}
    echo "${cmd}" >> ${jobscript}
    echo "${jobname}" >> ${joblist}

    let count=count+1
done

############################################
cd ${jobdir}

njobs=101

bash /data/ywu94/Final_template/scripts/zz_FOD/utils/submit_jobs_v9_wait ${joblist} 24:00:00 8G 1 ${jobdir} ${njobs}




