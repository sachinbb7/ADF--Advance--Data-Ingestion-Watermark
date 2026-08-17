CREATE TABLE dbo.etl_watermark
(
    id                          INT IDENTITY(1,1) PRIMARY KEY,
    source_name                 VARCHAR(50) NOT NULL,
    last_processed_timestamp    DATETIME2(7) NOT NULL,
    created_on                  DATETIME2(7) NOT NULL
        DEFAULT SYSUTCDATETIME()
);
