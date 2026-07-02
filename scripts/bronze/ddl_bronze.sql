/*
=============================================================
DDL Script: Create Bronze Tables
=============================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist. Run this script to re-define the DDL structure of 
    the bronze tables.

    Bronze tables store raw source data exactly as extracted from the CSV files, 
    with no transformation. All columns are TEXT to avoid failed imports from 
    messy/inconsistent source data — type conversion and cleaning happens in 
    the silver layer.
=============================================================
*/

-- ==========================================================
-- CRM source tables
-- ==========================================================

DROP TABLE IF EXISTS bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info (
cst_id 				TEXT,
cst_key 			TEXT,
cst_firstname 		TEXT,
cst_lastname 		TEXT,
cst_marital_status 	TEXT,
cst_gndr 			TEXT,
cst_create_date 	TEXT
);

DROP TABLE IF EXISTS bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info (
prd_id 			TEXT,
prd_key 		TEXT,
prd_nm 			TEXT,
prd_cost 		TEXT,
prd_line 		TEXT,
prd_start_dt 	TEXT,
prd_end_dt 		TEXT
);

DROP TABLE IF EXISTS bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
sls_ord_num 	TEXT,
sls_prd_key 	TEXT,
sls_cust_id 	TEXT,
sls_order_dt 	TEXT,
sls_ship_dt 	TEXT,
sls_due_dt 		TEXT,
sls_sales 		TEXT,
sls_quantity 	TEXT,
sls_price 		TEXT

);

-- ==========================================================
-- ERP source tables
-- ==========================================================

DROP TABLE IF EXISTS bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
cid 	TEXT,
bdate 	TEXT,
gen 	TEXT
);

DROP TABLE IF EXISTS bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
cid 	TEXT,
cntry 	TEXT
);

DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2 (
ID 				TEXT,
cat 			TEXT,
subcat 			TEXT,
maintenance 	TEXT
);

