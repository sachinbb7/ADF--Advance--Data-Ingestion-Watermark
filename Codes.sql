CREATE TABLE dbo.customers
(
    customer_id     VARCHAR(20)    NOT NULL,
    customer_name   VARCHAR(100),
    city            VARCHAR(50),
    membership      VARCHAR(30),
    CONSTRAINT PK_customers PRIMARY KEY (customer_id)
);
