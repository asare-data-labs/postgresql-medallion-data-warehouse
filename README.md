# Enterprise PostgreSQL Data Warehouse & Analytics Platform

This project delivers an end-to-end data pipeline built on **PostgreSQL**, utilizing a **Medallion Architecture** (Bronze, Silver, Gold) to process raw data into production-ready analytical models and reporting views.

---

## Module 1: Data Warehousing (Engineering)

### 1. Introduction
The core data warehousing engine manages raw data ingestion, transformation, and dimensional storage. Built entirely inside PostgreSQL using native `PL/pgSQL` procedural logic, it provides an isolated, reliable pipeline for scalable data processing.

### 2. Requirements
* **Database Engine:** PostgreSQL 14+
* **Administration Tools:** DBeaver or `psql` CLI
* **Execution Environment:** Local installation or Docker container

### 3. Objective
* Implement operational isolation across Bronze (Staging), Silver (Cleansed), and Gold (Dimensional) layers.
* Automate data cleansing, type casting, NULL handling, and deduplication using stored procedures.
* Model raw transactional data into high-performance Star-Schema structures (Fact and Dimension tables).

### 4. Specification
* **Bronze Layer (`bronze` schema):** Raw data staging maintaining source structure and append-only metadata.
* **Silver Layer (`silver` schema):** Cleansed and standardized entities enforcing business validation rules and constraints.
* **Gold Layer (`gold` schema):** Dimensional models featuring surrogate primary keys and enforced foreign key relationships.

---

## Module 2: Analytics & Reporting (Data Analytics)

### 1. Introduction
The analytics module exposes curated Gold-layer models to reporting tools and stakeholders. It focuses on pre-aggregated views and query performance to support fast, complex business decision-making.

### 2. Requirements
* **Access Level:** Read-only access to the `gold` schema
* **Visualization Tools:** Compatible with Power BI, Tableau, Metabase, or standard SQL reporting interfaces

### 3. Objective
* Deliver key performance indicators (KPIs) and business metrics with low-latency query execution.
* Reduce reporting load on base tables using materialized views and targeted indexing.
* Provide clean, self-serve data models for non-technical business analysts.

### 4. Specification
* **Analytical Views:** Pre-joined summary views aggregating revenue, customer metrics, and dimensional trends.
* **Query Optimization:** Indexed foreign keys and optimized execution plans (`EXPLAIN ANALYZE`).
* **Data Integrity:** Verification tests ensuring zero duplicate facts and accurate metric calculations.

---

## Repository Structure

```text
postgresql-medallion-data-warehouse/
├── scripts/
│   ├── 01_schema_setup.sql       # Schema initialization
│   ├── 02_bronze_layer.sql       # Raw ingestion tables
│   ├── 03_silver_layer.sql       # Cleansed PL/pgSQL procedures
│   ├── 04_gold_layer.sql         # Fact & Dimension schema
│   └── 05_analytical_views.sql   # Pre-aggregated reporting views
├── tests/
│   └── data_quality_checks.sql   # Integrity validation scripts
└── README.md


Author & Brand
About Asare Data Labs
Asare Data Labs is an independent data engineering practice specializing in modern database architecture, performance tuning, and robust ETL/ELT pipelines using PostgreSQL and Python. Focused on delivering production-grade data infrastructure that scales cleanly for business intelligence and analytics.
•	GitHub: @asare-data-labs
•	Services: Data Warehousing, SQL Optimization, PL/pgSQL Pipeline Automation, Dimensional Modeling

License
This project is licensed under the MIT License - see the LICENSE file for details. You are free to use, modify, and distribute this codebase for personal or commercial projects.
