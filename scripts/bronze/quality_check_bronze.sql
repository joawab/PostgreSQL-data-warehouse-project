/* 
This script role is used to check data quality of all tables. Each table check has following steps volume, uniqueness, completeness, consistency. Actual data cleaning will happen in Silver Layer, this is only for documentation purposes.
*/
-- =========================================================
-- crm_cust_info check
-- =========================================================
-- =========================================================
-- volume check
-- =========================================================
-- no anomalies found
SELECT
	COUNT(*)
FROM
	bronze.crm_cust_info;

-- =========================================================
-- uniqueness check
-- =========================================================
-- duplicates in cst_id. Check for duplicate cst_id, cst_key alligns with cst_id. Next steps in Silver is keeping the newest row based on cst_create_date
WITH
	duplicate_cst_id AS (
		SELECT
			cst_id,
			COUNT(cst_id) AS cust_id_count
		FROM
			bronze.crm_cust_info
		GROUP BY
			cst_id
		HAVING
			COUNT(cst_id) > 1
	)
SELECT
	*
FROM
	bronze.crm_cust_info
WHERE
	cst_id IN (
		SELECT
			cst_id
		FROM
			duplicate_cst_id
	)
ORDER BY
	cst_id,
	cst_create_date DESC;

-- check for more duplicates in cst_key, alligns with cst_id duplicates
WITH
	duplicate_cst_key AS (
		SELECT
			cst_key,
			COUNT(cst_key) AS cust_key_count
		FROM
			bronze.crm_cust_info
		GROUP BY
			cst_key
		HAVING
			COUNT(cst_key) > 1
	)
SELECT
	*
FROM
	bronze.crm_cust_info
WHERE
	cst_key IN (
		SELECT
			cst_key
		FROM
			duplicate_cst_key
	)
ORDER BY
	cst_key,
	cst_create_date DESC;

-- =========================================================
-- completeness check
-- =========================================================
-- identified nulls in cst_id, all columns apart cst_key are blank, next step for Silver: delete rows
SELECT
	*
FROM
	bronze.crm_cust_info
WHERE
	cst_id IS NULL;

-- no nulls in cst_key
SELECT
	*
FROM
	bronze.crm_cust_info
WHERE
	cst_key IS NULL;

-- identified nulls in cst_firstname, mostly blank rows, some are duplicates from cst_id. Safe to delete in Silver
SELECT
	*
FROM
	bronze.crm_cust_info
WHERE
	cst_firstname IS NULL;

-- identified nulls in cst_lastname, mostly blank rows, some are duplicates from cst_id and cst_key. Safe to delete in Silver
SELECT
	*
FROM
	bronze.crm_cust_info
WHERE
	cst_lastname IS NULL;

-- cst_marital_status seems to be mandatory field as only nulls identified are in blank rows from cst_id and cst_key check. No further steps as these will be removed when clearing cst_id and cst_key
SELECT
	*
FROM
	bronze.crm_cust_info
WHERE
	cst_marital_status IS NULL;

-- based on number of nulls this is not a mandatory column. No further actions
SELECT
	*
FROM
	bronze.crm_cust_info
WHERE
	cst_gndr IS NULL;

-- identified nulls in cst_create_date, all linked to null cst_id. No further action needed
SELECT
	*
FROM
	bronze.crm_cust_info
WHERE
	cst_create_date IS NULL;

-- =========================================================
-- consistency check
-- =========================================================
-- cst_marital_status has consistent values
SELECT DISTINCT
	cst_marital_status
FROM
	bronze.crm_cust_info;

-- cst_gndr has consistent values
SELECT DISTINCT
	cst_gndr
FROM
	bronze.crm_cust_info;

-- cst_create_date has consistent length, next step checks formatting
SELECT
	LENGTH(cst_create_date)
FROM
	bronze.crm_cust_info
GROUP BY
	LENGTH(cst_create_date);

-- cst_create_date matches format xxxx-xx-xx
SELECT
	cst_create_date
FROM
	bronze.crm_cust_info
WHERE
	cst_create_date !~ '^\d{4}-\d{2}-\d{2}$';

-- consistent year values
SELECT
	MIN(
		CAST(
			SUBSTRING(
				cst_create_date
				FROM
					1 FOR 4
			) AS INTEGER
		)
	) AS min_year,
	MAX(
		CAST(
			SUBSTRING(
				cst_create_date
				FROM
					1 FOR 4
			) AS INTEGER
		)
	) AS max_year
FROM
	bronze.crm_cust_info;

-- consistent month values 
SELECT DISTINCT
	CAST(
		SUBSTRING(
			cst_create_date
			FROM
				6 FOR 2
		) AS INTEGER
	) AS MONTH
FROM
	bronze.crm_cust_info
WHERE
	CAST(
		SUBSTRING(
			cst_create_date
			FROM
				6 FOR 2
		) AS INTEGER
	) < 1
	OR CAST(
		SUBSTRING(
			cst_create_date
			FROM
				6 FOR 2
		) AS INTEGER
	) > 12;

-- consistent day value
SELECT DISTINCT
	CAST(
		SUBSTRING(
			cst_create_date
			FROM
				9 FOR 2
		) AS INTEGER
	) AS DAY
FROM
	bronze.crm_cust_info
WHERE
	CAST(
		SUBSTRING(
			cst_create_date
			FROM
				9 FOR 2
		) AS INTEGER
	) < 1
	OR CAST(
		SUBSTRING(
			cst_create_date
			FROM
				9 FOR 2
		) AS INTEGER
	) > 31
ORDER BY
	DAY ASC;

-- ==========================================================
-- crm_prd_info check
-- =========================================================
-- =========================================================
-- volume check
-- =========================================================
-- no anomalies
SELECT
	COUNT(*)
FROM
	bronze.crm_prd_info
	-- =========================================================
	-- uniqueness check
	-- =========================================================
	-- no duplicates found in crm_prd_info
SELECT
	COUNT(*)
FROM
	bronze.crm_prd_info
GROUP BY
	prd_id
ORDER BY
	COUNT(*) DESC;

-- multiple duplicates in prd_key
/* 
Further investigation needed: prd_start_dt seems to be switched with prd_end_dt except the one with null value in prd_end_dt. Deferred to Silver for handling, not a bronze-stage defect
*/
WITH
	duplicate_prd_key AS (
		SELECT
			prd_key,
			COUNT(*)
		FROM
			bronze.crm_prd_info
		GROUP BY
			prd_key
		HAVING
			COUNT(*) > 1
		ORDER BY
			COUNT(*) DESC
	)
SELECT
	*
FROM
	bronze.crm_prd_info
WHERE
	prd_key IN (
		SELECT
			prd_key
		FROM
			duplicate_prd_key
	);

-- prd_id and prd_key are the only columns expected to be unique (business/system keys).
-- Remaining columns are attributes, not identifiers - uniqueness check not applicable.
-- =========================================================
-- completeness check
-- =========================================================
-- no nulls in prd_id
SELECT
	*
FROM
	bronze.crm_prd_info
WHERE
	prd_id IS NULL;

-- no nulls in prd_key
SELECT
	*
FROM
	bronze.crm_prd_info
WHERE
	prd_key IS NULL;

-- no nulls in prd_nm
SELECT
	*
FROM
	bronze.crm_prd_info
WHERE
	prd_nm IS NULL;

/*
Identified nulls in prd_cost (e.g. size 58 variants). Initial hypothesis that prd_cost is correlated with size didn't hold. Deffered to Silver, needs further investigation on actual pattern.
*/
SELECT
	*
FROM
	bronze.crm_prd_info
WHERE
	prd_cost IS NULL;

SELECT
	*
FROM
	bronze.crm_prd_info
WHERE
	prd_nm LIKE '%HL Road Frame%'
ORDER BY
	prd_cost DESC;

-- multiple missing prd_line identified
SELECT
	*
FROM
	bronze.crm_prd_info
WHERE
	prd_line IS NULL;

/*
Investigate whether products with missing prd_line have a filled value elsewhere under the same prd_nm (would allow imputation from sibling rows)
*/
WITH
	missing_prd_line AS (
		SELECT DISTINCT
			prd_nm
		FROM
			bronze.crm_prd_info
		WHERE
			prd_line IS NULL
		ORDER BY
			prd_nm
	)
SELECT
	prd_nm,
	STRING_AGG(prd_line, ',')
FROM
	bronze.crm_prd_info
WHERE
	prd_nm IN (
		SELECT
			prd_nm
		FROM
			missing_prd_line
	)
GROUP BY
	prd_nm;

/*
Every group returned only nulls. No sibling rows with a filled
prd_line exist for these product names. Imputation not possible from
this table alone. Deferred to Silver: apply placeholder default, or
investigate cross-source lookup.
*/
-- no nulls identified in prd_start_dt
SELECT
	*
FROM
	bronze.crm_prd_info
WHERE
	prd_start_dt IS NULL;

-- multiple nulls identified in prd_end_dt
SELECT
	*
FROM
	bronze.crm_prd_info
WHERE
	prd_end_dt IS NULL;

-- null values correlated with prd_start_dt (2013-07-01 and 2003-07-01. Investigated on 2026-07-04)
SELECT
	prd_start_dt
FROM
	bronze.crm_prd_info
WHERE
	prd_end_dt IS NULL
GROUP BY
	prd_start_dt;

/*
Missing prd_end_dt may indicate ongoing production (most recent version of a product). Deferred to Silver: cross-check against other tables/columns before confirming this assumption. IMPORTANT: See earlier note on prd_start_dt/prd_end_dt possible date-swap issue — resolve that first, as it affects whether this assumption holds. 
*/
-- =========================================================
-- consistency check
-- =========================================================
-- no consistency issues on prd_id
SELECT
	prd_id
FROM
	bronze.crm_prd_info
WHERE
	prd_id !~ '^\d+$';

-- no anomalies identified in prd_key length

SELECT
	LENGTH(prd_key),
	COUNT (DISTINCT prd_key)
FROM
	bronze.crm_prd_info
GROUP BY
	LENGTH(prd_key);

-- spotcheck of prd_key for each length

SELECT 
	DISTINCT prd_key
FROM
	bronze.crm_prd_info
WHERE
	LENGTH(prd_key) = 13;

SELECT 
	DISTINCT prd_key
FROM
	bronze.crm_prd_info
WHERE
	LENGTH(prd_key) = 15;

SELECT 
	DISTINCT prd_key
FROM
	bronze.crm_prd_info
WHERE
	LENGTH(prd_key) = 16;

-- syntax check for prd_key 

SELECT
	prd_key
FROM
	bronze.crm_prd_info
WHERE
	LENGTH(prd_key) = 13
	AND prd_key !~ '^[A-Z]{2}-[A-Z]{2}-[A-Z]{2}-(\d{4}|[A-Z]{1}\d{3})$';

SELECT
	prd_key
FROM
	bronze.crm_prd_info
WHERE
	LENGTH(prd_key) = 15
	AND prd_key !~ '^[A-Z]{2}-[A-Z]{2}-[A-Z]{2}-([A-Z]{1}\d{3}|\d{4})-[A-Z]{1}$';

SELECT
	prd_key
FROM
	bronze.crm_prd_info
WHERE
	LENGTH(prd_key) = 16
	AND prd_key !~ '^[A-Z]{2}-[A-Z]{2}-[A-Z]{2}-[A-Z0-9]{4}-\d{2}$';

-- check for any prd_key not matching identified patterns

SELECT
	*
FROM
	bronze.crm_prd_info
WHERE
	NOT (
		(
			LENGTH(prd_key) = 13
			AND prd_key ~ '^[A-Z]{2}-[A-Z]{2}-[A-Z]{2}-(\d{4}|[A-Z]{1}\d{3})$'
		)
		OR (
			LENGTH(prd_key) = 15
			AND prd_key ~ '^[A-Z]{2}-[A-Z]{2}-[A-Z]{2}-([A-Z]{1}\d{3}|\d{4})-[A-Z]{1}$'
		)
		OR (
			LENGTH(prd_key) = 16
			AND prd_key ~ '^[A-Z]{2}-[A-Z]{2}-[A-Z]{2}-[A-Z0-9]{4}-\d{2}$'
		)
	)

	-- =========================================================
	-- crm_sales_details check
	-- =========================================================
	-- =========================================================
	-- volume check
	-- =========================================================
	-- =========================================================
	-- completeness check
	-- =========================================================
	-- =========================================================
	-- consistency check
	-- =========================================================
	-- =========================================================
	-- erp_cust_az12 check
	-- =========================================================
	-- =========================================================
	-- volume check
	-- =========================================================
	-- =========================================================
	-- completeness check
	-- =========================================================
	-- =========================================================
	-- consistency check
	-- =========================================================
	-- =========================================================
	-- erp_loc_a101 check
	-- =========================================================
	-- =========================================================
	-- volume check
	-- =========================================================
	-- =========================================================
	-- completeness check
	-- =========================================================
	-- =========================================================
	-- consistency check
	-- =========================================================
	-- =========================================================
	-- erp_px_cat_g1v2 check
	-- =========================================================
	-- =========================================================
	-- volume check
	-- =========================================================
	-- =========================================================
	-- completeness check
	-- =========================================================
	-- =========================================================
	-- consistency check
	-- =========================================================