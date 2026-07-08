# Data Dictionary for Gold Layer

## Overview

The Gold layer represents business-ready data organized in Star schema. It consists of fact table described by dimension tables.

## Content

### Fact_sales

#### Purpose:
Stores transactional data for further analysis.
#### Contents:

|Column | Data Type | Description |
|---|---|---|
|order_number |TEXT|Sales order identifier (Primary key)|
|product_key |INTEGER|Foreign key for dim_products|
|customer_key |INTEGER|Foreign key for dim_customers|
|order_date |DATE|Date order has been placed (YYYY-MM-DD)|
|ship_date|DATE|Date order has been shipped (YYYY-MM-DD)|
|due_date |DATE|Expected delivery date (YYYY-MM-DD)|
|sales |DECIMAL|Sales value|
|quantity |INTEGER|Units sold|
|sales |DECIMAL|Price per unit|

#### Business Decisions:
- Some sales records were missing or had clearly wrong values for total
  sale amount or unit price. Where that happened, missing figure has been recalcualted (sale amount = quantity × price).
- One order can include several products, so the same order number will
  appear more than once — once per product purchased.

### Dim_customers

#### Purpose:
Store customer details including demographic and geographic data.
#### Contents:
|Column | Data Type | Description|
|---|---|---|
|customer_key|INTEGER|Surrogate key uniquely identifying customer record (Primary key)|
|customer_id|INTEGER|Unique numerical customer identifier|
|customer_number|TEXT|Alfanumeric customer identifier|
|first_name|TEXT|Customer's first name|
|last_name|TEXT|Customer's last name|
|country|TEXT|Customer's country of residence (country code)|
|marital_status|TEXT|Customer's marital status|
|gender|TEXT|Customer's gender|
|birthdate|DATE|Customer's birthdate (YYYY-MM-DD)|
|create_date|DATE|Customer record creation date (YYYY-MM-DD)|

#### Business Decisions:
- Some customers had a different gender recorded in the CRM system than in
  the ERP system. Since the two disagreed, we chose to trust the CRM
  record as the primary source, only using the ERP value when CRM had no
  answer at all.
- Customer records with no matching ERP data (birthdate, country) will
  simply show that information as missing, rather than being excluded.
### Dim_products

#### Purpose:
Store product details.
#### Contents:
|Column | Data Type | Description|
|---|---|---|
|product_key|INTEGER|Surrogate key uniquely identifying product (Primary key)
|product_id|INTEGER|Unique numerical product identifier|
|product_number|TEXT| Alfanumeric product identifier|
|product_category|TEXT| Product category|
|product_saleskey|TEXT| Product key segment used to join against `crm_sales_details.sls_prd_key`|
|product_subcategory|TEXT|Product category|
|product_name|TEXT|Product name|
|product_line|TEXT|Product line code|
|maintenance|BOOLEAN| Whether the product requires maintenance |
|cost|DECIMAL|Cost|
|start_date|DATE| Date this product version became active (YYYY-MM-DD)|

#### Business Decisions:
- Products can have several past versions on record (e.g. price changes
  over time). This view only shows each product's current version — past
  versions are not included here.
- Some products don't have a known cost or product line on record; these
  are shown as missing or "N/A" rather than guessed at.