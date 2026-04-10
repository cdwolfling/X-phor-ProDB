
/*
2026-04-03 Jackie Chen
EXEC [dbo].[usp_Insert_TestTime_Record]
     @ProductFamily = 'Coral6P0',
     @LotWafer      = 'LN46185-W01',
     @Station       = 'CP01',
     @TestStartTime = '2026-04-03 08:00:00',
     @TestEndTime   = '2026-04-03 09:30:00',
     @Operator      = 'Jason';

Change Log:
*/
CREATE PROCEDURE [dbo].[usp_Insert_TestTime_Record]
    @ProductFamily  varchar(8),
    @LotWafer       varchar(11),
    @Station        varchar(10),
    @TestStartTime  datetime,
    @TestEndTime    datetime,
    @Operator       varchar(10)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM [dbo].[TestTime_Record] WITH (UPDLOCK, HOLDLOCK)
        WHERE [LotWafer] = @LotWafer
          AND [TestStartTime] = @TestStartTime
    )
    BEGIN
        INSERT INTO [dbo].[TestTime_Record]
        (
            [ProductFamily],
            [LotWafer],
            [Station],
            [TestStartTime],
            [TestEndTime],
            [Operator]
        )
        VALUES
        (
            @ProductFamily,
            @LotWafer,
            @Station,
            @TestStartTime,
            @TestEndTime,
            @Operator
        );
    END
END