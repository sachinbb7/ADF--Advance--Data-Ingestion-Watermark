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

--------------------------------------------------------------

#15-Aug initial load
    
INSERT INTO dbo.orders
(
    order_id,
    customer_id,
    product_id,
    store_id,
    order_date,
    last_updated_date,
    quantity,
    selling_price,
    discount,
    order_status
)
VALUES
('QB1001','C101','P101','S01','2026-08-15','2026-08-15 09:00:00',2,65,0,'Delivered'),

('QB1002','C102','P102','S01','2026-08-15','2026-08-15 09:10:00',1,48,5,'Delivered'),

('QB1003','C103','P103','S02','2026-08-14','2026-08-15 09:30:00',3,18,0,'Delivered'),

('QB1004','C104','P104','S02','2026-08-15','2026-08-15 10:00:00',2,42,4,'Delivered'),

('QB1005','C105','P105','S03','2026-08-12','2026-08-15 10:20:00',1,139,0,'Returned'),

('QB1006','C999','P106','S01','2026-08-15','2026-08-15 10:30:00',2,16,0,'Delivered'),

('QB1007','C106','P999','S02','2026-08-15','2026-08-15 10:40:00',1,110,0,'Delivered'),

('QB1008','C107','P107','S03','2026-08-15','2026-08-15 10:50:00',-1,200,0,'Delivered'),

('QB1009','C108','P108','S02','2026-08-15','2026-08-15 11:00:00',1,-50,0,'Delivered'),

('QB1010','C109','P109','S01','2026-08-15','2026-08-15 11:10:00',2,50,5,'Cancelled'),

('QB1011','C110','P110','S03','2026-08-15','2026-08-15 11:20:00',2,45,0,'Delivered'),

('QB1012','C101','P101','S01','2026-08-15','2026-08-15 11:30:00',1,65,0,'Delivered');


INSERT INTO dbo.payments_returns
(
    order_id,
    payment_method,
    payment_status,
    return_status,
    refund_amount
)
VALUES
('QB1001','UPI','Paid','Not Returned',0),
('QB1002','Credit Card','Paid','Not Returned',0),
('QB1003','UPI','Paid','Not Returned',0),
('QB1004','COD','Paid','Not Returned',0),
('QB1005','Credit Card','Paid','Returned',139),
('QB1010','UPI','Paid','Not Returned',0),
('QB1011','UPI','Paid','Not Returned',0),
('QB1012','UPI','Paid','Not Returned',0);

---------------------------------------------------------------------------------------

#16-Aug first_load

INSERT INTO dbo.orders
(
    order_id,
    customer_id,
    product_id,
    store_id,
    order_date,
    last_updated_date,
    quantity,
    selling_price,
    discount,
    order_status
)
VALUES
('QB1013','C102','P103','S02','2026-08-16','2026-08-16 08:30:00',2,18,0,'Delivered'),

('QB1014','C105','P107','S03','2026-08-16','2026-08-16 09:00:00',1,205,10,'Delivered'),

('QB1015','C106','P109','S01','2026-08-16','2026-08-16 09:15:00',3,50,0,'Delivered'),

('QB1016','C103','P104','S02','2026-08-15','2026-08-16 09:30:00',1,42,0,'Delivered'),

('QB1017','C999','P101','S01','2026-08-16','2026-08-16 10:00:00',1,65,0,'Delivered'),

('QB1018','C104','P999','S02','2026-08-16','2026-08-16 10:15:00',1,100,0,'Delivered'),

('QB1019','C107','P108','S02','2026-08-16','2026-08-16 10:30:00',-2,110,0,'Delivered'),

('QB1020','C108','P102','S01','2026-08-16','2026-08-16 10:45:00',1,-48,0,'Delivered');


INSERT INTO dbo.payments_returns
(
    order_id,
    payment_method,
    payment_status,
    return_status,
    refund_amount
)
VALUES
('QB1013','UPI','Paid','Not Returned',0),

('QB1014','Credit Card','Paid','Not Returned',0),

('QB1015','COD','Paid','Not Returned',0),

('QB1016','UPI','Paid','Not Returned',0),

('QB1017','UPI','Paid','Not Returned',0),

('QB1018','Credit Card','Paid','Not Returned',0),

('QB1019','COD','Paid','Not Returned',0),

('QB1020','UPI','Paid','Not Returned',0);

----------------------------------------------------------------------------------------
#17-Aug second_load
    
INSERT INTO dbo.orders
(
    order_id,
    customer_id,
    product_id,
    store_id,
    order_date,
    last_updated_date,
    quantity,
    selling_price,
    discount,
    order_status
)
VALUES
('QB1021','C101','P106','S01','2026-08-17','2026-08-17 08:00:00',3,16,0,'Delivered'),

('QB1022','C110','P110','S03','2026-08-17','2026-08-17 08:20:00',2,45,5,'Delivered'),

('QB1023','C109','P109','S01','2026-08-17','2026-08-17 08:40:00',1,50,0,'Returned'),

('QB1024','C104','P105','S03','2026-08-17','2026-08-17 09:00:00',1,139,0,'Delivered'),

('QB1025','C106','P107','S03','2026-08-16','2026-08-17 09:20:00',2,200,0,'Delivered'),

('QB1026','C103','P103','S02','2026-08-17','2026-08-17 09:40:00',2,18,0,'Cancelled');



INSERT INTO dbo.payments_returns
(
    order_id,
    payment_method,
    payment_status,
    return_status,
    refund_amount
)
VALUES
('QB1021','UPI','Paid','Not Returned',0),

('QB1022','Credit Card','Paid','Not Returned',0),

('QB1023','UPI','Paid','Returned',50),

('QB1024','COD','Paid','Not Returned',0),

('QB1025','Credit Card','Paid','Not Returned',0),

('QB1026','UPI','Paid','Not Returned',0);



---------------------------------------------------------------


#Create Tabel and Stored Procedure to Log Watermark

CREATE TABLE dbo.etl_watermark
(
    id                          INT IDENTITY(1,1) PRIMARY KEY,
    source_name                 VARCHAR(50) NOT NULL,
    last_processed_timestamp    DATETIME2(7) NOT NULL,
    created_on                  DATETIME2(7) NOT NULL
        DEFAULT SYSUTCDATETIME()
);


CREATE OR ALTER PROCEDURE dbo.usp_log_watermark
(
    @source_name                 VARCHAR(50),
    @last_processed_timestamp    DATETIME2(7)
)
AS
BEGIN

    SET NOCOUNT ON;

    INSERT INTO dbo.etl_watermark
    (
        source_name,
        last_processed_timestamp
    )
    VALUES
    (
        @source_name,
        @last_processed_timestamp
    );

END;

