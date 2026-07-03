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