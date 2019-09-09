# data.gouv.fr checks

Shell scripts to extract inconsistencies in organizations, datasets and ressources published by data.gouv.fr

Depends on unix command-line tools (comm, csvkit, grep, sed, uniq)

## Organizations and dataset count inconsistencies

Track inconsistencies between "metrics.datasets" info found in organizations and real dataset count by organization

Run script:

```bash
./org_dataset_inconsistencies.sh
```

## Dataset and resource inconsistencies

Track inconsistencies between "dataset.id" found in resources and "id" found in datasets

Run script:

```bash
./dataset_resource_inconsistencies.sh
```
