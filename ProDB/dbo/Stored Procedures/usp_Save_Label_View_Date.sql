
/*
2026-05013 Jackie Chen HackWay to print labels of special date
EXEC dbo.usp_Save_Label_View_Date
    @Label_View = 'v_WH03_BOXLABEL',
    @Date = '2026-05-10',
    @UserID = 2
EXEC dbo.usp_Save_Label_View_Date
    @Label_View = 'v_WH03_BOXLABEL',
    @Date = NULL,
    @UserID = 2
select * from dbo.Config_Label_View_Date

Change Log:
*/
CREATE   PROCEDURE [dbo].[usp_Save_Label_View_Date]
    @Label_View nvarchar(128),
    @Date date = NULL,
    @UserID int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRAN;

    IF EXISTS (
        SELECT 1 
        FROM dbo.Config_Label_View_Date 
        WHERE Label_View = @Label_View
    )
    BEGIN
        INSERT INTO dbo.Config_Label_View_Date_History
        (
            ID,
            Label_View,
            [Date],
            Cdt,
            Udt,
            UserID,
            Updated_UserID
        )
        SELECT
            ID,
            Label_View,
            [Date],
            Cdt,
            Udt,
            UserID,
            @UserID
        FROM dbo.Config_Label_View_Date
        WHERE Label_View = @Label_View;

        UPDATE dbo.Config_Label_View_Date
        SET 
            [Date] = @Date,
            Udt = GETDATE(),
            UserID = @UserID
        WHERE Label_View = @Label_View;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.Config_Label_View_Date
        (
            Label_View,
            [Date],
            UserID
        )
        VALUES
        (
            @Label_View,
            @Date,
            @UserID
        );
    END

    COMMIT TRAN;
END;