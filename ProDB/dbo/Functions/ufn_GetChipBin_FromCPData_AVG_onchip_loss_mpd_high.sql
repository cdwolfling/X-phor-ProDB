/*
Create by Jackiech on 2026-04-01
SELECT dbo.[ufn_GetChipBin_FromCPData_AVG_onchip_loss_mpd_high]('LN41477-W01', 'E07-403') AS Bin_AVG_onchip_loss_mpd_high

Change Log:
2026-04-21 JC: Initial. Base ufn_GetChipBin_FromCPData
*/
CREATE   FUNCTION [dbo].[ufn_GetChipBin_FromCPData_AVG_onchip_loss_mpd_high]
(
    @LotWafer VARCHAR(50),
    @ChipSN   VARCHAR(50)
)
RETURNS INT
AS
BEGIN
    --declare @LotWafer VARCHAR(50)='LN47756-W06'
    --declare @ChipSN   VARCHAR(50)='A04-104'

    DECLARE @Bin INT = 2;  -- 默认 Bin2（兜底）
    DECLARE @ChannelNum INT, @impdNum INT

    -- =============================================
    -- 1. Spec 参数（替换为从配置表动态读取）
    -- =============================================
    DECLARE @ProductFamily      VARCHAR(50)
    SELECT @ProductFamily=left(w.SourceName,8) from dbo.Wafer w where w.Wafer号=@LotWafer
    SELECT @ChannelNum = case when @ProductFamily in ('Coral3p1','Coral3p5') then 4
                            when @ProductFamily in ('Coral4p1','Coral6p0','Coral6p3') then 8
                        end
    SELECT @impdNum = case when @ProductFamily in ('Coral3p1','Coral3p5') then 1
                            when @ProductFamily in ('Coral4p1','Coral6p0') then 2
                            when @ProductFamily in ('Coral6p3') then 4
                        end
    IF @ChannelNum is null
    BEGIN
        RETURN -1
    END;

    DECLARE @AVG_onchip_loss_mpd_high     FLOAT = 11


    -- =============================================
    -- 2. 取芯片数据
    -- =============================================
    DECLARE @v TABLE
    (
        Onchip_loss_CH01_MPD   FLOAT,
        Onchip_loss_CH02_MPD   FLOAT,
        Onchip_loss_CH03_MPD   FLOAT,
        Onchip_loss_CH04_MPD   FLOAT,
        Onchip_loss_CH05_MPD   FLOAT,
        Onchip_loss_CH06_MPD   FLOAT,
        Onchip_loss_CH07_MPD   FLOAT,
        Onchip_loss_CH08_MPD   FLOAT
    );
    INSERT INTO @v
    SELECT       
        Onchip_loss_CH01_MPD,Onchip_loss_CH02_MPD,Onchip_loss_CH03_MPD,Onchip_loss_CH04_MPD,Onchip_loss_CH05_MPD,Onchip_loss_CH06_MPD,Onchip_loss_CH07_MPD,Onchip_loss_CH08_MPD
    FROM dbo.vw_CPTestData v
    WHERE v.LotWafer = @LotWafer
        AND v.ChipSN   = @ChipSN
        AND v.isRecent = 1;
    
    IF NOT EXISTS (SELECT 1 FROM @v)
    BEGIN
        --PRINT '找不到数据'
        RETURN 0;
    END;

    -- =============================================
    -- 3. 非数值检查
    --    任一必需判定列为空，直接 Bin2
    -- =============================================
    IF @ChannelNum = 4 and @impdNum = 1
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM @v
            WHERE Onchip_loss_CH01_MPD IS NULL OR Onchip_loss_CH02_MPD IS NULL OR Onchip_loss_CH03_MPD IS NULL OR Onchip_loss_CH04_MPD IS NULL
        )
        BEGIN
            RETURN 2;
        END;
    END
    ELSE IF @ChannelNum = 8 and @impdNum = 2
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM @v
            WHERE Onchip_loss_CH01_MPD IS NULL OR Onchip_loss_CH02_MPD IS NULL OR Onchip_loss_CH03_MPD IS NULL OR Onchip_loss_CH04_MPD IS NULL OR Onchip_loss_CH05_MPD IS NULL OR Onchip_loss_CH06_MPD IS NULL OR Onchip_loss_CH07_MPD IS NULL OR Onchip_loss_CH08_MPD IS NULL
        )
        BEGIN
            RETURN 2;
        END;
    END

    -- =============================================
    -- 4. 取 whole wafer 的 mean/std，生成 UEC 动态上下限, 再结合@uec_high/@uec_low
    -- =============================================


    -- =============================================
    -- 5. 各项 Fail 判定
    -- =============================================
    DECLARE @fail INT = 0;
    DECLARE @fail_ER INT = 0;

    -- 5.4 onchip_loss_mpd：按 @ChannelNum 检查 CHxx
    IF EXISTS
    (
        SELECT 1
        FROM @v AS v
        CROSS APPLY
        (
            SELECT AVG(x.loss_value * 1.0) AS avg_loss_value
            FROM (VALUES
                (1, v.Onchip_loss_CH01_MPD),
                (2, v.Onchip_loss_CH02_MPD),
                (3, v.Onchip_loss_CH03_MPD),
                (4, v.Onchip_loss_CH04_MPD),
                (5, v.Onchip_loss_CH05_MPD),
                (6, v.Onchip_loss_CH06_MPD),
                (7, v.Onchip_loss_CH07_MPD),
                (8, v.Onchip_loss_CH08_MPD)
            ) AS x(ch_no, loss_value)
            WHERE x.ch_no <= @ChannelNum
        ) AS ca
        WHERE ca.avg_loss_value >= @AVG_onchip_loss_mpd_high
    )
    BEGIN
        --PRINT '5.4'
        RETURN 2
    END

    RETURN 1


END