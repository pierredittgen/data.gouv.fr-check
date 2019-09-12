#!/bin/bash
#
# Download dumps files from data.gouv.fr (if not already present)
# Looks for inconsistencies between dataset number declared for an organization (organizations.csv)
#   and dataset count found for this organization (datasets.csv).
#
# Depends on csvkit (csvcut, csvjoin), sed and uniq command-line tools
# Maximum CSV line length 
MAX_LINE_LEN=1000000

./download_dumps.sh || exit 1

echo "Work on it..."
mkdir -p work
csvcut -d ';' -c 'id,name,metric.datasets' data/organizations.csv | csvsort -c 'id' > work/orgs.csv
(echo "id,dataset_count" && (csvcut -d ';' -c 'organization_id' -z $MAX_LINE_LEN data/datasets.csv | sed -e "1d" | sort | uniq -c | sed -e 's/^ *//' | sed -e 's/ /,/' | csvcut -c '2,1')) > work/dataset_count.csv

STATS_FILE=dist/organization_nb_dataset.csv 
echo "Generating stats file $STATS_FILE"
mkdir -p dist
csvjoin --left -c 'id' work/orgs.csv work/dataset_count.csv | sed -e 's/,$/,0/' > $STATS_FILE

echo
orgs_nb=`csvcut -c 'id' $STATS_FILE | sed -e '1d' | wc -l`
echo "Organizations: $orgs_nb"
errors_nb=`csvcut -c metric.datasets,dataset_count $STATS_FILE | sed -e '1d' | grep -Ev '^([0-9]+),\1$' | wc -l`
echo "Detected inconsistencies: $errors_nb"