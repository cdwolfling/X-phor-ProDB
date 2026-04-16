CREATE TABLE [dbo].[LotWafer_UEC_Mean_Std] (
    [LotWafer]           VARCHAR (11) NOT NULL,
    [CPFileTime]         DATETIME     NULL,
    [Mean]               FLOAT (53)   NULL,
    [Std]                FLOAT (53)   NULL,
    [Cdt]                DATETIME     CONSTRAINT [DF_LotWafer_UEC_Mean_Std_Cdt] DEFAULT (getdate()) NULL,
    [Udt]                DATETIME     CONSTRAINT [DF_LotWafer_UEC_Mean_Std_Udt] DEFAULT (getdate()) NULL,
    [FinishDieParameter] BIT          CONSTRAINT [DF_LotWafer_UEC_Mean_Std_FinishDieParameter] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_LotWafer_UEC_Mean_Std] PRIMARY KEY CLUSTERED ([LotWafer] ASC)
);


GO
/*
Change Log:
*/
CREATE TRIGGER [dbo].[trg_LotWafer_UEC_Mean_Std_Update]
ON [dbo].[LotWafer_UEC_Mean_Std]
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    /* ========= DELETE：一律写历史 ========= */
    IF NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.LotWafer_UEC_Mean_Std_History
               (LotWafer, CPFileTime, Mean, Std, FinishDieParameter)
        SELECT LotWafer, CPFileTime, Mean, Std, FinishDieParameter
        FROM deleted;

        RETURN;
    END

    /* ========= UPDATE：仅当“非(GenerateShippingData_Cdt/ImportTraySN_Cdt/Udt)”字段变化才写历史 ========= */
    IF EXISTS
    (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d
            ON i.LotWafer = d.LotWafer
        WHERE
            /* 下面这些列：只要任意一列新旧不同，就认为是“有效变更”，需要写历史 */
               ISNULL(CONVERT(datetime2(0), i.CPFileTime), '19000101') <> ISNULL(CONVERT(datetime2(0), d.CPFileTime), '19000101')
            OR ISNULL(i.Mean,0) <> ISNULL(d.Mean,0)
            OR ISNULL(i.Std,'') <> ISNULL(d.Std,'')
    )
    BEGIN
        INSERT INTO dbo.LotWafer_UEC_Mean_Std_History
               (LotWafer, CPFileTime, Mean, Std, FinishDieParameter)
        SELECT LotWafer, CPFileTime, Mean, Std, FinishDieParameter
        FROM deleted;
    END
END