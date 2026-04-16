/*
=============================================
Author:		Jackie Chen
Create date: 2026-04-13
Description: 用来查看和监控Fab WIP
Sample:
select fab.[ufn_Get_Layer_ExpertedLT]('Fab3',30)
select fab.[ufn_Get_Layer_ExpertedLT]('Fab2',30)
exec [fab].[uspReport_FabWIP] @QueryDate = '2026-04-01'	, @QueryType = 'Warning'
exec [fab].[uspReport_FabWIP]

Change Log:
2026-04-15 JC: 根据Vicky提供的V3模板， 修改输出内容; DateFalg-->DateFlag
2026-04-14 JC: 增加 @QueryDate 和 @QueryType 两个选项
=============================================
*/
CREATE   PROCEDURE [fab].[uspReport_FabWIP](
@QueryDate date=null
,@QueryType varchar(20)=null --All or Warning
)
AS
BEGIN
    SET NOCOUNT ON;
	select @QueryDate=isnull(@QueryDate, getdate())
	select @QueryType=isnull(@QueryType, 'All')
    
	if OBJECT_ID('tempdb..#Lot') is not null drop table #Lot
	create table #Lot(SeqID INT identity(1,1), LastDayflag date, LotID varchar(50),LotType varchar(50),FAB varchar(50),TowerPart varchar(50),CustomerPart varchar(50),Stage varchar(50),CompPct INT,Qty INT,Priority varchar(50)
		, CurrentLayer INT, StartDate date, ECD date, RFCD date, PONumber varchar(50)
		, CurrentLayer_FirstDay date, Current_Layer_Running_Day INT, Standard_Layer_LT INT, Current_Layer_Over_LTDays INT
		, Processing_Days INT, Standard_Processing_Days INT
		, Over_Processing_LTDays INT
		, Total_Lead_Time INT, Arrival_EDT_Date Date)
	insert #Lot(LotID, LotType,FAB, LastDayflag, Standard_Layer_LT)
		select f.LotID, f.LotType ,f.FAB, max(f.DateFlag), 0
		from fab.tFabWIP f
		where f.StartDate is not null
		and f.DateFlag<=@QueryDate
		group by f.LotID,f.LotType,f.FAB
	
	update l set l.TowerPart=f.TowerPart, l.CustomerPart=f.CustomerPart, l.Stage=f.Stage, l.CompPct=f.CompPct,l.Qty=f.Qty, l.Priority=f.Priority
		, l.CurrentLayer=f.CurrentLayer, l.StartDate=f.StartDate, l.ECD=f.ECD, l.RFCD=f.RFCD, l.PONumber=f.PONumber
		from #Lot l
		join fab.tFabWIP f on f.LotID=l.LotID and f.DateFlag=l.LastDayflag
	--1. Current Layer Running Day: 从进入当前 Layer 的第一天开始计算，截至查询日期为止，按自然日累计。
	update l set l.CurrentLayer_FirstDay=(select min(f.DateFlag) from fab.tFabWIP f where f.LotID=l.LotID and f.CurrentLayer=l.CurrentLayer and f.DateFlag<=@QueryDate
		)
		from #Lot l
	update l set l.Current_Layer_Running_Day=DATEDIFF(dd,CurrentLayer_FirstDay,@QueryDate)+1
		from #Lot l

	--2. Standard Layer LT
	update l set l.Standard_Layer_LT=lt.LeadTime
		from #Lot l
		join [fab].[tFAB_LT] lt on l.FAB=lt.FabName and l.CurrentLayer=lt.Layer
	--3. Current Layer Over LTDays
	update l set l.Current_Layer_Over_LTDays=case when l.Current_Layer_Running_Day>l.Standard_Layer_LT then l.Current_Layer_Running_Day-l.Standard_Layer_LT else 0 end
		from #Lot l

	--4. Processing Days
	--5. Standard Processing Days
	update l set l.Processing_Days=DATEDIFF(dd,l.StartDate,@QueryDate)+1
		, l.Standard_Processing_Days=fab.[ufn_Get_Layer_ExpertedLT](l.FAB, l.CurrentLayer)
		from #Lot l

	--6. Over Processing LTDays
	update l set l.Over_Processing_LTDays = l.Processing_Days - l.Standard_Processing_Days - l.Standard_Layer_LT
		from #Lot l

	--7. Total Lead Time
	update l set l.Total_Lead_Time = fab.[ufn_Get_Layer_ExpertedLT](l.FAB, 99) + l.Over_Processing_LTDays
		from #Lot l

	--7. Total Lead Time
	update l set l.Arrival_EDT_Date = DATEADD(dd,l.Total_Lead_Time+4,l.StartDate)
		from #Lot l

	--8. Arrival EDT Date
	UPDATE l SET l.Arrival_EDT_Date = DATEADD
		(
			DAY,
			CASE (DATEDIFF(DAY, '19000101', l.Arrival_EDT_Date) % 7)
				WHEN 5 THEN 2   -- 周六 -> 顺延2天到周一
				WHEN 6 THEN 1   -- 周日 -> 顺延1天到周一
				ELSE 0
			END,
			l.Arrival_EDT_Date
		)
		FROM #Lot l
		WHERE (DATEDIFF(DAY, '19000101', l.Arrival_EDT_Date) % 7) IN (5, 6);
		
	if @QueryType='All'
	begin
		select l.SeqID, l.LotID, l.LotType, l.FAB, l.TowerPart, l.CustomerPart, l.Stage, l.CompPct, l.Qty, l.Priority
			, l.CurrentLayer, l.StartDate, l.ECD, l.RFCD, l.PONumber
			, l.Current_Layer_Running_Day, l.Standard_Layer_LT, l.Current_Layer_Over_LTDays
			, l.Processing_Days, l.Standard_Processing_Days, l.Over_Processing_LTDays
			, l.Total_Lead_Time, l.Arrival_EDT_Date
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
			 ('Fab3', fab.[ufn_Get_Layer_ExpertedLT]('Fab3',99)*0.1)
			,('Fab9', fab.[ufn_Get_Layer_ExpertedLT]('Fab9',99)*0.1)
			,('Fab2', fab.[ufn_Get_Layer_ExpertedLT]('Fab2',99)*0.1)
		select l.SeqID, l.LotID, l.LotType, l.FAB, l.TowerPart, l.CustomerPart, l.Stage, l.CompPct, l.Qty, l.Priority
			, l.CurrentLayer, l.StartDate, l.ECD, l.RFCD, l.PONumber
			, l.Current_Layer_Running_Day, l.Standard_Layer_LT, l.Current_Layer_Over_LTDays
			, l.Processing_Days, l.Standard_Processing_Days, l.Over_Processing_LTDays
			, l.Total_Lead_Time, l.Arrival_EDT_Date
			from #Lot l
			join #WarningThreshold w on l.FAB=w.FAB
			where l.Over_Processing_LTDays>w.OverLTWarningThreshold
	end

END;
GO
GRANT EXECUTE
    ON OBJECT::[fab].[uspReport_FabWIP] TO [Production]
    AS [dbo];

