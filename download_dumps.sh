#!/bin/bash

DATA_DIR=data

echo "Download dumps from data.gouv..."
mkdir -p data
if [ ! -e $DATA_DIR/organizations.csv ]; then
    wget -nv https://www.data.gouv.fr/fr/organizations.csv -O $DATA_DIR/organizations.csv
fi
if [ ! -e $DATA_DIR/datasets.csv ]; then
    wget -nv https://www.data.gouv.fr/fr/datasets.csv -O $DATA_DIR/datasets.csv
fi

echo "done."