# Restaurant Order and Billing System (MySQL)

A beginner-friendly SQL project for managing restaurant tables, menu items, orders, order items, bills, and sales reports.

## Features

- Relational database with primary keys and foreign keys
- Menu and restaurant table management
- Orders with multiple items
- BEFORE INSERT trigger to snapshot the current menu price
- AFTER INSERT triggers to create bills, occupy tables, and update bill totals
- Views for detailed bills and bill summaries
- Stored procedure with a transaction to close a bill and free the table
- Reports: best-selling dishes, daily revenue, busiest hour, category revenue
- CSV menu sample for import practice

## Tools to install

1. MySQL Community Server 8.0 or newer
2. MySQL Workbench
3. Git
4. A GitHub account

Download MySQL and Workbench: https://dev.mysql.com/downloads/

## Folder structure

```text
restaurant-order-billing-sql/
├── data/
│   └── menu_items.csv
├── docs/
│   └── ER_DIAGRAM.md
├── sql/
│   ├── 01_create_database_and_tables.sql
│   ├── 02_sample_data.sql
│   ├── 03_triggers.sql
│   ├── 04_views.sql
│   ├── 05_procedures_and_transactions.sql
│   └── 06_report_queries.sql
├── .gitignore
└── README.md
```

## Step 1 — Open MySQL Workbench

1. Install and open MySQL Workbench.
2. Connect to your local MySQL server (often the connection is named `Local instance MySQL80`).
3. Enter your MySQL password.
4. Open a new SQL tab.

## Step 2 — Create database and tables

Open `sql/01_create_database_and_tables.sql`.
Run the whole script using the lightning icon.
Check the Schemas panel and refresh. You should see `restaurant_billing` and these five tables:
`menu_items`, `restaurant_tables`, `orders`, `order_items`, `bills`.

## Step 3 — Install triggers and insert sample records

First open and run `sql/03_triggers.sql`. Then open and run `sql/02_sample_data.sql`.

**Run the SQL files in this exact order:**
1. `01_create_database_and_tables.sql`
2. `03_triggers.sql`
3. `02_sample_data.sql`
4. `04_views.sql`
5. `05_procedures_and_transactions.sql`
6. `06_report_queries.sql`

The trigger file must be installed before sample data is inserted. It automatically creates bills, marks tables occupied, copies the current menu price into each order item, and updates bill totals.

If you already inserted sample data before installing triggers, recreate the database or clean up the sample rows before repeating the sequence to avoid duplicate records.

## Step 4 — Verify the data

Run:

```sql
USE restaurant_billing;
SELECT * FROM menu_items;
SELECT * FROM restaurant_tables;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM bills;
```

The `orders` trigger creates one bill per order and marks its table occupied. The `order_items` triggers copy the current menu price and recalculate the bill.

## Step 5 — Test the view

```sql
SELECT * FROM v_bill_details;
SELECT * FROM v_bill_summary;
```

The detailed view displays item, quantity, item price, line total, and bill totals.

## Step 6 — Test closing a bill (transaction)

First inspect the bill:

```sql
SELECT * FROM bills WHERE order_id = 1;
SELECT * FROM restaurant_tables WHERE table_id = 1;
```

Close it:

```sql
CALL sp_close_bill(1);
```

Verify:

```sql
SELECT * FROM bills WHERE order_id = 1;
SELECT * FROM orders WHERE order_id = 1;
SELECT * FROM restaurant_tables WHERE table_id = 1;
```

The bill should be PAID, the order CLOSED, and its table AVAILABLE. The procedure performs these updates in one transaction.

## Step 7 — Run the reports

Open `sql/06_report_queries.sql` and run each query separately or run the full file. It includes:
- Best-selling dishes
- Revenue by day (paid bills)
- Busiest hour
- Bill details
- Occupied tables
- Revenue by category

The daily revenue report will show rows after you close/pay bills.

## Step 8 — Import the menu CSV

For a beginner-friendly Workbench import:
1. In the Schemas panel, right-click `menu_items`.
2. Choose **Table Data Import Wizard**.
3. Select `data/menu_items.csv`.
4. Choose the existing `menu_items` table.
5. Map the four CSV columns to `item_name`, `category`, `price`, `is_available`.
6. Run the import.

The CSV deliberately excludes `item_id` and `created_at`, which MySQL generates automatically. Importing the sample CSV after running sample data will create duplicate menu names; use a fresh database or remove the sample menu rows first.

Alternative: use the Workbench Table Data Import Wizard rather than `LOAD DATA LOCAL INFILE`, because local-file settings differ between MySQL installations.

## Step 9 — Export daily sales

Run a query such as:

```sql
SELECT
    DATE(paid_at) AS sales_date,
    SUM(total_amount) AS daily_revenue
FROM bills
WHERE bill_status = 'PAID'
GROUP BY DATE(paid_at)
ORDER BY sales_date;
```

In MySQL Workbench:
1. Execute the query.
2. In the Result Grid, click **Export** (or right-click the result grid and choose an export option).
3. Save as CSV, for example `daily_sales.csv`.

## Step 10 — View/export the ER diagram

1. Open `docs/ER_DIAGRAM.md`.
2. Copy the Mermaid code (the text between the Mermaid fences).
3. Open https://mermaid.live and paste it.
4. Export as PNG or SVG.
5. Optionally save the exported image in `docs/` as `er-diagram.png`.

You can also create a Workbench EER diagram:
1. Select **Database → Reverse Engineer**.
2. Select your local connection and the `restaurant_billing` schema.
3. Finish the wizard; Workbench generates an EER diagram from the foreign keys.
4. Use **File → Export** to save the diagram as PNG/PDF/SVG if available in your Workbench version.

## Step 11 — Upload the project to GitHub

### A. Create a repository on GitHub
1. Sign in at https://github.com.
2. Click **New repository**.
3. Repository name: `restaurant-order-billing-sql`.
4. Add description: `Restaurant order and billing database project using MySQL`.
5. Choose Public if you want recruiters to view it.
6. Do not initialize with a README if you plan to push this existing folder.
7. Click **Create repository**.

### B. Open the project folder in VS Code
1. Extract the ZIP file.
2. Open VS Code.
3. Select **File → Open Folder**.
4. Choose the extracted `restaurant-order-billing-sql` folder.
5. Open Terminal → New Terminal.

### C. Configure Git (first-time setup only)

```bash
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

Use the name and email associated with your GitHub account.

### D. Commit and push

Replace `YOUR-USERNAME` with your GitHub username:

```bash
git init
git add .
git commit -m "Initial commit: restaurant order and billing SQL project"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/restaurant-order-billing-sql.git
git push -u origin main
```

If Git asks you to authenticate, complete the browser sign-in or use a GitHub Personal Access Token when prompted. Do not put passwords, tokens, or database credentials in your repository.

### E. Later updates

After changing files:

```bash
git add .
git commit -m "Add sales reports and improve billing logic"
git push
```

## Important project notes / possible extensions

- This is a database project, not a complete restaurant website or POS user interface.
- The example tax rate is 5% for demonstration only. Change `tax_rate` to the rate appropriate for your assignment/business.
- The supplied triggers cover inserts, as requested in the project brief. If you later allow editing or deleting order items, add matching UPDATE/DELETE triggers so bill totals remain synchronized.
- For a production system, add validation to prevent adding items to closed orders, prevent multiple active orders for one table if that is your business rule, and handle discounts, refunds, split payments, and audit logs.
- Never commit database passwords or private credentials to GitHub.
