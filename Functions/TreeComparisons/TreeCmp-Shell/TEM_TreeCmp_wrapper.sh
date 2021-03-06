##########################
#Wrapper for the TreeCmp function for the Total Evidence missing data analysis
##########################
#SYNTAX: TEM_TreeCmp_wrapper <list> <x> <method> <type>
#With
#<list> the list of chains numbers
#<x> the number of chains
#<method> either Bayesian or ML
#<type> either single or treesets
##########################
#version: 0.1
TEM_TreeCmp_wrapper_version="TEM_TreeCmp_wrapper.sh v0.1"
#----
#guillert(at)tcd.ie - 02/09/2014
##########################
#Requirements:
#-R 3.x
#-TreeCmp java script (Bogdanowicz et al 2012)
#-http://www.la-press.com/treecmp-comparison-of-trees-in-polynomial-time-article-a3300
#-TreeCmp folder to be installed at the level of the analysis
#-TEM_NexToNew.sh
##########################

list=$1
x=$2
method=$3
type=$4

#Bayesian method
if echo $method | grep "Bayesian" > /dev/null
then
    
    #Single tree comparisons (CONSENSUS TREE)
    if echo $type | grep "single" > /dev/null
    then
        for ((n = 0 ; n < x ; n++))
        do
            #Converting the trees
            mkdir Chain${list[n]}/
            cp -R 51t_1100c_HKY_Both_Chain${list[n]}_Bayesianjobs/ Chain${list[n]}/
            cd Chain${list[n]}/
            echo Chain${list[n]}
            sh ../TEM_NexToNew.sh Chain${list[n]} newick
            rm *.con.tre
            for f in *con.tre.tre
            do
                prefix=$(basename $f .con.tre.tre)
                mv $f ${prefix}.tre
                printf .
            done
            echo ""
            cd ..

            #Running the comparisons
            sh TEM_TreeCmp.sh Chain${list[n]}/Chain${list[n]}_L00F00C00.tre Chain${list[n]}/Chain${list[n]}_L 1 Chain${list[n]} newick TRUE

            #Renaming the comparisons (in unique comparison files)
            echo "1   1   " > file11
            file=Chain${list[n]}.Cmp
            folder=Chain${list[n]}
            chain=Chain${list[n]}
            length=$(grep ${folder}/${chain} $file | wc -l | sed 's/[[:space:]]//g')
            sed '1d' $file > tempfile

            for n in $(seq 1 $length)
            do
                name=$(sed -n ''"$n"'p' tempfile | sed 's/'"${folder}"'\/'"${chain}"'_L00F00C00.tre[[:space:]]'"${folder}"'\///g' | sed 's/.tre.*//g')
                valu=$(sed -n ''"$n"'p' tempfile | sed 's/'"${folder}"'\/'"${chain}"'_L00F00C00.tre[[:space:]]'"${folder}"'\///g' | sed 's/'"${name}"'.tre//g')
                prefix=$(basename ${name} .tre)
                echo $valu > ${name}.tmp
                echo "Ref.trees   Input.trees MatchingCluster R-F_Cluster NodalSplitted   Triples" > ${prefix}.Cmp
                paste file11 ${name}.tmp >> ${prefix}.Cmp
                printf .
            done

            echo ""
            rm file11 ; rm tempfile ; rm *.tmp
            rm $file ; rm -R $folder

        done

    else
    #Multiple trees comparisons (TREESETS)
        for ((n = 0 ; n < x ; n++))
        do
            echo Chain${list[n]}

            #Creating the treesets
            sh TEM_ChainSum.sh Chain${list[n]} 51 25 #number of species / burnin

            #Running the comparisons
            for input in Chain${list[n]}_treesets/Chain${list[n]}_*treeset
            do
                output=$(echo ${input} | sed 's/Chain'"${list[n]}"'_treesets\///g' | sed 's/.treeset//g')
                sh TEM_TreeCmp.sh Chain${list[n]}_treesets/Chain${list[n]}_L00F00C00.treeset ${input} 1000 ${output} nexus TRUE
            done

            #Removing the treeset file
            rm -R Chain${list[n]}_treesets

        done

    fi

else
    #ML method
    #Single tree comparisons (ML TREE)
    if echo $type | grep "single" > /dev/null
    then
        for ((n = 0 ; n < x ; n++))
        do
            #Renaming the trees
            mkdir Chain${list[n]}/
            cp -R 51t_1100c_HKY_Both_Chain${list[n]}_MLjobs/ Chain${list[n]}/
            cd Chain${list[n]}/
            echo Chain${list[n]}

            echo "Renaming the ML trees"
            for tree in RAxML_bipartitions.*
            do
                rename=$(echo $tree | sed 's/RAxML_bipartitions.//g')
                mv $tree ${rename}.tre
                printf .
            done
            echo ""
            cd ..

            #Running the comparisons
            sh TEM_TreeCmp.sh Chain${list[n]}/Chain${list[n]}_L00F00C00.tre Chain${list[n]}/Chain${list[n]}_L 1 Chain${list[n]} newick TRUE

            #Renaming the comparisons (in unique comparison files)
            echo "1   1   " > file11
            file=Chain${list[n]}.Cmp
            folder=Chain${list[n]}
            chain=Chain${list[n]}
            length=$(grep ${folder}/${chain} $file | wc -l | sed 's/[[:space:]]//g')
            sed '1d' $file > tempfile

            for n in $(seq 1 $length)
            do
                name=$(sed -n ''"$n"'p' tempfile | sed 's/'"${folder}"'\/'"${chain}"'_L00F00C00.tre[[:space:]]'"${folder}"'\///g' | sed 's/.tre.*//g')
                valu=$(sed -n ''"$n"'p' tempfile | sed 's/'"${folder}"'\/'"${chain}"'_L00F00C00.tre[[:space:]]'"${folder}"'\///g' | sed 's/'"${name}"'.tre//g')
                prefix=$(basename ${name} .tre)
                echo $valu > ${name}.tmp
                echo "Ref.trees   Input.trees MatchingCluster R-F_Cluster NodalSplitted   Triples" > ${prefix}.Cmp
                paste file11 ${name}.tmp >> ${prefix}.Cmp
                printf .
            done

            echo ""
            rm file11 ; rm tempfile ; rm *.tmp
            rm $file ; rm -R $folder

        done
    else

    #Multiple trees comparisons (BOOTSTRAPS)
        for ((n = 0 ; n < x ; n++))
        do
            echo Chain${list[n]}

            #Renaming the bootstraps files
            mkdir Chain${list[n]}_treesets
            cp -R 51t_1100c_HKY_Both_Chain${list[n]}_MLjobs/ Chain${list[n]}_treesets/
            cd Chain${list[n]}_treesets/
            echo "Renaming the ML trees"
            for tree in RAxML_bootstrap.*
            do
                rename=$(echo $tree | sed 's/RAxML_bootstrap.//g')
                mv $tree ${rename}.treeset
                printf .
            done
            echo ""
            cd ..


            #Running the comparisons
            for input in Chain${list[n]}_treesets/Chain${list[n]}_*treeset
            do
                output=$(echo ${input} | sed 's/Chain'"${list[n]}"'_treesets\///g' | sed 's/.treeset//g')
                sh TEM_TreeCmp.sh Chain${list[n]}_treesets/Chain${list[n]}_L00F00C00.treeset ${input} 1000 ${output} newick TRUE
            done

            #Removing the treeset file
            rm -R Chain${list[n]}_treesets

        done
    fi

fi
#End