
/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2026/01/03
-- Description:	获取 待 AOI 工艺步骤、待处理 Wafer 的清单
-- Notes:

Change Log:
2025/01/27 JC: job频率从5分钟改为30分钟， 每次处理数量从100改为300
2025/01/05 JC: 只从3天内有更新的Wafer中 处理AOI Json文件
-- =============================================
*/
CREATE PROCEDURE [dbo].[uspGetPendingAOIStepWafers]
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @WaferUpdateWindowDays int = 3

	IF OBJECT_ID('tempdb..#Result') IS NOT NULL DROP TABLE #Result
	CREATE TABLE #Result(SeqID int identity(1,1), ProductModel VARCHAR(8), Lot号 VARCHAR(7), Wafer号 VARCHAR(3), AOI开始 datetime, 目检开始时间 datetime, 复判照片开始时间 datetime, AOIJson处理时间 datetime)


	INSERT #Result(ProductModel, Lot号, Wafer号, AOI开始, 目检开始时间, 复判照片开始时间)
		SELECT left(w.SourceName,8), w.Lot号, right(w.Wafer号,3) as Wafer号, w.AOI开始, w.目检开始时间, w.复判照片开始时间
		FROM dbo.Wafer w
		LEFT JOIN dbo.Wafer_AOI_Process wo on w.Lot号=wo.LotNo and w.Wafer号=wo.LotNo+'-'+wo.Wafer
		WHERE w.测试结束时间>='2000/1/1' and wo.Seqid is NULL
		ORDER by w.FileModifiedTime
	UPDATE z set z.AOI开始=NULL from #Result z where z.AOI开始='1899-12-31 00:00:00.000'
	UPDATE z set z.目检开始时间=NULL from #Result z where z.目检开始时间='1899-12-31 00:00:00.000'
	UPDATE z set z.复判照片开始时间=NULL from #Result z where z.复判照片开始时间='1899-12-31 00:00:00.000'
	DELETE z FROM #Result z WHERE z.AOI开始 is NULL and z.目检开始时间 is NULL and z.复判照片开始时间 is NULL

	IF (select count(1) from #Result)<300
	BEGIN
		INSERT #Result(ProductModel, Lot号, Wafer号, AOI开始, 目检开始时间, 复判照片开始时间, AOIJson处理时间)
			SELECT Top 300 left(w.SourceName,8), w.Lot号, right(w.Wafer号,3) as Wafer号, w.AOI开始, w.目检开始时间, w.复判照片开始时间, wo.Udt
			FROM dbo.Wafer w
			JOIN dbo.Wafer_AOI_Process wo on w.Lot号=wo.LotNo and w.Wafer号=wo.LotNo+'-'+wo.Wafer
			WHERE w.测试结束时间>='2000/1/1' and (w.AOI开始>='2000/1/1' or 目检开始时间>='2000/1/1' or w.复判照片开始时间>='2000/1/1')
			and w.FileModifiedTime>=DATEADD(dd,-1*@WaferUpdateWindowDays, getdate()) -- 如果wafer之前已处理过，后续只处理Traveler在n天内有更新的Wafer
			ORDER BY wo.Udt --> n天内数据 反复处理
	END

	select z.SeqID, ProductModel, Lot号, Wafer号, AOI开始, 目检开始时间, 复判照片开始时间, z.AOIJson处理时间
		FROM #Result z
		order by z.SeqID

END;
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[uspGetPendingAOIStepWafers] TO [Production]
    AS [dbo];

