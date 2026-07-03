/*
Adjust the base path below to match your local dataset location before running.
Expected folder structure: datasets/source_crm/ and datasets/source_erp/
*/
COPY bronze.crm_cust_info
FROM
	'/path/to/datasets/source_crm/cust_info.csv'
WITH
	(format csv, header TRUE, delimiter ',');

COPY bronze.crm_prd_info
FROM
	'/path/to/datasets/source_crm/prd_info.csv'
WITH
	(format csv, header TRUE, delimiter ',');

COPY bronze.crm_sales_details
FROM
	'/path/to/datasets/source_crm/sales_details.csv'
WITH
	(format csv, header TRUE, delimiter ',');

COPY bronze.erp_cust_az12
FROM
	'/path/to/datasets/source_erp/cust_az12.csv'
WITH
	(format csv, header TRUE, delimiter ',');

COPY bronze.erp_loc_a101
FROM
	'/path/to/datasets/source_erp/loc_a101.csv'
WITH
	(format csv, header TRUE, delimiter ',');

COPY bronze.erp_px_cat_g1v2
FROM
	'/path/to/datasets/source_erp/px_cat_g1v2.csv'
WITH
	(format csv, header TRUE, delimiter ',');