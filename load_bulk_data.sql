CREATE OR REPLACE DATABASE my_db;

USE DATABASE my_db;

CREATE TABLE public.sales (
OrderID NUMBER,
CustomerID NUMBER,
CustomerName STRING,
TransactionDate DATE
);

CREATE OR REPLACE SCHEMA external_stages;

CREATE OR REPLACE SCHEMA file_formats;

--AWS S3 Configuration (ACCOUNTADMIN has the privilege)
CREATE OR REPLACE STORAGE INTEGRATION s3_int
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::111222333444:role/snowflake_role'
STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-private/knoldus/load_data/');

--Create file format
CREATE OR REPLACE FILE FORMAT my_db.file_formats.my_csv_format
TYPE = CSV FIELD_DELIMITER = '|' SKIP_HEADER = 1 NULL_IF = ('NULL', 'null') EMPTY_FIELD_AS_NULL = TRUE;

--Create external stage
CREATE OR REPLACE STAGE my_db.external_stages.my_s3_ext_stage
STORAGE_INTEGRATION = s3_int
URL = 's3://snowflake-private/knoldus/load_data/'

--Copy command
COPY INTO my_db.public.sales FROM @my_db.external_stages.my_ext_stage
FILE_FORMAT = (FORMAT_NAME = 'my_csv_format')
ON_ERROR = 'skip_file';

SELECT * FROM my_db.public.sales LIMIT 20;