#!/bin/bash
# --------------------------------------------------------------
# Compares inpout and output inchiKey of xtb after optimization
# INOUT: MOL file
# Requires xtb and crest: https://xtb-docs.readthedocs.io/
# Tobias Kind (2020) v1
# --------------------------------------------------------------

# debug on (-x) /off (+x)
set +x

# start timing, does not work with "sh" in subshellbut with "./"
start=$SECONDS
##echo "$start"

# requires mol/xyz file as input
# needs to be crudely optimized with explicit hydrogens
# check if 2D is sufficient

if [ $# -eq 0 ]; then
    echo "Error: argument required: Please add input file in XYZ or mol format."
    echo ""
    exit 1
fi

# assign name
FNAME=$1
##echo "Input structure: $FNAME"
##REM cat ${FNAME}

# assign processing threads for CREST 
# beware of oversubscribing
# add stack and memory options if needed
NUMTHREADS=$(nproc)
##echo "Using $NUMTHREADS threads."

# increase stack size for larger molecules, otherwise crash
# can be issue on cluster/cloud when small RAM size is requested
export OMP_STACKSIZE=1G

#------------------------------------
# run extreme optimization
#------------------------------------
# xtb used all CPUs automatically
# set export OMP_NUM_THREADS=<ncores>,1


# calculate inchikey1 from input structure
obabel -imol $FNAME -oINCHIKEY --errorlevel 0 2>&1  | grep -e "-" | tail -1 > inchikey1.txt

# calculate optimized structure and inchikey2; no output (only bash)
xtb --opt extreme $FNAME &> /dev/null

# calculate second inchikey2
obabel -imol xtbopt.mol -oINCHIKEY  ---errorlevel 0 2>&1  | grep -e "-" | tail -1 > inchikey2.txt

# compare and outpbut both inchikeys
# maybe check function to tell if different
diff inchikey1.txt inchikey2.txt  -y

# need to wait until command is finished
wait

# cleanup detail
rm inchikey1.txt; rm inchikey2.txt; rm xtbrestart; rm xtbopt.*; rm charges; rm wbo; rm xtbopt.log &> /dev/null
rm gfnff_convert.* &> /dev/null; rm scoord.* &> /dev/null ; rm xtb.trj&> /dev/null ; rm xtbmdok &> /dev/null
rm xonvert.log &> /dev/null ; rm mdrestart &> /dev/null ; rm.xtboptok &> /dev/null


# no timing because its fast
# SECONDS timing can not run in subshell with sh only direct "./"
end=$SECONDS
##echo "-------------------------------------"
##echo ""
##echo "Finished in $((end-start)) seconds."




