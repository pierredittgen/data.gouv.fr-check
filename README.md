# Cohérence des données datagouv

## Nombre de datasets par organisation

À partir de odservatoire.sqlite:

Nombre datasets estimés par organisation (table organisations)

```sql
SELECT id, name, metric_datasets
FROM data_gouv_organizations
ORDER BY 1
```

Nombre de datasets trouvés par organisation (table datasets)

```sql
SELECT organization_id, COUNT(*) as dataset_nb
FROM data_gouv_datasets
GROUP BY organization_id
ORDER BY 1
```

## Nombre de ressources par dataset

## Getting data

From datagouv website

```bash
mkdir -p data
wget -nv https://www.data.gouv.fr/fr/organizations.csv -O data/organizations.csv
wget -nv https://www.data.gouv.fr/fr/datasets.csv -O data/datasets.csv
wget -nv https://www.data.gouv.fr/fr/resources.csv -O data/resources.csv
```

## Handling data

Using [csvkit](https://pypi.org/project/csvkit/), sort, uniq and sed

```bash
# Creates a minimal organizations CSV file
# with id, name and number of datasets
# sorted by id
mkdir -p work
csvcut -d ';' -c 'id,name,metric.datasets' data/organizations.csv | csvsort -c 'id' > work/orgs.csv
```

```bash
# Creates a CSV file containing number of datasets per organization id
# - extract organization_id column, ignoring errors
# - remove empty values
# - remove first line (header)
# - sort alphabetically and computes frequencies
# - rebuild csv
#   - remove heading spaces
#   - replacing space delimiter character by ','
#   - adding header
#   - swapping columns
csvcut -d ';' -c 'organization_id' data/datasets.csv 2>/dev/null | grep -v '""' | sed -e "1d" | sort | uniq -c | sed -e 's/^ *//' | sed -e 's/ /,/' | sed '1i dataset_count,id' | csvcut -c 'id,dataset_count' > work/dataset_count.csv
```

```bash
# Builds diff document
mkdir -p dist
csvjoin --left -c 'id' work/org.csv work/dataset_count.csv | sed -e 's/,$/,0/' > dist/organization_nb_dataset.csv
```
