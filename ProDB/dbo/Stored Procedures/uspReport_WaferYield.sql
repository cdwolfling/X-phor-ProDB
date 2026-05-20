/*
2026-02-28 Jackie Chen
@ProductStatus:
1 已测试未划片
2 已划片
3 已完成
exec uspReport_WaferYield @ProductModel='Coral3p1',@ProductStatus=2,@WaferList=null

Change Log:
2026-05-14 JC: remove @LotList, add @WaferList in input parameters
*/
CREATE     PROC [dbo].[uspReport_WaferYield]
(
@ProductModel varchar(20),
@ProductStatus INT,
@WaferList varchar(MAX)=''
)
AS
BEGIN
    SET NOCOUNT ON;
    
	select @WaferList=isnull(@WaferList,'')
    select @WaferList=replace(@WaferList,char(13),',')
    select @WaferList=replace(@WaferList,char(10),',')
	IF OBJECT_ID('tempdb..#WaferList') IS NOT NULL DROP TABLE #WaferList
	create table #WaferList(Wafer varchar(20))
	if @WaferList<>''
	begin
		insert #WaferList(Wafer)
			select distinct w.Wafer号
			from dbo.ufnGetListFromSourceString(@WaferList,',') f
            join dbo.Wafer w on f.MyColumn=w.Wafer号
            where f.MyColumn<>''
	end
	else
	begin
        if @ProductStatus=1
        begin
		    insert #WaferList(Wafer)
			    select distinct s.Wafer号
			    from dbo.Wafer s
			    where left(s.SourceName,8) = @ProductModel
                and s.测试结束时间>='2020-01-01'
                and (s.划片结束时间 is null or s.划片结束时间 = '1899-12-31')
        end
        else if @ProductStatus=2
        begin
		    insert #WaferList(Wafer)
			select distinct s.Wafer号
			from dbo.Wafer s
			where left(s.SourceName,8) = @ProductModel
            and s.划片结束时间>='2020-01-01'
            and (s.包装结束时间 is null or s.包装结束时间 = '1899-12-31')
        end
        else if @ProductStatus=3
        begin
		    insert #WaferList(Wafer)
			select distinct s.Wafer号
			from dbo.Wafer s
			where left(s.SourceName,8) = @ProductModel
            and s.包装结束时间>='2020-01-01'
        end
	end

    SELECT
        w.[ID],
        w.[Wafer号],
        w.[特殊备注],
        w.[测试数量],
        w.[测试通过数量bin1],
        w.[测试不良数量bin2],
        w.[划片不良数量bin23],
        w.[划片后sampling bin24],
        w.[分拣不良数量bin25],
        w.[挑粒投入],
        w.[挑粒产出],
        w.[目检产出],
        w.[划片开始时间],
        w.[划片结束时间],
        w.[挑粒开始时间],
        w.[挑粒结束时间],
        w.[复判照片结束时间],
        w.[OQC结束时间],
        w.[包装结束时间],
        w.[测试良率],
        w.[挑粒良率],
        w.[目检良率],
        w.[滚动良率],
        w.[目检结束时间],
        w.[划痕HH],
        w.[扎痕ZH],
        w.[脏污ZW],
        w.[崩裂BL],
        w.[测试开始时间],
        w.[测试结束时间],
        w.[AOI开始],
        w.[AOI结束],
        w.[目检开始时间],
        w.[复判照片开始时间],
        w.[OQC开始时间],
        w.[包装开始时间],
        w.[pn],
        w.[Lot号],
        w.[Lead TIME],
        w.[复判-挑粒结束],
        w.[目检标准],
        w.[流程],
        w.[SourceName],
        w.[FileModifiedTime],
        w.[更新日期],
        w.[Cdt],
        w.[Udt],
        w.[SourceDir],
        w.[Binmap_SpecVersion],
        w.[Binmap_ImportTime],
        ISNULL(x.Bin7, 0) AS DS_Bin7,
        ISNULL(x.Bin8, 0) AS DS_Bin8
    FROM dbo.Wafer w
    join #WaferList l on w.Wafer号=l.Wafer
    LEFT JOIN (
        SELECT
            d.LotWafer,
            SUM(CASE WHEN d.bin = 7 THEN 1 ELSE 0 END) AS Bin7,
            SUM(CASE WHEN d.bin = 8 THEN 1 ELSE 0 END) AS Bin8
        FROM dbo.Die d
        WHERE d.bin IN (7, 8)
        GROUP BY d.LotWafer
    ) x
        ON x.LotWafer = w.[Wafer号];

END