#!/bin/bash
# This script transform fod transformations calculated by mrtrix using ants transformations
# Xiaoxiao Qi

if [ $# -lt 4 ];then
	echo "`basename $0` FOD_image transform target_template transformed_FOD"
	echo "transform should be in ants convention"
	echo "The transformed_FOD will be reoriented and in MRTrix format"
	exit
fi

fod=${1}
trans=${2}
target=${3}
outfod=${4}

outdir=`dirname ${outfod}`

filename=`basename ${fod}`  
filename=${filename%_fod*}

tmpdir=${outdir}/tmp_${filename}

(umask 077 && mkdir ${tmpdir}) || {
	echo "Could not create temporary directory! Exiting." 1>&2
	exit 1
}

# commands:

warpinit ${fod} ${tmpdir}/identity_warp[].nii.gz

cmd="antsApplyTransforms -d 3 --verbose 1 -i ${tmpdir}/identity_warp0.nii.gz ${trans} -r ${target} -o [${tmpdir}/combtrans.nii.gz,1]"
echo ${cmd}
${cmd}

for i in {0..2}
do
	antsApplyTransforms -i ${tmpdir}/identity_warp${i}.nii.gz -t ${tmpdir}/combtrans.nii.gz -r ${target} -o ${tmpdir}/mrtrix_warp${i}.nii.gz
done


warpcorrect ${tmpdir}/mrtrix_warp[].nii ${tmpdir}/mrtrix_warp_corrected.mif -nthreads 1

mrtransform ${fod} -warp ${tmpdir}/mrtrix_warp_corrected.mif ${outfod} -force -nthreads 1

#rm -rf ${tmpdir}
