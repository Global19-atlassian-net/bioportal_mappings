#!/bin/bash

# Configure defines the 4store server URLs and graph variables.
source 4storeConfigure.sh

# ---------------------------------------------------------------------------------
# Process input arguments

cat <<END > help.txt

Usage: $0 -g {graphEncodedURL} -i {mappingInputFile}

The {graphEncodedURL} is a target triple store graph URL, used as a
-d "graph={graphEncodedURL} for curl interaction with a 4store data endpoint.
This input argument is required.

The {mappingInputFile} is a file generated by java processes, which contains
mapping triples in turtle format.  This input argument is required.

END

if [ $# -eq 0 ]; then
    help
fi

graphEncodedURL=""
mappingInputFile=""

while getopts ":hg:i:" opt; do
    case $opt in
        h)
            help
            ;;
        g)
            graphEncodedURL="$OPTARG"
            ;;
        i)
            mappingInputFile="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

if [ "$graphEncodedURL" == "" ]; then
    help
fi
if [ "$mappingInputFile" == "" ]; then
    help
fi
if [ ! -f $mappingInputFile ]; then
    echo "$(date): $0, ERROR: There is no file: $mappingInputFile" >&2
    exit 1;
fi

# ---------------------------------------------------------------------------------
# Populate the {graph} with the input data.
echo "$(date): $0, INFO: Input file: $mappingInputFile" >&2
echo "$(date): $0, INFO: Upload graph: $graphEncodedURL" >&2
echo "$(date): $0, INFO: Starting upload to graph." >&2
curl -s -i \
    --data-urlencode data@$mappingInputFile \
    -d "graph=$graphEncodedURL" \
    -d "mime-type=application/x-turtle" \
    $triplestoreDataURL > $tmpFile
grep -q "success" $tmpFile
if [ $? -eq 0 ]; then
    echo "$(date): $0, INFO: Completed upload to graph." >&2
else
    echo "$(date): $0, ERROR: Failed to upload to graph." >&2
    cat $tmpFile >&2
    cleanup
    exit 1
fi

cleanup
