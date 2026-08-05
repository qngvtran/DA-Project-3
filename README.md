# Olist Brazilian E-Commerce Performance Analytics

Data analytics project built on Olist's
real, publicly released e-commerce dataset: ~100,000 orders from a
Brazilian online marketplace, spanning customers, sellers, products,
payments, reviews, and geolocation across 8 linked relational tables.

> **Dataset:** [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

> 8 relational CSVs plus a category translation lookup, covering real orders from
> September 2016 to October 2018.

---

## Project goals

Business questions:

1. What's our overall revenue and order volume, and how is it trending?
2. How reliable is our delivery performance — what % of orders arrive
   late, and does it hurt customer satisfaction?
3. Which product categories, sellers, and states drive the most revenue?
4. How do customers prefer to pay, and does payment method relate to
   order value?
5. What does a full, production-style data model for this business
   actually look like — dimensions, facts, and the relationships between
   them?

---

## Tech stack

| Tool | Role in this project |
|---|---|
| **Python (Pandas)** — Google Colab | Clean 8 relational files, resolve a real key-granularity trap, aggregate a noisy 1M-row geolocation table, engineer delivery-performance metrics, build a full star schema |
| **PostgreSQL (SQL)** | 8-table relational schema with real foreign keys + 12 multi-table business queries, including window functions |
| **Excel** | Denormalized, analysis-ready KPI dashboard built from the star schema |
| **Power BI** | - |
| **GitHub** | Documentation and version control (this repo) |

---

## Project structure
```
.
├── data/
│   ├── raw/
│   └── processed/
│
├── excel/
│
├── images/     
│
├── notebooks/
│ 
├── sql/
│ 
└── README.md
```
---
## Workflow

### 1. Data cleaning (Python / Pandas, in Google Colab)

- Loads all 8 raw relational files plus the category translation lookup
- Builds `dim_customers`, `dim_sellers`
- Builds `dim_products`, merged with English category names, with a
  sensible fallback for two untranslated categories
- Builds `fact_orders` with engineered delivery-performance metrics
  (`delivery_days_actual`, `delivery_delta_days`, `is_late`)
- Builds `fact_order_items`, `fact_payments`, `fact_reviews`

### 2. SQL analysis (PostgreSQL)
- revenue and order trends
- delivery performance by state
- whether lateness hurts review scores
- top categories and sellers
- payment method breakdowns
- running revenue totals
- top category per state

### 3. Excel dashboard
- Orders sheet: a denormalized, order-grain view (99,441 rows) -
  purchase info, delivery metrics, payment summary, and review score all
  pre-joined for easy pivoting
- Seller Performance / Category Performance sheets: pre-aggregated
  summaries
- Dashboard sheet: KPI cards (Total Orders, Revenue, Late Delivery
  Rate, Avg Review Score), 4 formula-driven summary tables, and 4 charts

### 4. Power BI dashboard

---

## Key findings

- Total revenue: R$15.4M across 96,478 delivered orders (Sep 2016 – Oct 2018)
- 6.8% of delivered orders arrived after their estimated delivery date
- Orders delivered late average a noticeably lower review score than
  on-time orders - a clear, data-backed case for investing in delivery
  reliability
