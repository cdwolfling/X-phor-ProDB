/*
2026-04-16 Jackie Chen

Change Log:
*/
CREATE   PROC [dbo].[uspCalculate_LotWafer_Die_CP_Parameter_Job]
AS
BEGIN
    SET NOCOUNT ON;

	if OBJECT_ID('tempdb..#Wafer') is not null drop table #Wafer
	create table #Wafer(Seqid int identity(1,1), LotWafer varchar(20))
	insert #Wafer(LotWafer)
		select top 100 l.LotWafer from dbo.LotWafer_UEC_Mean_Std l
		where l.FinishDieParameter=0
		order by l.LotWafer
	
	declare @seqid INT=1
	declare @MaxID INT, @LotWafer varchar(20)
	select @MaxID=max(Seqid) from #Wafer
	while @seqid<=@MaxID
	begin
		select @LotWafer=LotWafer from #Wafer z where z.Seqid=@seqid
		exec dbo.uspCalculate_LotWafer_Die_CP_Parameter @LotWafer=@LotWafer
		--declare @diff int
		--select @diff=count(1) from dbo.vw_CPTestData d where d.LotWafer=@LotWafer and d.isRecent=1
		--	and dbo.ufn_GetChipBin_FromCPData(d.LotWafer,d.ChipSN)<>dbo.ufn_GetChipBin_FromCPData_Fast(d.LotWafer,d.ChipSN)
		--if @diff>0
		--begin
		--	print @seqid
		--	print @LotWafer
		--	insert dbo.[LotWafer_Die_CP_Parameter_ErrorWafer] (LotWafer) values (@LotWafer)
		--end
		select @seqid=@seqid+1
	end

END