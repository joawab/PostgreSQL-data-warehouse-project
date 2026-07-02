/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.

HOW TO RUN (PostgreSQL / pgAdmin):
    This script CANNOT be run all at once. It must be run in two separate steps,
    because CREATE DATABASE cannot execute inside a transaction block, and the
    schema statements must run while connected to the new database.

    STEP 1 — while connected to any existing database (e.g. 'postgres'):
        Run the DROP DATABASE and CREATE DATABASE statements below.

    STEP 2 — open a NEW Query Tool connected specifically to 'DataWarehouse',
        then run the three CREATE SCHEMA statements below.
=============================================================
*/

-- ============================================================
-- STEP 1: run while connected to 'postgres' (or any other database)
-- ============================================================

-- Drop and recreate the 'DataWarehouse' database
DROP DATABASE IF EXISTS "DataWarehouse";

-- Create the 'DataWarehouse' database
CREATE DATABASE "DataWarehouse";


-- ============================================================
-- STEP 2: run while connected to 'DataWarehouse'
-- ============================================================

CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;