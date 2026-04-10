
/*
Created by Jackie Chen 2025/12/28

select dbo.ufn_YearWeekCode('2025/12/28')
select dbo.ufn_YearWeekCode('2025/12/29')
*/
CREATE   FUNCTION dbo.ufn_YearWeekCode
(
    @Ship_date date
)
RETURNS char(6)
AS
BEGIN
    IF @Ship_date IS NULL
        RETURN NULL;

    DECLARE @isoWeek int = DATEPART(ISO_WEEK, @Ship_date);

    -- ISO 年：取该 ISO 周“星期四”所在的年份（等价实现）
    DECLARE @isoYear int = YEAR(DATEADD(day, 26 - @isoWeek, @Ship_date));

    RETURN CAST(CONCAT(@isoYear, RIGHT('0' + CONVERT(varchar(2), @isoWeek), 2)) AS char(6));
END