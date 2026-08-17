CREATE TABLE dbo.customers
(
    customer_id     VARCHAR(20)    NOT NULL,
    customer_name   VARCHAR(100),
    city            VARCHAR(50),
    membership      VARCHAR(30),
    CONSTRAINT PK_customers PRIMARY KEY (customer_id)
);

CREATE TABLE dbo.products
(
    product_id      VARCHAR(20)    NOT NULL,
    product_name    VARCHAR(150),
    brand           VARCHAR(100),
    category        VARCHAR(100),
    store_id        VARCHAR(20),
    mrp             DECIMAL(10,2),
    CONSTRAINT PK_products PRIMARY KEY (product_id)
);

CREATE TABLE dbo.orders
(
    order_id            VARCHAR(20)    NOT NULL,
    customer_id         VARCHAR(20),
    product_id          VARCHAR(20),
    store_id            VARCHAR(20),
    order_date          DATE,
    last_updated_date   DATETIME2,
    quantity            INT,
    selling_price       DECIMAL(10,2),
    discount            DECIMAL(10,2),
    order_status        VARCHAR(30),

    CONSTRAINT PK_orders PRIMARY KEY (order_id)
);

CREATE TABLE dbo.payments_returns
(
    order_id         VARCHAR(20)    NOT NULL,
    payment_method   VARCHAR(50),
    payment_status   VARCHAR(30),
    return_status    VARCHAR(30),
    refund_amount    DECIMAL(10,2),

    CONSTRAINT PK_payments_returns PRIMARY KEY (order_id)
);
