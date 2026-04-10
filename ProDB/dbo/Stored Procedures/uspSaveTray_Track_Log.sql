/*
2026-02-13 Jackie Chen It's used to save tracking info for tray.
exec dbo.uspSaveTray_Track_Log @LotWaferTrayKey=N'LN43663-W13-06',@Station=N'/',@TrackIn='2025-12-27 16:45:59.530',@TrackOut='2025-12-27 16:46:14.650',@Operator=N'JFL',@ProcessStepName=N'包装'
SELECT * FROM dbo.Tray_Track_Log t WHERE t.LotWaferTrayKey = 'LN43664-W21-01'

Change Log:
*/
CREATE     PROC [dbo].[uspSaveTray_Track_Log]
(
    @LotWaferTrayKey   varchar(20),
    @ProcessStepName   varchar(20),
    @Station   varchar(20),
    @Operator   varchar(10),
    @TrackIn datetime,
    @TrackOut datetime
)
AS
BEGIN
    SET NOCOUNT ON;
    declare @Station_db varchar(20)
    declare @Operator_db varchar(10)
    declare @TrackIn_db datetime
    declare @TrackOut_db datetime

    select @TrackIn_db=t.TrackIn,@TrackOut_db=t.TrackOut,@Station_db=t.Station,@Operator_db=t.Operator
        from dbo.Tray_Track_Log t where t.LotWaferTrayKey=@LotWaferTrayKey and t.ProcessStepName=@ProcessStepName

    if (@TrackIn_db>'2020/1/1' or @TrackOut_db>'2020/1/1')
    begin
        update t set t.Station=@Station, t.Operator=@Operator, t.TrackIn=@TrackIn, t.TrackOut=@TrackOut, t.Udt=getdate()
            from dbo.Tray_Track_Log t where t.LotWaferTrayKey=@LotWaferTrayKey and t.ProcessStepName=@ProcessStepName
    end
    else
    begin
        insert dbo.Tray_Track_Log(LotWaferTrayKey,ProcessStepName,LotWafer,Station,Operator,TrackIn,TrackOut)
            values(@LotWaferTrayKey, @ProcessStepName, left(@LotWaferTrayKey,11), @Station, @Operator, @TrackIn, @TrackOut)
    end

END