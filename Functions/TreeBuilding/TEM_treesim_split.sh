##########################
#Total Evidence Method simulations - splits the given matrix and modifies the .cmd file
##########################
#SYNTAX:
#sh TEM_treesim_split.sh <matrix> [vertical|horizontal|corner]
#with:
#<matrix> the full prefix of one of the matrices generated buy TEM_matsim.sh script to split
#[vertical|horizontal|corner]the way to split the matrix. vertical = removes all molecular data. horizontal = removes all fossil data. corner = removes fossil data and molecular data.  
##########################
#WARNING: this version only deals with nexus files generated by TEM_treesim.sh with the following parameters (25 living taxa, 25 fossil taxa, 1 outgroup - 1000 molecular characters, 100 morphological characters).
#version: 0.2
#----
#guillert(at)tcd.ie - 13/05/2014
##########################

#INPUT
matrix=$1
type=$2

echo $type > type.test

#SPLITING THE MATRIX
if grep "vertical" type.test > /dev/null
then

    #Remove DNA in the nexus file    #WARNING! for the values see header
    rm type.test
    sed '11,61s/\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?\?//g' ${matrix}.nex | sed '11,61s/[ACGT][ACGT][ACGT][ACGT]//g' > ${matrix}.vertical
    sed 's/dimensions ntax = 51 nchar = 1100;/dimensions ntax = 51 nchar = 100;/g' ${matrix}.vertical | sed 's/datatype=mixed(DNA:1-1000,standard:1001-1100)/datatype=standard/g' > ${matrix}.ver.nex
    rm ${matrix}.vertical

    #Changing the command file
    sed 's/'"${matrix}"'/'"${matrix}"'.ver/g' ${matrix}.cmd | sed 's/applyto=(2)//g' > ${matrix}.vertical
    sed '15d' ${matrix}.vertical | sed '13d' | sed '6,9d' > ${matrix}.ver.cmd
    rm ${matrix}.vertical

else

    if grep "horizontal" type.test > /dev/null
    then

        #Remove fossils    #WARNING! for the values see header
        rm type.test
        sed '66,70d' ${matrix}.nex | sed '37,61d' > ${matrix}.horizontal
        sed 's/dimensions ntax = 51 nchar = 1100;/dimensions ntax = 26 nchar = 1100;/g' ${matrix}.horizontal > ${matrix}.hor.nex
        rm ${matrix}.horizontal

        #Changing the command file
        sed 's/'"${matrix}"'/'"${matrix}"'.hor/g' ${matrix}.cmd > ${matrix}.horizontal
        sed '19d' ${matrix}.horizontal > ${matrix}.hor.cmd
        rm ${matrix}.horizontal
    
    else

        if grep "corner" type.test > /dev/null
        then

            #Remove DNA and fossils    #WARNING! for the values see header
            rm type.test
            sed '66,70d' ${matrix}.nex | sed '37,61d' | sed '11,36s/[ACGT][ACGT][ACGT][ACGT]//g' > ${matrix}.corner
            sed 's/dimensions ntax = 51 nchar = 1100;/dimensions ntax = 26 nchar = 100;/g' ${matrix}.corner | sed 's/datatype=mixed(DNA:1-1000,standard:1001-1100)/datatype=standard/g' > ${matrix}.cor.nex
            rm ${matrix}.corner

            #Changing the command file
            sed 's/'"${matrix}"'/'"${matrix}"'.cor/g' ${matrix}.cmd | sed 's/applyto=(2)//g' > ${matrix}.corner
            sed '19d' ${matrix}.corner | sed '15d' | sed '13d' | sed '6,9d' > ${matrix}.cor.cmd
            rm ${matrix}.corner

        else

            #Wrong input
            rm type.test
            echo 'type must be "vertical", "horizontal" or "corner"'
        fi
    fi
fi

#End