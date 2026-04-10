/*
Jackie Chen 2026-01-27

select dbo.[ufnGetStation_FromCPTestFilePath]('Y:\Production\3.测试数据\CORAL6P0\WLT\LN42184\LN42184-W17_TEST4\CORAL6P0_LN42184_W17_DR8_1.xlsx')
*/
CREATE   FUNCTION [dbo].[ufnGetStation_FromCPTestFilePath]
(
    @FilePath VARCHAR(400)
)
RETURNS VARCHAR(20)    -- 返回格式：y_x
AS
BEGIN
    -- Station 解析：取 XXxxxx\XXxxxx-Wxx 后面的那段（可能为空/_TESTn/other），并去掉前导 '_'
    DECLARE @Station varchar(20) = '';

    ;WITH s AS
    (
        SELECT p = @FilePath  --Y:\Production\3.测试数据\CORAL6P0\WLT\LN41686\LN41686-W02_TEST4\CORAL6P0_LN41686_W02_DR8_1.xlsx
    )
    SELECT @Station =
        CASE
            WHEN seg IS NULL OR seg = '' THEN ''
            WHEN LEFT(seg, 1) IN ('_', '-') THEN LEFT(SUBSTRING(seg, 2, 20), 20)
            ELSE LEFT(seg, 20)
        END
    FROM s
    CROSS APPLY
    (
        -- 1) 从 \WLT\ 后开始
        SELECT startPos = NULLIF(CHARINDEX('\WLT\', p), 0)
    ) a
    CROSS APPLY
    (
        SELECT afterAnchor =
            CASE WHEN a.startPos IS NULL THEN NULL
                    ELSE SUBSTRING(p, a.startPos + 5, 400)  -- 跳过 '\WLT\' 长度=5
            END
    ) b
    CROSS APPLY
    (
        -- 2) 固定格式：LNxxxxx\LNxxxxx-Wxx （长度固定 19），后面紧跟 _TESTn 或 \（无_TEST段）
        SELECT tail =
            CASE WHEN b.afterAnchor IS NULL THEN NULL
                    ELSE SUBSTRING(b.afterAnchor, 20, 400) -- 从第20位开始：'_TEST4\...' 或 '\CORAL...'
            END
    ) c
    CROSS APPLY
    (
        -- 3) 取到下一个 '\' 前的段；如果第一位就是 '\'，表示没有 TEST 段
        SELECT seg =
            CASE
                WHEN c.tail IS NULL THEN NULL
                WHEN LEFT(c.tail,1) = '\' THEN ''
                ELSE LEFT(c.tail, CHARINDEX('\', c.tail + '\') - 1)
            END
    ) d;

    RETURN @Station;
END;