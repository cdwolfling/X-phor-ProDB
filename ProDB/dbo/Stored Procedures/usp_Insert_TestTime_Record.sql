
/*
2026-04-03 Jackie Chen
EXEC [dbo].[usp_Insert_TestTime_Record]
     @ProductFamily = 'Coral6P0',
     @LotWafer      = 'LNJason-W01',
     @Station       = 'CP01',
     @TestStartTime = '2026-04-03 08:00:00',
     @TestEndTime   = '2026-04-03 09:30:00',
     @Operator      = 'Jason';

Change Log:
2026-04-13 JC: 支持[dbo].[TestTime_Record]数据更新
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
    Declare @Existed_TestStartTime datetime
    select @Existed_TestStartTime=TestEndTime
        FROM [dbo].[TestTime_Record]
        WHERE [LotWafer] = @LotWafer

    IF @Existed_TestStartTime is null
    BEGIN
        print 'insert'
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
    ELSE IF @TestEndTime>@Existed_TestStartTime
    BEGIN
        print 'update'
        Insert dbo.TestTime_Record_History(ID, ProductFamily, LotWafer,t.Station, TestStartTime, TestEndTime, Operator, Cdt, Udt)
            select t.ID, t.ProductFamily, t.LotWafer,t.Station, t.TestStartTime, t.TestEndTime, t.Operator, t.Cdt, t.Udt
            FROM [dbo].[TestTime_Record] t
            WHERE [LotWafer] = @LotWafer
        Update t set t.ProductFamily=@ProductFamily, t.Station=@Station, t.TestStartTime=@TestStartTime, t.TestEndTime=@TestEndTime, t.Operator=@Operator, t.Udt=GETDATE()
            FROM [dbo].[TestTime_Record] t
            WHERE [LotWafer] = @LotWafer
    END
    else
        print 'skip'
END