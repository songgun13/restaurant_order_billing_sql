# Entity Relationship Diagram

Paste this Mermaid code into https://mermaid.live to view or export the ER diagram as PNG/SVG.

```mermaid
erDiagram
    RESTAURANT_TABLES ||--o{ ORDERS : receives
    ORDERS ||--o{ ORDER_ITEMS : contains
    MENU_ITEMS ||--o{ ORDER_ITEMS : selected_in
    ORDERS ||--|| BILLS : generates

    RESTAURANT_TABLES {
        INT table_id PK
        INT table_number UK
        INT capacity
        ENUM table_status
    }

    MENU_ITEMS {
        INT item_id PK
        VARCHAR item_name
        VARCHAR category
        DECIMAL price
        BOOLEAN is_available
    }

    ORDERS {
        INT order_id PK
        INT table_id FK
        DATETIME order_datetime
        ENUM order_status
        VARCHAR notes
    }

    ORDER_ITEMS {
        INT order_item_id PK
        INT order_id FK
        INT item_id FK
        INT quantity
        DECIMAL unit_price
        DECIMAL line_total
    }

    BILLS {
        INT bill_id PK
        INT order_id FK, UK
        DECIMAL subtotal
        DECIMAL tax_rate
        DECIMAL tax_amount
        DECIMAL total_amount
        ENUM bill_status
        DATETIME created_at
        DATETIME paid_at
    }
```

## Relationship explanation

- One restaurant table can have many orders over time.
- One order contains one or many order items.
- One menu item can appear in many order items.
- Each order has one bill; `bills.order_id` is UNIQUE.
- `order_items.unit_price` stores the price at the time of ordering (price snapshot).
