#!/bin/bash
#
# Download organizations and datasets files from data.gouv.fr (if not already present)
# Creates a CSV stats file to show diff
#
# Depends on csvkit (csvcut, csvjoin), sed and uniq command-line tools
#

./download_dumps.sh || exit 1

echo "Work on it..."
mkdir -p work
csvcut -d ';' -c 'id,name,metric.datasets' data/organizations.csv | csvsort -c 'id' > work/orgs.csv
(echo "id,dataset_count" && (csvcut -d ';' -c 'organization_id' data/datasets.csv 2>/dev/null | grep -v '""' | sed -e "1d" | sort | uniq -c | sed -e 's/^ *//' | sed -e 's/ /,/' | csvcut -c '2,1')) > work/dataset_count.csv

STATS_FILE=dist/organization_nb_dataset.csv 
echo "Generating stats file $STATS_FILE"
mkdir -p dist
csvjoin --left -c 'id' work/orgs.csv work/dataset_count.csv | sed -e 's/,$/,0/' > $STATS_FILE

echo
orgs_nb=`csvcut -c 'id' $STATS_FILE | sed -e '1d' | wc -l`
echo "Organizations: $orgs_nb"
errors_nb=`csvcut -c metric.datasets,dataset_count $STATS_FILE | sed -e '1d' | grep -Ev '^([0-9]+),\1$' | wc -l`
echo "Detected inconsistencies: $errors_nb"