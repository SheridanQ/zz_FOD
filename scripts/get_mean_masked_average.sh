#!/bin/bash
# Descrption: get mean masked template, dealing with mif files
# utils
BASEDIR=$(dirname $0)
sum="${BASEDIR}/../utils/sum_images.sh"
div="${BASEDIR}/../utils/div_images.sh"
mul="${BASEDIR}/../utils/mul_images.sh"

if [ $# -lt 3 ]
then
    echo "Usage: `basement $0` subj_list mask_list mmtemplate"
    exit
fi

# parsing inputs
subj_list=${1}
mask_list=${2}
mmtemplate=${3} # mean masked template

outdir=$(dirname ${mmtemplate})

# protect env
tmpdir=${outdir}/tmp_${RANDOM}_${RANDOM}_${RANDOM}_$$
(umask 077 && mkdir ${tmpdir}) || {
    echo "Could not create temporary directory! Exiting." 1>&2
    exit 1
}

#cmds
# string=""
# paste -d'\n' ${subj_list} ${mask_list} | while read f1 && read f2; do
#   echo "$f1 $f2"

# done

bash ${sum} ${subj_list} ${tmpdir}/fod_sum.mif
bash ${sum} ${mask_list} ${tmpdir}/mask_sum.mif

bash ${div} ${tmpdir}/fod_sum.mif ${tmpdir}/mask_sum.mif ${mmtemplate}

# clean up
rm -rf ${tmpdir}

