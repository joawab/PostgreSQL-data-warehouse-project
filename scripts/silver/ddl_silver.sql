/*
=============================================================
DDL Script: Create Silver Tables
=============================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist. Run this script to re-define the DDL structure of 
    the silver tables.

    Silver layer contains values iwth correct formats assigned.
=============================================================
*/

-- ==========================================================
-- CRM source tables
-- ==========================================================

DROP TABLE IF EXISTS silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info (
	cst_id 				INT,
	cst_key 			TEXT,
	cst_firstname 		TEXT,
	cst_lastname 		TEXT,
	cst_marital_status 	TEXT,
	cst_gndr 			TEXT,
	cst_create_date 	DATE
);

DROP TABLE IF EXISTS silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (
	prd_id 			INT,
	prd_key 		TEXT,
	prd_nm 			TEXT,
	prd_cost 		DECIMAL(10,2),
	prd_line 		TEXT,
	prd_start_dt 	DATE,
	prd_end_dt 		DATE
);

DROP TABLE IF EXISTS silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
	sls_ord_num 	TEXT,
	sls_prd_key 	TEXT,
	sls_cust_id 	INT,
	sls_order_dt 	DATE,
	sls_ship_dt 	DATE,
	sls_due_dt 		DATE,
	sls_sales 		DECIMAL(10,2),
	sls_quantity 	INT,
	sls_price 		DECIMAL(10,2)
);

-- ==========================================================
-- ERP source tables
-- ==========================================================

DROP TABLE IF EXISTS silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12 (
	cid 	TEXT,
	bdate 	DATE,
	gen 	TEXT
);

DROP TABLE IF EXISTS silver.erp_loc_a101;

CREATE TABLE silver.erp_loc_a101 (
	cid 	TEXT,
	cntry 	TEXT
);

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;

CREATE TABLE silver.erp_px_cat_g1v2 (
	id 				TEXT,
	cat 			TEXT,
	subcat 			TEXT,
	maintenance 	BOOLEAN
);

