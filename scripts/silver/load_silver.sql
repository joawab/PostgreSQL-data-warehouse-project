/*
=============================================================
Load Script: Transform and Load Silver Tables
=============================================================
Script Purpose:
    This script transforms and loads data from the 'bronze' schema into 
    the 'silver' schema, based on findings from bronze-layer profiling.
=============================================================
*/

-- =========================================================
-- crm_cust_info
-- =========================================================

/*
Findings from bronze profiling:
- Duplicate cst_id/cst_key rows exist; most recent record (by 
  cst_create_date) is the complete one.
- Some rows are entirely blank aside from cst_key.
- consisten cst_marital_status and cst_gndr.
- cst_create_date is a clean, valid date field.
*/

TRUNCATE TABLE silver.crm_cust_info;

INSERT INTO silver.crm_cust_info 
WITH
	deduplication AS (
		SELECT
			*,
			ROW_NUMBER() OVER (
				PARTITION BY
					cst_id
				ORDER BY
					cst_create_date DESC
			) AS last_entry
		FROM
			bronze.crm_cust_info
		WHERE
			cst_id IS NOT NULL
	)
SELECT
	CAST(cst_id AS INTEGER),
	TRIM(cst_key) AS cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	TRIM(cst_marital_status) AS cst_marital_status,
	TRIM(cst_gndr) AS cst_gndr,
	CAST(cst_create_date AS date)
	FROM
	deduplication
WHERE
	last_entry = 1;

-- deduplicated, trimmed, tested agains any null values (except null cst_gndr: these are expected)

-- =========================================================
-- crm_prd_info
-- =========================================================
/*
Findings from bronze profiling:
- prd_key duplicates exist, associated with prd_start_dt/prd_end_dt — 
  possible historical versioning, but a start/end date swap is also 
  suspected and unresolved.
- prd_cost has nulls with no reliable imputation pattern (price/size 
  theory tested and disproven).
- prd_line has nulls with no fillable sibling values.
- prd_key contains erp_px_cat_g1v2.id as a substring (confirmed).
*/


-- =========================================================
-- crm_sales_details
-- =========================================================
/*
Findings from bronze profiling:
- sls_order_dt contains placeholder '0' values and numeric values 
  resembling unconverted Excel serial dates.
- sls_ship_dt / sls_due_dt not yet checked for the same pattern.
- sls_sales has nulls and a few negative values; both misalign with 
  positive sls_price. A quantity x price relationship was observed but 
  not verified as the correct fix.
- sls_price has some zero values.
- sls_ord_num is not unique by design (multi-line orders).
*/


-- =========================================================
-- erp_cust_az12
-- =========================================================
/*
Findings from bronze profiling:
- Completeness/consistency checks not yet finished for this table.
- gen values likely need to align with crm_cust_info.cst_gndr, since 
  both may describe the same customer attribute.
- cid is expected to correspond to crm_cust_info.cst_key.
*/


-- =========================================================
-- erp_loc_a101
-- =========================================================
/*
Findings from bronze profiling:
- Completeness/consistency checks not yet finished for this table.
- cid is expected to correspond to crm_cust_info.cst_key.
*/


-- =========================================================
-- erp_px_cat_g1v2
-- =========================================================
/*
Findings from bronze profiling:
- maintenance expected to be a clean Yes/No field, to be cast to BOOLEAN.
- id corresponds to a substring within crm_prd_info.prd_key (confirmed).
*/