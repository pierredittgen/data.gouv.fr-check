#!/bin/bash
#
# Download dumps files from data.gouv.fr (if not already present)
# Looks for inconsistencies between datasets and dataset ids referenced by resources
#
# Depends on comm, csvkit (csvcut, csvjoin), sed and uniq command-line tools

./download_dumps.sh || exit 1

echo "Work on it..."
mkdir -p work
csvcut -d ';' -c 'id' data/datasets.csv 2>/dev/null | sed -e "1d" | sort -u > work/datasets_unique_id.txt
csvcut -d ';' -c 'dataset.id' data/resources.csv | sed -e '1d' | sort -u > work/resources_ref_dataset_unique_id.txt

STATS_FILE=dist/dataset_ids_not_found.csv 
echo "Generating stats file $STATS_FILE"
mkdir -p dist
(echo "unknown dataset.id" && (comm -13 work/datasets_unique_id.txt work/resources_ref_dataset_unique_id.txt)) > $STATS_FILE

dataset_nb=`cat work/datasets_unique_id.txt | wc -l`
resource_dataset_nb=`cat work/resources_ref_dataset_unique_id.txt | wc -l`
unknown_dataset_nb=`sed -e '1d' $STATS_FILE | wc -l`

echo
echo "Dataset unique ids count in datasets table: $dataset_nb"
echo "Dataset unique ids number in resources.csv: $resource_dataset_nb"
echo "Unknown dataset ids number in resources.csv: $unknown_dataset_nb"