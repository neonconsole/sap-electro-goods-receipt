# Electrical Warehouse Goods Receipt Management

A custom **Classic ABAP application** for managing goods receipts against existing purchase orders in an electrical products warehouse.

The application supports partial and complete goods receipts, validates received quantities against ordered quantities, maintains order fulfillment statuses, and prevents concurrent processing of the same order using SAP enqueue/dequeue locking.

## Features

- **Order-based goods receipt processing** — receive products against existing orders.
- **Product validation** — ensure that a product belongs to the selected order before adding it to a receipt.
- **Flexible product selection** — search by product ID, enter a product name, or use SAP Search Help to browse products belonging to the selected order.
- **Quantity validation** — prevent zero or negative quantities and receipts exceeding the remaining ordered quantity.
- **Partial deliveries** — process a single order across multiple receipts.
- **Automatic order status management** — update order status based on the quantities received.
- **Concurrency control** — lock the selected order during receipt posting.
- **Order status reporting** — filter orders and display results in a SAP SALV table.
- **Master data maintenance** — maintain products, manufacturers, order headers, and order items.
- **Multilingual product descriptions** — support English (EN) and German (DE), based on the SAP logon language.

## Business Workflow

1. Select **Receive Order** from the main menu.
2. Enter an existing order ID and select **Apply Order**.
3. Select a product using its ID, name, or Search Help.
4. Validate the product and review the ordered, received, and remaining quantities.
5. Enter the quantity to receive and select **Add Item**.
6. Repeat for additional products in the same receipt.
7. Select **Submit Receipt** to validate and post the receipt.

During posting, the application locks the selected order, validates quantities, generates a unique receipt ID, saves the receipt header and items through an update Function Module, updates the order status, commits the database changes, and releases the lock.

## Order Lifecycle

The application maintains three order statuses:

| Status | Description |
|---|---|
| `NEW` | No products have been received. |
| `PARTIAL` | Some, but not all, ordered quantities have been received. |
| `COMPLETED` | All ordered quantities have been received. |

### Example: Partial Receipt

An order contains 100 units of a product.

| Quantity | Units |
|---|---:|
| Ordered | 100 |
| Previously received | 40 |
| Remaining | 60 |
| Current receipt | 30 |
| Remaining after receipt | 30 |

After posting the receipt, the order remains `PARTIAL`. The remaining 30 units can be received in a subsequent transaction. Once the full ordered quantity has been received, the order status changes to `COMPLETED`.

## Technical Architecture

The application uses custom ABAP Dictionary objects, classic SAP GUI screens, Open SQL, and reusable function-module logic.

### Main Application Components

| Component | Responsibility |
|---|---|
| `ZKOF6_ORDER_RECEIVE` | Main transaction for goods receipt processing |
| Main Menu | Navigation between receipt processing, status reporting, and administration |
| Order Receive Screen | Order selection, product validation, quantity entry, and receipt submission |
| Order Status Report | Order filtering and reporting through SAP SALV |
| Administration Menu | Maintenance of master data and order data |
| Update Function Module | Posting receipt header and item data |

## Database Design

The application uses seven custom database tables.

| Table | Purpose |
|---|---|
| `ZKOF6_D_MANUFACT` | Manufacturer master data |
| `ZKOF6_D_PRODUCT` | Product master data |
| `ZKOF6_D_PROD_T` | Language-dependent product names and descriptions |
| `ZKOF6_D_ORDER_H` | Order header data |
| `ZKOF6_D_ORDER_I` | Products and quantities belonging to an order |
| `ZKOF6_D_RECP_H` | Goods receipt header data |
| `ZKOF6_D_RECP_I` | Individual items recorded in a receipt |

The data model separates order headers and items from receipt headers and items. This enables multiple receipts to be associated with the same order while preserving the distinction between ordered and received quantities.

### Additional ABAP Dictionary Objects

The project also includes:

- Custom domains and data elements for identifiers, quantities, statuses, and product descriptions.
- Structures and table types for order display, receipt processing, and selection criteria.
- Maintenance view `ZKOF6_V_PRODUCT` for product master data and multilingual product texts.
- Lock object `EZKOF6_ORDER` for order-level concurrency control.

## Validation and Transaction Integrity

Before a receipt is posted, the application verifies that:

- The selected order exists.
- The product belongs to the selected order.
- The received quantity is greater than zero.
- The received quantity does not exceed the remaining quantity.
- The cumulative received quantity does not exceed the ordered quantity.

During receipt posting, the application locks the order to prevent simultaneous processing. It then performs the posting and status update, commits the database changes, and releases the lock.

## Order Status Reporting

The Order Status report retrieves existing orders and displays them in a SAP SALV table.

Available selection criteria include:

- Order status exclusion filters.
- Order ID.
- Created By.
- Order Date.

The additional selection criteria can be activated when more specific filtering is required.

## Administration

The administration section provides maintenance dialogs for:

- Order headers.
- Order items.
- Products.
- Manufacturers.

These functions allow the application data to be prepared and maintained before goods receipt processing.

## Technologies

- SAP Classic ABAP
- ABAP Dictionary (DDIC)
- Open SQL
- SAP GUI and Dynpro
- SAP SALV
- Function Modules
- SAP enqueue/dequeue locking
- Database LUW and commit handling
- Language-dependent application data

## Project Scope

This project demonstrates the implementation of a warehouse goods receipt workflow in a classic SAP environment, combining custom data modeling, input validation, transactional processing, concurrency control, reporting, and master data maintenance.

The focus is on applying ABAP development concepts to a practical business scenario while maintaining data consistency throughout the receipt process.
