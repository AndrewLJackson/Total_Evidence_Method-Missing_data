##########################
#Total Evidence Method simulations
##########################
#SYNTAX:
#sh TEM_split-tasker.sh <chain name> <folder> <from> <to>
#with:
#<chain name> the chain name
#<folder> the prefix of the folder containing the chains
#<from> the starting chain name
#<to> the ending chain name
##########################
#Splits the matrix using the TEM_treesim_split.sh script and creates the task file for the cluster
#########################
#WARNING: this version only deals with nexus files generated by TEM_treesim.sh with the following parameters (25 living taxa, 25 fossil taxa, 1 outgroup - 1000 molecular characters, 100 morphological characters).
#WARNING: this version only uses only the matrix with no missing data L00C00F00
#version: 0.4
#Update: Correction in mpirun -np 8 mb ... added chain number after folder name ($folder$n)
#Update: Correction in task file, mb is now run directly in $folder$n
#Update: line 59 - Cluster timing is set to a maximum of one day (instead of 4)
#----
#guillert(at)tcd.ie - 16/05/2014
##########################
#Requirements:
#-Shell script TEM_treesim_split.sh
##########################

#Bonus
#For making the chains with the minimum amount of data (i.e. only the L00C00F00 matrices+cmd files)

#for n in $(seq 1 51)
#do
#    mkdir Split_Chain${n}
#    cp 51t_1100c_HKY_Bayesian_Chain${n}/MChain${n}_L00F00C00.nex Split_Chain${n}/
#    cp 51t_1100c_HKY_Bayesian_Chain${n}/MChain${n}_L00F00C00.cmd Split_Chain${n}/
#done


#INPUT
chain=$1
folder=$2
from=$3
to=$4

for n in $(seq $from $to)
do
    cd ${folder}${n}

    #Split the L00F00C00 matrices
    sh ../TEM_treesim_split.sh ${chain}${n}_L00F00C00 vertical
    sh ../TEM_treesim_split.sh ${chain}${n}_L00F00C00 horizontal
    sh ../TEM_treesim_split.sh ${chain}${n}_L00F00C00 corner
    echo "Matrix ${chain}${n} split"

    cd ..

    #JOB TEMPLATE
    echo "/#!/bin/sh
#SBATCH -n 8
#SBATCH -t 1-00:00:00
#SBATCH -p compute
#SBATCH -J S_${n}
source /etc/profile.d/modules.sh
export http_proxy=http://proxy.tchpc.tcd.ie:8080
module load cports6 openmpi/1.6.5-gnu4.8.2 
module load cports gsl/1.16-gnu

##########################
#TASK FILE ${n} - ${chain}
##########################

cd ${folder}${n}
mpirun -np 8 mb ${chain}${n}_L00F00C00.hor.cmd ;
mpirun -np 8 mb ${chain}${n}_L00F00C00.ver.cmd ;
mpirun -np 8 mb ${chain}${n}_L00F00C00.cor.cmd ;
cd .." | sed 's/\/\#!/\#!/g' > ${chain}${n}.job

done
