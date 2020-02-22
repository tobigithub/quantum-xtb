#!/bin/bash
# --------------------------------------------------------------
# crest automation for tautomers, protomers, conformers, adducts
# Requires xtb and crest: https://xtb-docs.readthedocs.io/
# Tobias Kind (2020) v1
# --------------------------------------------------------------

# debug on (-x) /off (+x)
set +x

# start timing, does not work with "sh" in subshellbut with "./"
start=$SECONDS
echo "$start"

# requires xyz file as input
# needs to be crudely optimized with explicit hydrogens
# check if 2D is sufficient

if [ $# -eq 0 ]; then
    echo "Error: argument required: Please add input file in XYZ or mol format."
    echo ""
    exit 1
fi

# assign name
FNAME=$1
echo "Input structure: $FNAME"
#REM cat ${FNAME}

# assign processing threads for CREST
# beware of oversubscribing
NUMTHREADS=$(nproc)
echo "Using $NUMTHREADS threads for CREST"


#------------------------------------
# run low energy extreme optimization
#------------------------------------
# xtb used all CPUs automatically
# set export OMP_NUM_THREADS=<ncores>,1

mkdir energy
cp $FNAME energy/
cd energy
xtb $FNAME -opt extreme 2>&1 | tee energy-output.txt
cp xtbopt.xyz ../
cd ..

#-------------------------------------
# create all conformers and rotamers
# Warning: large computational overhead.
# Requires many CPUs, crest performs estimate calculation
#-------------------------------------

mkdir conformers
cp "xtbopt.xyz" conformers/
cd conformers
#REM crest xtbopt.xyz -T $NUMTHREADS 2>&1 | tee conformer-output.txt
cd ..

#------------------
# run [M+H]+ adduct
#------------------

mkdir protomers
cp "xtbopt.xyz" protomers/
cd protomers
crest xtbopt.xyz -protonate -T $NUMTHREADS 2>&1 | tee protomer-output.txt
cd ..

#------------------
# run [M-H]-
#------------------

mkdir deprotomers
cp "xtbopt.xyz" deprotomers
cd deprotomers
crest xtbopt.xyz -deprotonate -T $NUMTHREADS 2>&1 | tee deprotomer-output.txt
cd ..

#-----------------
# run Na+ adduct
#-----------------

mkdir sodium
cp "xtbopt.xyz" sodium/
cd sodium
crest xtbopt.xyz -protonate -T $NUMTHREADS -swel na+ 2>&1 | tee sodium-autput.txt
cd ..

#---------------------------
# Examples for GBSA solvents
#---------------------------
## crest starting-conformer.xyz -protonate -T 16  -ewin 10000 -iter 1000 -g acetonitrile
## crest starting-conformer.xyz -protonate -T 16  -ewin 10000 -iter 1000 -g water


#-----------------
# create tautomers
#-----------------

mkdir tautomers
cp "xtbopt.xyz" tautomers/
cd tautomers
crest xtbopt.xyz -tautomerize -T $NUMTHREADS 2>&1 | tee tautomer-output.txt
cd ..


# SECONDS timing can not run in subshell with sh only direct "./"
end=$SECONDS
echo "Finished in $((end-start)) seconds."
