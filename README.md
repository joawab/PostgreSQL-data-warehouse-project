# PostgreSQL Data Warehouse Project

A PostgreSQL data warehouse implementing the **bronze / silver / gold
medallion architecture** — from raw CSV ingestion to analysis-ready data.

This project is adapted from [DataWithBaraa's SQL Server data warehouse
project](https://github.com/DataWithBaraa/sql-data-warehouse-project),
ported to PostgreSQL. 

---

## Objective

Develop a modern data warehouse using PostgreSQL to consolidate sales data,
enabling analytical reporting and informed decision-making.

## Specifications

- **Data Sources:** Import data from two source systems (ERP and CRM),
  provided as CSV files.
- **Data Quality:** Cleanse and resolve data quality issues prior to
  analysis.
- **Integration:** Combine both sources into a single, user-friendly data
  model designed for analytical queries.
- **Scope:** Focus on the latest dataset only; historization of data is not
  required.
- **Documentation:** Provide clear documentation of the data model to
  support both business stakeholders and analytics teams.

---

## Tech Stack

- **PostgreSQL** — data warehouse engine
- **SQL** (DDL, DML, PL/pgSQL) — ingestion, transformation, and view logic
- **Git / GitHub** — version control

---

## Data Architecture

This project follows the **medallion architecture**. Each layer has a distinct responsibility, and data only moves forward — never backward — through the pipeline.

```
Source Systems (CRM, ERP)
        │
        ▼
  ┌───────────┐      ┌───────────┐      ┌───────────┐
  │  BRONZE   │  →   │  SILVER   │  →   │   GOLD    │
  │  (raw)    │      │ (cleaned) │      │ (business)│
  └───────────┘      └───────────┘      └───────────┘
                                              │
                                              ▼
                                    Analytics / BI / Reporting
```

### 🟫 Bronze Layer — Raw Data

**Purpose:** Land source data exactly as received, with zero transformation.

- One-to-one copy of source files (CRM and ERP exports)
- All columns loaded as `text`, regardless of their apparent type — this
  avoids silent data loss or errors from malformed values (e.g. inconsistent
  date formats) at load time
- No deduplication, no null handling, no renaming
- Serves as the audit trail / single source of truth for "what did the raw
  data actually look like"
- Includes data quality *investigation* scripts (read-only checks — no
  fixes applied at this stage)

### ⬜ Silver Layer — Cleaned & Standardized Data

**Purpose:** Apply data quality rules and standardize structure, without yet
imposing business logic or aggregation.

- Deduplication (e.g. keeping the most recent record per business key)
- Type casting (text → date, text → numeric, etc.)
- Standardizing categorical values (e.g. `M`/`F`/`Male`/`Female` → a single
  consistent value)
- Trimming whitespace, fixing casing
- Handling nulls per documented rules (drop, default, or flag — decided
  during Bronze investigation, applied here)
- Still organized around source structure (one Silver table roughly maps to
  one Bronze table) — not yet reshaped into a star schema

### 🟨 Gold Layer — Business-Ready Data

**Purpose:** Present data in a form ready for direct consumption by
analysts, dashboards, or reporting tools.

- Structured as a **star schema**: dimension tables/views (`dim_`) and fact
  tables/views (`fact_`)
- Combines and reshapes Silver tables — this is where CRM and ERP data
  actually get joined together into unified business entities
  (e.g. one `dim_customers` from multiple source systems)
- Built as **views**, not physical tables
- Business-friendly naming — no raw source column names should reach this
  layer

---

## Naming Conventions

### Schemas
One schema per layer: `bronze`, `silver`, `gold`.

### Bronze & Silver tables
Pattern: `<source_system>_<entity>`

| Example | Meaning |
|---|---|
| `bronze.crm_cust_info` | Raw customer info from the CRM source |
| `bronze.erp_cust_az12` | Raw customer info from the ERP source |
| `silver.crm_cust_info` | Cleaned version of the same CRM table |

Silver tables keep the **same name as their Bronze source** — this makes it
trivial to trace a Silver table back to where it came from. The
*transformation* is documented in comments/metadata, not encoded in the name.

### Gold views
Pattern: `<type>_<entity>`

| Prefix | Meaning | Example |
|---|---|---|
| `dim_` | Dimension — descriptive attributes | `gold.dim_customers` |
| `fact_` | Fact — measurable business events | `gold.fact_sales` |

Gold names are **business-facing** — no source-system prefixes, no
abbreviations that only make sense to someone who's seen the raw data.

### Columns
- `snake_case` throughout — no camelCase, no spaces
- Surrogate keys generated in Gold: `<entity>_key` (e.g. `customer_key`)
- Natural/business keys retained from source: `<entity>_id` or
  `<entity>_number` (e.g. `customer_id`, `order_number`)
- Avoid ambiguous names like `date`, `id`, `status` alone — always qualify
  with what it refers to (`order_date`, `product_id`, `order_status`)

### Scripts & files
Pattern: `<layer>_<purpose>.sql`, grouped in matching folders:

```
scripts/
├── bronze/
│   ├── ddl_bronze.sql
│   ├── load_bronze.sql
│   └── quality_check_bronze.sql
├── silver/
│   ├── ddl_silver.sql
│   ├── transform_silver.sql
│   └── quality_check_silver.sql
└── gold/
    └── ddl_gold.sql
```

---

## Repository Structure

```
├── datasets/              Raw CRM and ERP CSV source files
├── docs/
│   ├── data_catalog.md    Column-level documentation for Gold layer objects
│   └── data_architecture.md   This document's source (layers + naming)
├── scripts/
│   ├── bronze/            Raw ingestion DDL, load, and quality check scripts
│   ├── silver/            Cleaning/transformation DDL and scripts
│   └── gold/              Dimension/fact view definitions
├── tests/                 Data quality validation scripts
└── README.md
```

---

## Key Skills Demonstrated

- Medallion architecture design (Bronze / Silver / Gold)
- ETL pipeline development in PostgreSQL
- Data profiling and quality investigation (volume, uniqueness,
  completeness, consistency checks)
- Data cleansing: deduplication, type casting, categorical standardization
- Star schema data modeling (dimension/fact design)
- SQL dialect translation (T-SQL → PostgreSQL)
- Git-based version control with structured, incremental commits

---

## How to Run

1. Clone this repository
2. Create a PostgreSQL database and the three schemas:
   ```sql
   CREATE SCHEMA bronze;
   CREATE SCHEMA silver;
   CREATE SCHEMA gold;
   ```
3. Run the Bronze layer scripts in `scripts/bronze/` to create raw tables
   and load the source CSVs
4. Run the Silver layer scripts in `scripts/silver/` to clean and
   standardize the data
5. Run the Gold layer scripts in `scripts/gold/` to build the final
   dimension/fact views
6. Explore `docs/data_catalog.md` for column-level definitions of the Gold
   layer objects
