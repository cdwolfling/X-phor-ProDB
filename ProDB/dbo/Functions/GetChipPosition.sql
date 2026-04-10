/*
Jackie Chen 2025-11-28

select * from dbo.Die d where LotWafer like 'LN41274-W05' and Cbin='H08-105'
select (1377-1)/252+1,dbo.GetChipPosition(1377)
*/
CREATE FUNCTION [dbo].[GetChipPosition]
(
    @SeqId INT      -- 整体序号（从 1 开始）
)
RETURNS VARCHAR(20)    -- 返回格式：y_x
AS
BEGIN
    -- 参数非法时返回 NULL
    IF @SeqId IS NULL OR @SeqId <= 0
        RETURN NULL;

    DECLARE 
        @BoxCapacity    INT = 252,   -- 每盒 18 列 * 14 行
        @Cols           INT = 18,    -- 列数
        @Rows           INT = 14,    -- 行数
        @PosInBox       INT,         -- 在当前盒中的顺序（1 ~ 252）
        @Idx            INT,         -- 从 0 开始的索引
        @RowFromBottom0 INT,         -- 自底向上第几行（0 ~ 13）
        @ColInRow0      INT,         -- 当前行内的序号（0 ~ 17）
        @X              INT,         -- 第几列
        @Y              INT,         -- 第几行
        @Result         VARCHAR(20);

    -- 盒号（如需要用到，可取消注释）
    -- DECLARE @BoxNo INT;

    -- 计算盒号：1~252 为第 1 盒，253~504 为第 2 盒，以此类推
    -- @BoxNo = ((@SeqId - 1) / @BoxCapacity) + 1;

    -- 计算在当前盒中的位置（1~252）
    SET @PosInBox = ((@SeqId - 1) % @BoxCapacity) + 1;

    -- 换算成从 0 开始的索引
    SET @Idx = @PosInBox - 1;

    -- 自底向上第几行（0=最底行=第14行，13=最顶行=第1行）
    SET @RowFromBottom0 = @Idx / @Cols;

    -- 当前行内的顺序（0~17）
    SET @ColInRow0 = @Idx % @Cols;

    -- 计算 y（行）：从上往下 1~14，所以 = 14 - 自底向上的行号
    SET @Y = @Rows - @RowFromBottom0;

    /*
        行内方向规则（蛇形）：
        - 自底向上的第 0 行（即第14行）、第2行（第12行）等：从右到左
        - 自底向上的第 1 行（第13行）、第3行（第11行）等：从左到右
    */
    IF (@RowFromBottom0 % 2 = 0)
    BEGIN
        -- 右 -> 左：第一个放在最右边（第18列）
        SET @X = @Cols - @ColInRow0;     -- 18,17,...,1
    END
    ELSE
    BEGIN
        -- 左 -> 右：第一个放在最左边（第1列）
        SET @X = 1 + @ColInRow0;         -- 1,2,...,18
    END

    -- 组合成 x_y
    SET @Result = CAST(@Y AS VARCHAR(5)) + '_' + CAST(@X AS VARCHAR(5));

    RETURN @Result;
END;