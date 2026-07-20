# Retail Sales & Customer Insights Platform
### A Walmart Supplier Analytics Dashboard for FreshNest Foods

**Tools:** Power BI · SQL · Excel · Python  
**Domain:** Consumer Packaged Goods (CPG) · Retail Analytics · Walmart Supplier  
**Dataset:** 98,000+ synthetic sales records · 2023–2024 · 4 retailers · 20 products  

---

## Business Problem

FreshNest Foods is a $180M Consumer Packaged Goods company supplying Walmart, Sam's Club, Target, and Kroger across the United States.

The CEO raised three urgent concerns heading into 2024 planning:

- **Sales grew only 1.5%** despite an **18% increase in promotional spend**
- **Profit margins are declining** due to rising COGS
- **Some Walmart regions are growing while others are shrinking** 

---

## My Role

I acted as the analyst hired to investigate the business problem end to end — from designing the data model to delivering actionable recommendations to the VP of Sales, Supply Chain, Finance, and the Walmart Customer Team.

---

## What I Built

### Power BI Dashboard (6 Pages)

| Page | Business Question Answered |
|---|---|
| Executive Summary | What happened this year overall? |
| Sales Performance | Where did sales grow and where did they decline? |
| Promotion Analysis | Which promotions actually worked? |
| Inventory Health | Which products are at risk of stockout? |
| Customer Insights | Which retailers and regions drive the most value? |
| Executive Recommendations | What should leadership do next? |

### SQL Analysis (25 Queries)
Business questions answered using SQL across 8 categories:
- Executive KPIs and YoY growth
- Product performance and category ranking
- Retailer and store performance
- Promotion ROI and sales lift
- Customer segmentation insights
- Inventory risk analysis
- Advanced analytics (CTEs, window functions, LAG, rolling averages)
- Executive recommendation support queries

---

## Key Findings

**1. Regional Performance Gap**
Southeast and South Central regions generate **38% of total revenue** and are growing fastest. Northeast is the weakest region and consistently underperforms — a store-level audit is recommended.

**2. Promotional Efficiency Problem**
Display Feature promotions drive the **highest revenue** of all promotion types. Digital Coupon events generate the least lift relative to spend. Promotional budget should be reallocated accordingly.

**3. Coffee Seasonal Opportunity**
Coffee revenue spikes **35% in winter months** but receives disproportionately low promotional investment during peak season. Shifting 10% of annual promo budget to Q4 Coffee could yield significant incremental revenue.

**4. Inventory Risk**
Several products show **Critical stock status** with under 7 days of supply remaining. Immediate reorder action is required ahead of peak season to prevent lost sales.

**5. Margin Pressure in 2024**
Gross margin declined slightly in 2024 due to rising COGS despite revenue growth — directly reflecting the CEO's concern. Top recommendation: renegotiate supplier costs on the top 5 SKUs and reduce discounts on high-velocity products.

---

## Executive Recommendations

| # | Recommendation |
|---|---|
| 1 | Prioritize promotional investment in Southeast and South Central — your highest-growth markets |
| 2 | Conduct a store-level audit of Northeast region to identify root causes of underperformance |
| 3 | Shift 10% of annual promo budget to Q4 Coffee to capture winter demand spike |
| 4 | Immediate reorder on Critical stock items before peak season |
| 5 | Prioritize Display Feature placements in Walmart and Sam's Club over TPR and Digital Coupon |
| 6 | Renegotiate top 5 SKU supplier costs and reduce discounts on high-velocity products |

---

## Data Model

```
Sales Fact (98,484 rows)
  ├── Products (20 SKUs · 4 categories)
  ├── Stores (310 locations · 4 retailers · 6 regions)
  ├── Promotions (20 events with spend and discount rates)
  ├── Inventory (480 rows · stock status flags)
  └── Calendar (731 days · Week, Month, Quarter, Fiscal Year)
```

**Categories:** Breakfast · Coffee · Snacks · Healthy Foods  
**Retailers:** Walmart · Sam's Club · Target · Kroger  
**Regions:** Southeast · South Central · Midwest · Southwest · West · Northeast

---

## Realistic Data Patterns Built In

The dataset was designed to mirror real CPG supplier dynamics:

- **Seasonal patterns** — Coffee peaks in winter, Snacks spike during football season (Aug–Oct)
- **Regional variance** — Southeast/South Central growing, Northeast/West declining
- **Promotional lift** — BOGO lifts volume 42%, Digital Coupon lifts only 10%
- **Margin pressure** — COGS increased 4% in 2024 compressing gross margins
- **Inventory risk** — Some products at Critical/At Risk status with realistic reorder points

---

## Project Structure

```
FreshNest-Retail-Analytics/
│
├── README.md
│
├── Dataset/
│   └── FreshNest_Dataset_V2.xlsx     # 6-sheet Excel workbook
│
├── SQL/
│   └── FreshNest_SQL_Queries.sql     # 25 business queries
│
├── PowerBI/
│   └── FreshNest_Dashboard.pbix      # 6-page Power BI report
│
└── Business Report/
    └── FreshNest_Executive_Summary.pdf
```

---

## About This Project

This project was designed as a **retail analytics consulting engagement simulation** — not a collection of unrelated analyses. Every dashboard page, SQL query, and recommendation connects back to the same business problem the CEO raised at the start.

The goal was to demonstrate how a business analyst approaches a real problem: starting with the business question, designing the data model, building the analysis, and delivering clear recommendations to leadership.

---

*Built by Radhika Balaji · [Portfolio](https://radhikabadhrinath.github.io/portfolio/) · [LinkedIn](https://www.linkedin.com/in/radhika-balaji/)*
