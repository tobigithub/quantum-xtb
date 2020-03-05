#!/bin/bash
# --------------------------------------------------------------
# Creates SASA (solvent accessible surface values for all solvents
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
echo "Using $NUMTHREADS threads for GBSA calculation"


#------------------------------------
# run extreme optimization with GBSA
#------------------------------------
# xtb used all CPUs automatically
# set export OMP_NUM_THREADS=<ncores>,1


# declare the gbsa.inp file for SASA output
cat > gbsa.inp << _EOF
\$write
   gbsa=true
   json=true
\$end
_EOF


# run GBSA optimization and print SASA
# "Acetone", "Acetonitrile", "Benzene", "CH2Cl2", "CHCl3", "CS2", "DMF", "DMSO", "Ether", "Water", "Methanol", "n-Hexan", "THF", "Toluene"
# benzene is only availabel with --gfn1 option

# declare solvents in an array variable
# https://stackoverflow.com/questions/8880603/loop-through-an-array-of-strings-in-bash
declare -a solvents=("Acetone" "Acetonitrile" "CH2Cl2" "CHCl3" "CS2" "DMF" "DMSO" "Ether" "Water" "Methanol" "n-Hexan" "THF" "Toluene")

# now loop through the above array
# You can access them using echo "${solvents[0]}", "${solvents[1]}" also

for i in "${solvents[@]}"
do
   echo "-------------------------------------"
   echo "$i"
   # xtb $FNAME -opt extreme 2>&1 | tee energy-output.txt
   xtb $FNAME --gfn2 --opt extreme --gbsa $i extreme -I gbsa.inp 2>&1 | grep SASA | tail -1
   rm xtbrestart; rm wbo; rm charges
done


# SECONDS timing can not run in subshell with sh only direct "./"
end=$SECONDS
echo "-------------------------------------"
echo ""
echo "Finished in $((end-start)) seconds."
