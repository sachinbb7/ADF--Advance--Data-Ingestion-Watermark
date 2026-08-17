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