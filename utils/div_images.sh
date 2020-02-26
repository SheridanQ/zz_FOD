num=${1}
dom=${2}
div=${3}

if [ $# -lt 3 ]
then
    echo "Usage: `basement $0` numerator dominator div"
    exit
fi

mrcalc ${num} ${dom} -div ${div} -force -nthreads 0

# clean up finite numbers
#mrcalc ${div} -isinf ${div} 0 -if ${div} -force -nthreads 0