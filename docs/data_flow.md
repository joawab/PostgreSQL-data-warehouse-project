# Data Flow

This diagram shows how data moves from source systems through the Bronze,
Silver, and Gold layers, based on the tables identified during profiling.

```mermaid
  flowchart LR

  subgraph Source["Source Systems"]
    CRM["CRM CSV files"]
    ERP["ERP CSV files"]
  end

  subgraph Bronze["Bronze Layer (raw data)"]
    B1["crm_sales_details"]
    B2["crm_cust_info"]
    B3["crm_prd_info"]
    B4["erp_cust_az12"]
    B5["erp_loc_a101"]
    B6["erp_px_cat_g1v2"]
  end

  subgraph Silver["Silver Layer (cleaned)"]
    S1["crm_sales_details"]
    S2["crm_cust_info"]
    S3["crm_prd_info"]
    S4["erp_cust_az12"]
    S5["erp_loc_a101"]
    S6["erp_px_cat_g1v2"]
  end

  subgraph Gold["Gold Layer (business-ready)"]
    G1["fact_sales"]
    G2["dim_customers"]
    G3["dim_products"]
  end

  CRM --> B1
  CRM --> B2
  CRM --> B3

  ERP --> B4
  ERP --> B5
  ERP --> B6

  B1 --> S1
  B2 --> S2
  B3 --> S3
  B4 --> S4
  B5 --> S5
  B6 --> S6

  S1 --> G1
  S2 --> G2
  S3 --> G3
  S4 --> G2
  S5 --> G2
  S6 --> G3

  G2 -.-> G1
  G3 -.-> G1
```

## Notes

- **Dotted lines** into `fact_sales` represent key relationships (the fact
  table references `dim_customers` and `dim_products` via surrogate keys),
  not a direct data transformation — the actual sales data comes from
  `crm_sales_details`.
- `dim_customers` combines CRM customer data (`crm_cust_info`) with ERP
  demographic and location data (`erp_cust_az12`, `erp_loc_a101`).
- `dim_products` combines CRM product data (`crm_prd_info`) with ERP
  category data (`erp_px_cat_g1v2`).
- Bronze and Silver tables share the same names by design (see naming
  conventions) — only the Gold layer introduces new, business-facing names.
