/*
从Traveler同步Wafer信息至数据库

Change Log:
2026-01-22 JC: Add Input @SourceDir
2025-12-22 JC: Add Output
2025-12-21 JC: Initial
*/
CREATE PROC [dbo].[usp_SyncWaferFromTraveler]
(
    @Wafer号               varchar(50),
    @特殊备注               varchar(500) = NULL,
    @测试数量               int          = NULL,
    @测试通过数量bin1       int          = NULL,
    @测试不良数量bin2       int          = NULL,
    @划片不良数量bin23      int          = NULL,
    @划片后sampling_bin24   int          = NULL,
    @分拣不良数量bin25      int          = NULL,
    @挑粒投入               int          = NULL,
    @挑粒产出               int          = NULL,
    @目检产出               int          = NULL,
    @划片开始时间           datetime     = NULL,
    @划片结束时间           datetime     = NULL,
    @挑粒开始时间           datetime     = NULL,
    @挑粒结束时间           datetime     = NULL,
    @复判照片结束时间       datetime     = NULL,
    @OQC结束时间            datetime     = NULL,
    @包装结束时间           datetime     = NULL,
    @测试良率               float        = NULL,
    @挑粒良率               float        = NULL,
    @目检良率               float        = NULL,
    @滚动良率               float        = NULL,
    @目检结束时间           datetime     = NULL,
    @划痕HH                 int          = NULL,
    @扎痕ZH                 int          = NULL,
    @脏污ZW                 int          = NULL,
    @崩裂BL                 int          = NULL,
    @测试开始时间           datetime     = NULL,
    @测试结束时间           datetime     = NULL,
    @AOI开始                datetime     = NULL,
    @AOI结束                datetime     = NULL,
    @目检开始时间           datetime     = NULL,
    @复判照片开始时间       datetime     = NULL,
    @OQC开始时间            datetime     = NULL,
    @包装开始时间           datetime     = NULL,
    @pn                     varchar(50)  = NULL,
    @Lot号                  varchar(50)  = NULL,
    @Lead_TIME              float        = NULL,
    @复判_挑粒结束          float        = NULL,
    @目检标准               varchar(200) = NULL,
    @流程                   varchar(200) = NULL,
    @SourceName             varchar(200) = NULL,
    @FileModifiedTime       datetime     = NULL,
    @更新日期               datetime     = NULL,
    @SourceDir             varchar(200) = NULL
    )
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS(SELECT * FROM dbo.Wafer w WHERE w.Wafer号 = @Wafer号)
    BEGIN
        INSERT INTO [dbo].[Wafer]
               ([Wafer号],[特殊备注],[测试数量],[测试通过数量bin1],[测试不良数量bin2],
                [划片不良数量bin23],[划片后sampling bin24],[分拣不良数量bin25],
                [挑粒投入],[挑粒产出],[目检产出],
                [划片开始时间],[划片结束时间],[挑粒开始时间],[挑粒结束时间],
                [复判照片结束时间],[OQC结束时间],[包装结束时间],
                [测试良率],[挑粒良率],[目检良率],[滚动良率],[目检结束时间],
                [划痕HH],[扎痕ZH],[脏污ZW],[崩裂BL],
                [测试开始时间],[测试结束时间],[AOI开始],[AOI结束],
                [目检开始时间],[复判照片开始时间],[OQC开始时间],[包装开始时间],
                [pn],[Lot号],[Lead TIME],[复判-挑粒结束],
                [目检标准],[流程],[SourceName],[FileModifiedTime],[更新日期], SourceDir)
        VALUES (@Wafer号,@特殊备注,@测试数量,@测试通过数量bin1,@测试不良数量bin2,
                @划片不良数量bin23,@划片后sampling_bin24,@分拣不良数量bin25,
                @挑粒投入,@挑粒产出,@目检产出,
                @划片开始时间,@划片结束时间,@挑粒开始时间,@挑粒结束时间,
                @复判照片结束时间,@OQC结束时间,@包装结束时间,
                @测试良率,@挑粒良率,@目检良率,@滚动良率,@目检结束时间,
                @划痕HH,@扎痕ZH,@脏污ZW,@崩裂BL,
                @测试开始时间,@测试结束时间,@AOI开始,@AOI结束,
                @目检开始时间,@复判照片开始时间,@OQC开始时间,@包装开始时间,
                @pn,@Lot号,@Lead_TIME,@复判_挑粒结束,
                @目检标准,@流程,@SourceName,@FileModifiedTime,@更新日期, @SourceDir)
    END
    ELSE
    BEGIN
	    UPDATE T SET T.[Wafer号] = @Wafer号
		    , T.[特殊备注] =@特殊备注
		    , T.[测试数量] = @测试数量
		    , T.[测试通过数量bin1] = @测试通过数量bin1
		    , T.[测试不良数量bin2] = @测试不良数量bin2
		    , T.[划片不良数量bin23] = @划片不良数量bin23
		    , T.[划片后sampling bin24] = @划片后sampling_bin24
		    , T.[分拣不良数量bin25] = @分拣不良数量bin25
		    , T.[挑粒投入] = @挑粒投入
		    , T.[挑粒产出] = @挑粒产出
		    , T.[目检产出] = @目检产出
		    , T.[划片开始时间] = @划片开始时间
		    , T.[划片结束时间] = @划片结束时间
		    , T.[挑粒开始时间] = @挑粒开始时间
		    , T.[挑粒结束时间] = @挑粒结束时间
		    , T.[复判照片结束时间] = @复判照片结束时间
		    , T.[OQC结束时间] = @OQC结束时间
		    , T.[包装结束时间] = @包装结束时间
		    , T.[测试良率] = @测试良率
		    , T.[挑粒良率] = @挑粒良率
		    , T.[目检良率] = @目检良率
		    , T.[滚动良率] = @滚动良率
		    , T.[目检结束时间] = @目检结束时间
		    , T.[划痕HH] = @划痕HH
		    , T.[扎痕ZH] = @扎痕ZH
		    , T.[脏污ZW] = @脏污ZW
		    , T.[崩裂BL] = @崩裂BL
		    , T.[测试开始时间] = @测试开始时间
		    , T.[测试结束时间] = @测试结束时间
		    , T.[AOI开始] = @AOI开始
		    , T.[AOI结束] = @AOI结束
		    , T.[目检开始时间] = @目检开始时间
		    , T.[复判照片开始时间] = @复判照片开始时间
		    , T.[OQC开始时间] = @OQC开始时间
		    , T.[包装开始时间] = @包装开始时间
		    , T.[pn] = @pn
		    , T.[Lot号] = @Lot号
		    , T.[Lead TIME] = @Lead_TIME
		    , T.[复判-挑粒结束] = @复判_挑粒结束
		    , T.[目检标准] = @目检标准
		    , T.[流程] = @流程
		    , T.[SourceName] = @SourceName
		    , T.[FileModifiedTime] = @FileModifiedTime
		    , T.[更新日期] = @更新日期
		    , T.Udt = GETDATE()
		    , T.[SourceDir] = @SourceDir
	        FROM dbo.Wafer AS T
		    WHERE T.[Wafer号] = @Wafer号
    END

    SELECT StatusCode = 0, Message = @Wafer号 + '已同步至dbo.Wafer'
END