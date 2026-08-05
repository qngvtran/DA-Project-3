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
| **Power BI** | A genuine multi-fact-table ("galaxy schema") data model across 5 report pages |
| **GitHub** | Documentation and version control (this repo) |

---

## Project structure
```
.
├── data/
│   ├── raw/                        # original, unmodified source data
│   │   └── add
│   └── processed/                  # cleaned output for SQL/Excel/Power BI
│
├── excel/
│   └── add      # KPI dashboard, formulas + charts
│
├── images/                     # screenshots
│
├── notebooks/
│   └── add           # Google Colab notebook
│ 
├── sql/
│   └── add         # 12 business-style questions 
│ 
└── README.md
```
---
## Workflow

### 1. Data cleaning (Python / Pandas, in Google Colab)

### 2. SQL analysis (PostgreSQL)

### 3. Excel dashboard

### 4. Power BI dashboard

---

## Key findings
