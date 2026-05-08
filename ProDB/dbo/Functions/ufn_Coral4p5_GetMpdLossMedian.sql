/*
Create by Jackiech on 2026-05-07
SELECT * FROM [dbo].[ufn_Coral4p5_GetMpdLossMedian]('LN34376-W01')
SELECT * FROM [dbo].[ufn_Coral4p5_GetMpdLossMedian]('LN34376-W02')
SELECT * FROM [dbo].[ufn_Coral4p5_GetMpdLossMedian]('LN34376-W03')

Change Log:
2026-05-07 Jackiech
- Change algorithm from channel-level median average to pooled channel data median.
- All valid channel values are combined into one data set before median/std calculation.
*/
CREATE   FUNCTION [dbo].[ufn_Coral4p5_GetMpdLossMedian]
(
    @LotWafer varchar(11)
)
RETURNS @Result TABLE
(
    LotWafer varchar(11) NOT NULL,
    MpdLossMedian float NULL,
    ValidChannelCount int NOT NULL,
    ExpectedChannelCount int NOT NULL,
    RawDataCount int NOT NULL,
    RangeDataCount int NOT NULL,
    SigmaDataCount int NOT NULL,
    RangeMedian float NULL,
    RangeStd float NULL
)
AS
BEGIN

    --DECLARE @LotWafer varchar(11) = 'LN34376-W01'
    DECLARE @ProductFamily varchar(20);
    DECLARE @ExpectedChannelCount int;

    DECLARE @RawDataCount int;
    DECLARE @RangeDataCount int;
    DECLARE @SigmaDataCount int;
    DECLARE @ValidChannelCount int;

    DECLARE @RangeMedian float;
    DECLARE @RangeStd float;
    DECLARE @MpdLossMedian float;

    DECLARE @RawData TABLE
    (
        ChannelNo tinyint NOT NULL,
        MpdLoss float NULL
    );

    DECLARE @RangeData TABLE
    (
        ChannelNo tinyint NOT NULL,
        MpdLoss float NOT NULL
    );

    DECLARE @SigmaData TABLE
    (
        ChannelNo tinyint NOT NULL,
        MpdLoss float NOT NULL
    );

    SELECT @ProductFamily = f.ProductModel
        FROM dbo.CPTest_File f
        WHERE f.LotWafer = @LotWafer
        AND f.isRecent = 1;
    SELECT @ExpectedChannelCount = p.Spec_ChannelNum
        FROM dbo.ProductModel p
        WHERE p.ProductModel = @ProductFamily;
    SET @ExpectedChannelCount = ISNULL(@ExpectedChannelCount, 0);

    INSERT INTO @RawData(ChannelNo,MpdLoss)
        SELECT v.ChannelNo, v.MpdLoss
        FROM dbo.vw_CPTestData p
        CROSS APPLY
        (
        VALUES
            (1, TRY_CONVERT(float, p.Onchip_MPD_CH01)),
            (2, TRY_CONVERT(float, p.Onchip_MPD_CH02)),
            (3, TRY_CONVERT(float, p.Onchip_MPD_CH03)),
            (4, TRY_CONVERT(float, p.Onchip_MPD_CH04)),
            (5, TRY_CONVERT(float, p.Onchip_MPD_CH05)),
            (6, TRY_CONVERT(float, p.Onchip_MPD_CH06)),
            (7, TRY_CONVERT(float, p.Onchip_MPD_CH07)),
            (8, TRY_CONVERT(float, p.Onchip_MPD_CH08))
        ) v(ChannelNo, MpdLoss)
        WHERE p.LotWafer = @LotWafer
        AND p.isRecent = 1
        AND v.ChannelNo <= @ExpectedChannelCount;
    --select * from @RawData

    INSERT INTO @RangeData(ChannelNo,MpdLoss)
        SELECT ChannelNo, MpdLoss
        FROM @RawData
        WHERE MpdLoss IS NOT NULL
        AND MpdLoss >= 0
        AND MpdLoss <= 100;

    SELECT @RawDataCount = COUNT(*) FROM @RawData;
    SELECT @RangeDataCount = COUNT(*) FROM @RangeData;

    SELECT TOP (1)
        @RangeMedian = x.RangeMedian,
        @RangeStd = x.RangeStd
    FROM
    (
        SELECT
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY MpdLoss) OVER () AS RangeMedian,
            STDEVP(MpdLoss) OVER () AS RangeStd
        FROM @RangeData
    ) x;

    INSERT INTO @SigmaData(ChannelNo,MpdLoss)
        SELECT ChannelNo, MpdLoss
        FROM @RangeData
        WHERE MpdLoss > @RangeMedian - 6.0 * @RangeStd
        AND MpdLoss < @RangeMedian + 6.0 * @RangeStd;

    SELECT @SigmaDataCount = COUNT(*) FROM @SigmaData;

    SELECT
        @ValidChannelCount = COUNT(DISTINCT ChannelNo)
    FROM @SigmaData;

    SELECT TOP (1)
        @MpdLossMedian = x.MpdLossMedian
    FROM
    (
        SELECT
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY MpdLoss) OVER () AS MpdLossMedian
        FROM @SigmaData
    ) x;

    INSERT INTO @Result
    (
        LotWafer,
        MpdLossMedian,
        ValidChannelCount,
        ExpectedChannelCount,
        RawDataCount,
        RangeDataCount,
        SigmaDataCount,
        RangeMedian,
        RangeStd
    )
    SELECT
        @LotWafer AS LotWafer,
        @MpdLossMedian AS MpdLossMedian,
        ISNULL(@ValidChannelCount, 0) AS ValidChannelCount,
        ISNULL(@ExpectedChannelCount, 0) AS ExpectedChannelCount,
        ISNULL(@RawDataCount, 0) AS RawDataCount,
        ISNULL(@RangeDataCount, 0) AS RangeDataCount,
        ISNULL(@SigmaDataCount, 0) AS SigmaDataCount,
        @RangeMedian AS RangeMedian,
        @RangeStd AS RangeStd;

    RETURN;
END;