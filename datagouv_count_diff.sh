#!/bin/bash
#
# Download organizations and datasets files from data.gouv.fr
# Creates a CSV file to show diff
#
# Depends on csvkit (csvcut, csvjoin), sed and uniq command-line tools
#

echo "Download data from data.gouv..."
mkdir -p data
wget -nv https://www.data.gouv.fr/fr/organizations.csv -O data/organizations.csv
wget -nv https://www.data.gouv.fr/fr/datasets.csv -O data/datasets.csv

echo "Work on it..."
mkdir -p work
csvcut -d ';' -c 'id,name,metric.datasets' data/organizations.csv | csvsort -c 'id' > work/orgs.csv
(echo "id,dataset_count" && (csvcut -d ';' -c 'organization_id' data/datasets.csv 2>/dev/null | grep -v '""' | sed -e "1d" | sort | uniq -c | sed -e 's/^ *//' | sed -e 's/ /,/' | csvcut -c '2,1')) > work/dataset_count.csv

echo "Generating merged file..."
mkdir -p dist
csvjoin --left -c 'id' work/orgs.csv work/dataset_count.csv | sed -e 's/,$/,0/' > dist/organization_nb_dataset.csv

echo "Done"