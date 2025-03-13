## NYC Taxi Data Pipeline using Kestra & dbt
### End-to-End Data Pipeline with Google Cloud Storage & BigQuery

This repository contains a fully automated data pipeline that processes NYC taxi trip data using Kestra for orchestration and dbt for transformation. The pipeline integrates Google Cloud Storage (GCS) and BigQuery (BQ) to store and process large-scale data efficiently.

---

## Architecture Overview
The project follows a modern ELT workflow:

1. **Kestra** orchestrates the pipeline:
   - Downloads raw NYC taxi data from GitHub.
   - Extracts, processes, and uploads it to GCS.
   - Creates external tables in BigQuery.

2. **dbt** transforms the data:
   - Cleans and models raw data.
   - Builds fact and dimension tables.
   - Computes aggregated metrics (revenue, travel time, fare distributions).

---

## Project Structure
```
nyc-taxi-data-pipeline
├── dags/                    # Kestra flows for orchestration
│   ├── green_taxi_flow.yml  # Kestra flow for green taxi data
│   ├── yellow_taxi_flow.yml # Kestra flow for yellow taxi data
│   ├── fhv_taxi_flow.yml    # Kestra flow for fhv taxi data
│   ├── backfill_flow.yml    # Kestra flow for historical data
├── dbt/                     # dbt transformation models
│   ├── models/              
│   │   ├── staging/         # Staging tables (raw data cleanup)
│   │   ├── core/            # Core fact and dimension tables
│   │   ├── marts/           # Aggregated models for analytics
│   ├── macros/              # Custom dbt macros
│   ├── tests/               # Data quality tests
│   ├── dbt_project.yml      # dbt project configuration
│   ├── profiles.yml         # dbt BigQuery connection config
├── scripts/                 # Utility scripts (optional)
├── README.md                # Project documentation
```

---

## Dependencies
Before running the pipeline, ensure you have the following:

### Google Cloud Platform (GCP)
- BigQuery
- Cloud Storage (GCS)
- IAM service account with necessary permissions

### Kestra
- Installed and configured locally or via Docker
- Google Cloud plugins enabled

### dbt
- `dbt-bigquery` installed
- Properly configured `profiles.yml`

### Python & Other Tools
- Python 3.8+
- `Google Cloud SDK`
- `git` for version control

---

## Installation & Setup

### 1. Clone the repository
```sh
git clone https://github.com/your-github-username/nyc-taxi-data-pipeline.git
cd nyc-taxi-data-pipeline
```

### 2. Configure Google Cloud credentials
```sh
export GOOGLE_APPLICATION_CREDENTIALS="path/to/your-gcp-service-account.json"
```

### 3. Install dbt dependencies
```sh
pip install dbt-bigquery
```
Initialize dbt:
```sh
dbt init nyc_taxi_dbt
```

### 4. Set up Kestra
Run locally using Docker:
```sh
docker run -p 8080:8080 kestra/kestra
```

### 5. Run the dbt pipeline
```sh
dbt run
```
To test the models:
```sh
dbt test
```

### 6. Run Kestra flows
Execute a backfill for historical data:
```sh
kestra flow execute --id backfill_flow
```

---

## Key dbt Models
| Model Name                          | Description |
|--------------------------------------|-------------|
| `stg_yellow_tripdata.sql`           | Staging table for yellow taxi trips |
| `stg_green_tripdata.sql`            | Staging table for green taxi trips |
| `dim_taxi_trips.sql`                | Dimension table with enriched trip details |
| `fct_taxi_trips_quarterly_revenue.sql` | Calculates quarterly revenue for taxi services |
| `fct_fhv_monthly_zone_traveltime_p90.sql` | Computes P90 travel time for FHV trips by zone |

---

## How the Pipeline Works

### 1. Data Extraction & Loading (Kestra)
- Fetches data from [DataTalksClub GitHub](https://github.com/DataTalksClub/nyc-tlc-data/releases).
- Loads data into Google Cloud Storage (GCS).
- Creates external tables in BigQuery.

### 2. Transformation & Aggregation (dbt)
- Cleans raw data (staging models).
- Builds fact and dimension tables for analysis.
- Computes revenue growth, travel time distribution, etc.

### 3. Analytics & Dashboarding
- The transformed data is now ready for BI tools like Looker, Tableau, or Google Data Studio.

---

## Running dbt in Production

### Schedule dbt Jobs
To schedule dbt runs in dbt Cloud, set up:
```yaml
schedules:
  - cron: "0 6 * * *"  # Run daily at 6 AM
    command: "dbt run --profiles-dir ./"
```

### Deploy dbt in Airflow
If using Apache Airflow, add a DAG to execute dbt:
```python
from airflow.providers.dbt.cloud.operators.dbt import DbtCloudRunJobOperator

dbt_run = DbtCloudRunJobOperator(
    task_id="dbt_run",
    dbt_cloud_conn_id="dbt_cloud",
    job_id=12345
)
```

---

## Contributing
If you'd like to contribute:
1. Fork the repository.
2. Create a new feature branch (`git checkout -b feature-branch`).
3. Commit changes (`git commit -m "Add new feature"`).
4. Push the branch (`git push origin feature-branch`).
5. Open a Pull Request.


