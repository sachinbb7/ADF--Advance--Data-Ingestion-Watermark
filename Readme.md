# 🛒 QuickBasket — Azure SQL to ADLS Data Pipeline

## 📌 Project Overview

This repository contains an **Azure Data Factory (ADF)** pipeline developed to move QuickBasket source data from **Azure SQL Database to Azure Data Lake Storage Gen2 (ADLS)**.

The pipeline follows a **metadata-driven approach**. Instead of manually creating an independent pipeline for every SQL table, ADF dynamically:

* Retrieves source tables from Azure SQL
* Filters unwanted ETL/control tables
* Iterates through the required source tables
* Uses a Switch activity to apply table-specific processing
* Copies data dynamically into ADLS
* Implements incremental loading for the `orders` table
* Maintains a High-Water Mark (HWM) in Azure SQL
* Generates dynamic ADLS filenames using the latest source timestamp

---

# 🏗️ Architecture

```text
                     Azure SQL Database
                             │
                             ▼
                   Lookup for sql tables
                             │
                             ▼
                          Filter
                             │
                             ▼
                          ForEach
                             │
                             ▼
                           Switch
          ┌──────────────────┼──────────────────┐
          │                  │                  │
          ▼                  ▼                  ▼
      customers           products       payments_returns
          │                  │                  │
          ▼                  ▼                  ▼
         Copy               Copy               Copy

                             │
                             ▼
                           orders
                             │
                             ▼
                   Previous- orders_HWM
                             │
                             ▼
              Lookup for new record max date
                             │
                             ▼
                     copy orders data
                             │
                             ▼
                   orders- last updated
                             │
                             ▼
                    Update - orders_HWM
                             │
                             ▼
                         ADLS Gen2
```

---

# 🔧 Technologies Used

| Technology                   | Purpose                                   |
| ---------------------------- | ----------------------------------------- |
| Azure Data Factory           | Pipeline orchestration                    |
| Azure SQL Database           | Source database                           |
| Azure Data Lake Storage Gen2 | Destination/raw storage                   |
| SQL                          | Metadata and incremental extraction       |
| Lookup Activity              | Source table and watermark retrieval      |
| Filter Activity              | Exclude ETL/control tables                |
| ForEach Activity             | Dynamically iterate through source tables |
| Switch Activity              | Apply table-specific processing           |
| Copy Activity                | Transfer Azure SQL data to ADLS           |
| Watermark Table              | Track successfully processed data         |

---

# 📊 Source Tables

The pipeline currently processes the following QuickBasket tables:

```text
customers
products
payments_returns
orders
```

An ETL watermark/control table is also maintained in Azure SQL but is excluded from normal source ingestion.

---

# 1️⃣ Dynamic SQL Table Discovery

The pipeline begins with:

```text
Lookup for sql tables
```

This Lookup Activity retrieves the available tables from the Azure SQL `dbo` schema.

The purpose is to avoid manually maintaining the list of source tables inside ADF.

Conceptually:

```text
Azure SQL
    ↓
Lookup for sql tables
    ↓
customers
products
payments_returns
orders
etl_watermark
```

---

# 2️⃣ Filtering ETL Tables

The Lookup output is passed to the:

```text
Filter
```

activity.

The Filter removes ETL/control tables that should not be copied to ADLS.

The resulting business-table collection contains:

```text
customers
products
payments_returns
orders
```

---

# 3️⃣ Dynamic Processing Using ForEach

The filtered output is passed to a:

```text
ForEach
```

activity.

The ForEach dynamically processes each table returned by the previous activities.

The current table is referenced using:

```text
@item().TABLE_NAME
```

and the schema can be accessed using:

```text
@item().TABLE_SCHEMA
```

Therefore, the pipeline does not need a separate top-level pipeline for every SQL source table.

---

# 4️⃣ Switch-Based Table Routing

Inside the ForEach, a **Switch Activity** routes each source table to its respective processing branch.

Current Switch cases:

```text
customers
products
payments_returns
orders
```

The architecture is:

```text
                     ForEach
                        │
                        ▼
                      Switch
       ┌────────────────┼─────────────────┐
       │                │                 │
       ▼                ▼                 ▼
   customers         products      payments_returns
       │                │                 │
      Copy             Copy              Copy

                        │
                        ▼
                      orders
                        │
                        ▼
                Incremental Logic
```

---

# 👥 Customers

The `customers` Switch case currently copies customer data from Azure SQL into ADLS.

Customer data includes:

```text
customer_id
customer_name
city
membership
```

The source intentionally contains data-quality scenarios such as duplicate customers, missing city information, and leading/trailing spaces that can later be handled in the transformation layer.

---

# 📦 Products

The `products` branch moves product reference data from Azure SQL into ADLS.

Product information includes:

```text
product_id
product_name
brand
category
store_id
mrp
```

Products are currently treated as reference/master data.

---

# 💳 Payments & Returns

The `payments_returns` branch moves payment and return information from Azure SQL into ADLS.

The source contains:

```text
order_id
payment_method
payment_status
return_status
refund_amount
```

Incremental processing can later be introduced when a reliable source change timestamp is available.

---

# 📈 Orders — Incremental Loading

Unlike the other source tables, `orders` currently implements an **incremental loading mechanism**.

The incremental logic is based on:

```text
last_updated_date
```

The Orders branch currently contains the following activities:

```text
Previous- orders_HWM
        ↓
Lookup for new record max date
        ↓
copy orders data
        ↓
orders- last updated
        ↓
Update - orders_HWM
```

---

# 🌊 High-Water Mark

HWM stands for **High-Water Mark**.

It represents the latest timestamp up to which Orders data has previously been processed.

The watermark information is maintained in:

```text
etl_watermark
```

This prevents the pipeline from copying the complete Orders table during every execution.

---

# 🔎 Previous Orders HWM

The first activity in the Orders incremental branch is:

```text
Previous- orders_HWM
```

The current SQL query used is:

```sql
SELECT MAX(last_processed_timestamp) AS prev_wm
FROM etl_watermark;
```

The result is exposed to subsequent ADF activities as:

```text
@activity('Previous- orders_HWM').output.firstRow.prev_wm
```

For example:

```text
prev_wm
-----------------------
2026-08-17 09:40:00
```

This represents the previous processing boundary.

---

# 🕒 Lookup for New Record Max Date

The next activity is:

```text
Lookup for new record max date
```

The source table and schema are dynamically obtained from the current ForEach item.

The SQL query is:

```sql
SELECT MAX(last_updated_date) AS latest_updated_date
FROM @{item().TABLE_SCHEMA}.@{item().TABLE_NAME}
```

Because the current Switch case is `orders`, this dynamically resolves to the Orders source table.

For example:

```text
TABLE_SCHEMA = dbo
TABLE_NAME   = orders
```

Conceptually, ADF executes:

```sql
SELECT MAX(last_updated_date) AS latest_updated_date
FROM dbo.orders;
```

Suppose the result is:

```text
2026-08-18 10:30:00
```

This represents the latest available Orders timestamp at the time of pipeline execution.

---

# 📥 Copy Orders Data

The activity:

```text
copy orders data
```

performs the incremental extraction.

The current source query is:

```sql
SELECT *
FROM dbo.orders
WHERE last_updated_date >
'@{activity('Previous- orders_HWM').output.firstRow.prev_wm}'
```

For example, if:

```text
Previous HWM =
2026-08-17 09:40:00
```

ADF effectively extracts:

```sql
SELECT *
FROM dbo.orders
WHERE last_updated_date > '2026-08-17 09:40:00';
```

Therefore, records already processed in previous runs are excluded.

---

# 🧠 Why `last_updated_date` Is Used

The incremental load is based on:

```text
last_updated_date
```

instead of:

```text
order_date
```

This allows the pipeline to process late-arriving or subsequently updated orders.

For example:

```text
order_id           = QB1025
order_date         = 2026-08-16
last_updated_date  = 2026-08-18 09:20
```

Even though the order belongs to August 16, it will still be picked up if the previous HWM is earlier than:

```text
2026-08-18 09:20
```

---

# 🆕 Orders Last Updated

After the Orders Copy Activity, the pipeline executes:

```text
orders- last updated
```

The query currently used is:

```sql
SELECT MAX(last_updated_date) AS nwm
FROM dbo.orders;
```

This retrieves the latest `last_updated_date` from the source after processing.

The result represents the **new watermark**.

For example:

```text
nwm
-----------------------
2026-08-18 10:30:00
```

---

# 💾 Update Orders HWM

After successful Orders processing, the pipeline executes:

```text
Update - orders_HWM
```

The new watermark is stored in the SQL watermark table.

Conceptually:

```text
Previous HWM
2026-08-17 09:40
        ↓
Incremental Orders processed
        ↓
New MAX(last_updated_date)
2026-08-18 10:30
        ↓
Update / Log Watermark
        ↓
Next execution starts after
2026-08-18 10:30
```

This allows each subsequent pipeline execution to continue from the previous successful processing point.

---

# 📁 Dynamic Orders File Naming

The Orders filename in ADLS is generated dynamically using the latest `last_updated_date`.

The current expression is:

```text
@concat(
    item().TABLE_NAME,
    '_',
    formatDateTime(
        activity('Lookup for new record max date')
            .output.firstRow.latest_updated_date,
        'yyyyMMdd'
    ),
    '.csv'
)
```

For example:

```text
TABLE_NAME =
orders

latest_updated_date =
2026-08-18 10:30:00
```

ADF generates:

```text
orders_20260818.csv
```

Therefore, the file date comes from the actual source data rather than simply using the pipeline execution time.

---

# 📂 ADLS Output

The destination can follow a structure such as:

```text
quickbasket/
│
└── raw/
    │
    ├── customers/
    │   └── customers.csv
    │
    ├── products/
    │   └── products.csv
    │
    ├── payments_returns/
    │   └── payments_returns.csv
    │
    └── orders/
        ├── orders_20260817.csv
        └── orders_20260818.csv
```

Orders are date-stamped based on the maximum source `last_updated_date`.

---

# 🔄 Complete Orders Incremental Example

Assume the watermark table contains:

```text
Previous HWM:
2026-08-17 10:00:00
```

The Orders source contains:

```text
Order      last_updated_date
---------  -----------------------
QB1021     2026-08-17 09:30:00
QB1022     2026-08-17 10:00:00
QB1023     2026-08-18 08:15:00
QB1024     2026-08-18 10:30:00
```

The Copy query applies:

```text
last_updated_date > 2026-08-17 10:00:00
```

Therefore:

```text
QB1021 ❌ Already processed

QB1022 ❌ Equal to HWM

QB1023 ✅ Incremental record

QB1024 ✅ Incremental record
```

The latest source timestamp becomes:

```text
2026-08-18 10:30:00
```

ADF creates:

```text
orders_20260818.csv
```

and the new watermark is recorded for the next execution.

---

# ⚠️ Watermark Failure Handling

The watermark must only advance after the Orders data has been successfully copied.

The intended dependency is:

```text
copy orders data
       │
       │ Success
       ▼
orders- last updated
       │
       ▼
Update - orders_HWM
```

If the Copy Activity fails:

```text
copy orders data ❌
       │
       X
Update HWM does NOT execute
```

This prevents ADF from skipping unprocessed Orders during the next run.

---

# 🚀 Current Pipeline Flow

```text
Azure SQL
    │
    ▼
Lookup for sql tables
    │
    ▼
Filter
    │
    ▼
ForEach
    │
    ▼
Switch
    │
    ├── customers
    │      └── Copy → ADLS
    │
    ├── products
    │      └── Copy → ADLS
    │
    ├── payments_returns
    │      └── Copy → ADLS
    │
    └── orders
           │
           ├── Previous- orders_HWM
           │
           ├── Lookup for new record max date
           │
           ├── copy orders data
           │
           ├── orders- last updated
           │
           └── Update - orders_HWM
                        │
                        ▼
                     ADLS
```

---

# ✅ Concepts Implemented

This project currently demonstrates:

* Azure SQL → ADLS ingestion
* Azure Data Factory orchestration
* Metadata-driven source discovery
* Dynamic schema/table references
* Filter Activity
* ForEach Activity
* Switch Activity
* Dynamic table routing
* Copy Activity
* Parameterized datasets
* Dynamic ADLS file naming
* Incremental Orders loading
* High-Water Mark implementation
* SQL watermark logging
* Late-arriving Orders handling
* Source-driven file dates
* Success-dependent watermark updates

---

# 🔮 Planned Enhancements

The current implementation establishes the ingestion and incremental-loading framework.

Future development can include:

* Incremental loading for Customers
* Incremental loading for Payments/Returns
* Metadata-driven load types (`FULL` / `INCREMENTAL`)
* Mapping Data Flow transformations
* Customer/Product enrichment
* Data-quality validation
* Rejected-record handling
* Curated ADLS layer
* Store/Product business aggregations
* Pipeline execution logging
* Azure Monitor failure alerts

---

## 📌 Summary

The QuickBasket pipeline currently uses a metadata-driven ADF architecture to discover Azure SQL source tables and dynamically route them through appropriate ingestion logic.

Reference/master datasets are copied to ADLS, while the Orders dataset uses a **High-Water Mark based incremental-loading mechanism**.

The Orders implementation tracks the previously processed timestamp, identifies the latest available `last_updated_date`, extracts only records newer than the previous watermark, dynamically creates a dated ADLS file, and updates the watermark after successful processing.

This architecture provides a reusable foundation for extending incremental processing to additional QuickBasket datasets.
