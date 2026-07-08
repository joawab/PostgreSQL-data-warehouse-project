/*
=============================================================
DDL Script: Create Gold Views
=============================================================
Script Purpose:
    This script creates views in the 'gold' schema, representing the final,
    business-ready star schema (dimension and fact views) built on top of
    the 'silver' layer.
=============================================================
*/

CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER () OVER (ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	loc.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE
		WHEN ci.cst_gndr IS NULL THEN caz.gen
		WHEN ci.cst_gndr = 'n/a' THEN caz.gen
		ELSE ci.cst_gndr
	END AS gender,
	caz.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM
	silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS caz 
	ON ci.cst_key = caz.cid
LEFT JOIN silver.erp_loc_a101 AS loc 
	ON ci.cst_key = loc.cid;

-- columns cst_gndr and gen contains contradictory data. In real life scenario this would be consulted with source team, in this case business decision is to keep CRM data (cst_gndr)

CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER () OVER (ORDER BY pi.prd_id) AS product_key,
	pi.prd_id AS product_id,
	pi.prd_key AS product_number,
	pi.cat_id AS product_category,
	pi.sls_prd_key AS product_saleskey,
	pc.subcat AS product_subcategory,
	pi.prd_nm AS product_name,
	pi.prd_line AS product_line,
	pc.maintenance AS maintenance,
	pi.prd_cost AS cost,
	pi.prd_start_dt AS start_date
FROM
	silver.crm_prd_info AS pi
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
	ON pi.cat_id = pc.id
WHERE pi.prd_end_dt IS NULL;

-- Business decision was to remove historical data.

CREATE VIEW gold.fact_sales AS
SELECT
	s.sls_ord_num AS order_number,
	p.product_key,
	c.customer_key,
	s.sls_order_dt AS order_date,
	s.sls_ship_dt AS ship_date,
	s.sls_due_dt AS due_date,
	s.sls_sales AS sales,
	s.sls_quantity AS quantity,
	s.sls_price AS price
FROM
	silver.crm_sales_details AS s
	LEFT JOIN gold.dim_products AS p 
	ON s.sls_prd_key = p.product_saleskey
	LEFT JOIN gold.dim_customers AS c
	ON s.sls_cust_id = c.customer_id;