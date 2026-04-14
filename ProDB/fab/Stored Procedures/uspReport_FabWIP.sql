/*
=============================================
Author:		Jackie Chen
Create date: 2026-04-13
Description: 用来查看和监控Fab WIP
Sample:
select fab.[ufn_Get_Layer_ExpertedLT]('Fab3',30)
select fab.[ufn_Get_Layer_ExpertedLT]('Fab2',30)
exec [fab].[uspReport_FabWIP] @QueryDate = '2026-04-01'	, @QueryType = 'Warning'
exec [fab].[uspReport_FabWIP] @QueryDate = null			, @QueryType = 'Warning'

Change Log:
2026-04-14 JC: 增加 @QueryDate 和 @QueryType 两个选项
=============================================
*/
CREATE   PROCEDURE [fab].[uspReport_FabWIP](
@QueryDate date=null
,@QueryType varchar(20)='All' --All or Warning
)
AS
BEGIN
    SET NOCOUNT ON;
	select @QueryDate=isnull(@QueryDate,getdate())
    
	if OBJECT_ID('tempdb..#Lot') is not null drop table #Lot
	create table #Lot(SeqID INT identity(1,1), LotID varchar(50),LotType varchar(50),FAB varchar(50),StartDate date,Qty INT
		, Last_CurrentLayer INT,CurrentLayer_FirstDay date, CurrentLayer_RunningDay INT, CurrentLayer_LT INT, CurrentLayer_OverLTDays INT
		, Layer_ExpertedLT INT,Layer_ActureLT INT
		, OverLTDays INT)
	insert #Lot(LotID,LotType,FAB,StartDate,Last_CurrentLayer)
		select f.LotID,f.LotType ,f.FAB,f.StartDate,max(f.CurrentLayer)
		from fab.tFabWIP f
		where f.StartDate is not null
		and f.DateFalg<=@QueryDate
		group by f.LotID,f.LotType,f.FAB,f.StartDate
	
	update l set l.Qty=(select top 1 Qty from fab.tFabWIP f where f.LotID=l.LotID and f.CurrentLayer=l.Last_CurrentLayer and f.DateFalg<=@QueryDate
		order by f.DateFalg desc
		)
		from #Lot l
	update l set l.CurrentLayer_FirstDay=(select max(f.DateFalg) from fab.tFabWIP f where f.LotID=l.LotID and f.CurrentLayer=l.Last_CurrentLayer and f.DateFalg<=@QueryDate
		)
		from #Lot l
	update l set l.CurrentLayer_RunningDay=DATEDIFF(dd,CurrentLayer_FirstDay,@QueryDate)
		from #Lot l
	update l set l.CurrentLayer_LT=lt.LeadTime
		from #Lot l
		join [fab].[tFAB_LT] lt on l.FAB=lt.FabName and l.Last_CurrentLayer=lt.Layer
	update l set l.CurrentLayer_OverLTDays=case when l.CurrentLayer_RunningDay>l.CurrentLayer_LT then l.CurrentLayer_RunningDay-l.CurrentLayer_LT else 0 end
		from #Lot l

	update l set l.Layer_ExpertedLT=fab.[ufn_Get_Layer_ExpertedLT](l.FAB, l.Last_CurrentLayer)
		,Layer_ActureLT=DATEDIFF(dd,l.StartDate,l.CurrentLayer_FirstDay)
		from #Lot l
	update l set l.OverLTDays=CurrentLayer_OverLTDays+(l.Layer_ActureLT-l.Layer_ExpertedLT)
		from #Lot l
		

	if @QueryType='All'
	begin
		select l.SeqID, l.LotID, l.LotType, l.FAB, l.StartDate, l.Qty
			, l.Last_CurrentLayer, l.CurrentLayer_FirstDay, l.CurrentLayer_RunningDay, l.CurrentLayer_LT, l.CurrentLayer_OverLTDays
			, l.Layer_ExpertedLT, l.Layer_ActureLT, l.OverLTDays
			from #Lot l
	end
	else if @QueryType='Warning'
	begin
		IF OBJECT_ID('tempdb..#WarningThreshold') IS NOT NULL DROP TABLE #WarningThreshold;
		CREATE TABLE #WarningThreshold
		(
			FAB                    VARCHAR(50),
			OverLTWarningThreshold INT
		)
		insert #WarningThreshold(FAB,OverLTWarningThreshold) values
			 ('Fab3', fab.[ufn_Get_Layer_ExpertedLT]('Fab3',30)*0.1)
			,('Fab9', fab.[ufn_Get_Layer_ExpertedLT]('Fab9',30)*0.1)
			,('Fab2', fab.[ufn_Get_Layer_ExpertedLT]('Fab2',30)*0.1)
		select l.SeqID, l.LotID, l.LotType, l.FAB, l.StartDate, l.Qty
			, l.Last_CurrentLayer, l.CurrentLayer_FirstDay, l.CurrentLayer_RunningDay, l.CurrentLayer_LT, l.CurrentLayer_OverLTDays
			, l.Layer_ExpertedLT, l.Layer_ActureLT, l.OverLTDays
			from #Lot l
			join #WarningThreshold w on l.FAB=w.FAB
			where l.OverLTDays>w.OverLTWarningThreshold
	end

END;
GO
GRANT EXECUTE
    ON OBJECT::[fab].[uspReport_FabWIP] TO [Production]
    AS [dbo];

