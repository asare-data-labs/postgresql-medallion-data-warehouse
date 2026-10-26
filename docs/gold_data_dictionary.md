# Gold Layer Data Dictionary

This document provides the metadata reference for the **Gold Layer** of the PostgreSQL Medallion Architecture data warehouse. The Gold layer houses business-ready dimensional models (star schema) optimized for analytics, reporting, and BI tool consumption (e.g., Power BI, Tableau).

---

## 1. Dimension: `gold.dim_customers`

### Overview & Purpose
* **Overview:** Integrates customer demographic, geographic, and administrative data sourced from the CRM and ERP systems.
* **Purpose:** Acts as the master customer dimension for analyzing sales performance, customer segmentation, and demographic distribution. It establishes CRM as the primary source of truth while gracefully falling back to ERP demographic attributes.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `customer_key` | BIGINT | Surrogate key generated via window function (`ROW_NUMBER`) to uniquely identify each customer record. |
| `customer_id` | INT | Natural source key from the CRM system (`cst_id`). |
| `customer_number` | VARCHAR | Unique business customer identifier or code (`cst_key`). |
| `first_name` | VARCHAR | Customer's first name. |
| `last_name` | VARCHAR | Customer's last name. |
| `country` | VARCHAR | Customer country of residence, integrated from ERP location records (`la.cntry`). |
| `marital_status` | VARCHAR | Customer marital status (e.g., Single, Married). |
| `gender` | VARCHAR | Standardized gender field; prioritizes CRM data with fallback to ERP demographics. |
| `birthdate` | DATE | Customer date of birth, sourced from ERP customer records (`ca.bdate`). |
| `create_date` | DATE | Timestamp indicating when the customer record was originally created in the CRM source. |

---

## 2. Dimension: `gold.dim_products`

### Overview & Purpose
* **Overview:** Contains current active product definitions, catalog classifications, pricing, and product line attributes by joining CRM product information with ERP product categories.
* **Purpose:** Provides descriptive attributes for products in sales analytics. Filters out historical or expired product lines (`prd_end_dt IS NULL`) to ensure reports evaluate active inventory.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `product_key` | BIGINT | Surrogate key generated via window function to uniquely identify each product. |
| `product_id` | INT | Natural source key from the CRM product table (`prd_id`). |
| `product_number` | VARCHAR | Unique SKU or business product identifier (`prd_key`). |
| `product_name` | VARCHAR | Full descriptive name of the product (`prd_nm`). |
| `category_id` | VARCHAR | Foreign key linking the product to its category classification. |
| `category` | VARCHAR | High-level product category name sourced from the ERP category catalog (`pc.cat`). |
| `subcategory` | VARCHAR | Detailed product subcategory name (`pc.subcat`). |
| `maintenance` | VARCHAR | Maintenance requirement or type classification for the product (`pc.maintenance`). |
| `cost` | NUMERIC | Standard acquisition or production cost of the product (`prd_cost`). |
| `product_line` | VARCHAR | Product line classification (e.g., Road, Mountain, Touring). |
| `start_date` | DATE | Effective start date when the product version became active (`prd_start_dt`). |

---

## 3. Fact Table: `gold.fact_sales`

### Overview & Purpose
* **Overview:** Stores transactional sales line items, linking operational metrics (revenue, quantity, price) to dimension tables via surrogate keys.
* **Purpose:** Serves as the core analytical engine for financial reporting, trend analysis, and volume calculations, ensuring historical transactions are preserved even if dimension metadata undergoes updates.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `order_number` | VARCHAR | Unique sales order transaction number (`sls_ord_num`). |
| `product_key` | BIGINT | Surrogate foreign key connecting the transaction to `gold.dim_products`. |
| `customer_key` | BIGINT | Surrogate foreign key connecting the transaction to `gold.dim_customers`. |
| `order_date` | DATE | Date the sales order was officially placed (`sls_order_dt`). |
| `shipping_date` | DATE | Date the order was fulfilled and shipped (`sls_ship_dt`). |
| `due_date` | DATE | Date the order payment or delivery was due (`sls_due_dt`). |
| `sales_amount` | NUMERIC | Total revenue generated for the line item (`sls_sales`). |
| `quantity` | INT | Total units purchased in the transaction line item (`sls_quantity`). |
| `price` | NUMERIC | Unit selling price of the product at the time of transaction (`sls_price`). |
