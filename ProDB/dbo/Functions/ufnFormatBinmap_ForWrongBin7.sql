
/*
Jackie 20260206
1.@originalBinMap中每@Box_X个字符可以定义为1行， 加上行号叫y, y以1开始， 后续每行+1
2.@originalBinMap中各个满行的字符保持不变
3.@originalBinMap的尾行如果是奇数行， 则在其右边补0已达到满行；如果是偶数行， 则在其左边补0已达到满行；
4.如果@originalBinMap总长度没达到 @Box_X * @Box_Y的长度，将@originalBinMap字符串在末尾补’0', 以达到@Box_X * @Box_Y的长度
select dbo.ufnFormatBinmap_ForWrongBin7('772272222287877278',12,10)

change log:
*/
CREATE   FUNCTION dbo.ufnFormatBinmap_ForWrongBin7
(
    @originalBinMap NVARCHAR(MAX),
    @Box_X INT,
    @Box_Y INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    -- 基础安全检查
    IF @Box_X <= 0 OR @Box_Y <= 0 RETURN @originalBinMap;

    DECLARE @Result NVARCHAR(MAX) = '';
    DECLARE @TotalInputLen INT = ISNULL(LEN(@originalBinMap), 0);
    DECLARE @y INT = 1;

    -- 循环处理每一行，直到达到 @Box_Y 指定的高度
    WHILE @y <= @Box_Y
    BEGIN
        DECLARE @Start INT = ((@y - 1) * @Box_X) + 1;
        DECLARE @RowStr NVARCHAR(MAX) = '';

        -- 情况 1 & 2 & 3：处理原始数据（包括满行和尾行）
        IF @Start <= @TotalInputLen
        BEGIN
            SET @RowStr = SUBSTRING(@originalBinMap, @Start, @Box_X);
            DECLARE @CurrentRowLen INT = LEN(@RowStr);
            -- 情况 3：如果当前行未满（说明是原始字符串的尾行）
            IF @CurrentRowLen < @Box_X
            BEGIN
                IF @y % 2 <> 0 
                    -- 奇数行：右补0
                    SET @RowStr = @RowStr + REPLICATE('0', @Box_X - @CurrentRowLen);
                ELSE           
                    -- 偶数行：左补0
                    SET @RowStr = REPLICATE('0', @Box_X - @CurrentRowLen) + @RowStr;
            END
        END
        -- 情况 4：如果原始数据已取完，但还未达到 @Box_Y 的高度，全补 '0'
        ELSE
        BEGIN
            SET @RowStr = REPLICATE('0', @Box_X);
        END

        -- 累加到结果字符串
        SET @Result = @Result + @RowStr;
        SET @y = @y + 1;
    END

    RETURN @Result;
END