CREATE TABLE [dbo].[Die] (
    [DieID]        INT          IDENTITY (1, 1) NOT NULL,
    [LotWafer]     VARCHAR (20) NOT NULL,
    [Seqid]        INT          NOT NULL,
    [Cbin]         VARCHAR (7)  NULL,
    [Die_Location] VARCHAR (3)  NULL,
    [Dev_ID]       VARCHAR (3)  NULL,
    [Bin]          INT          NULL,
    [BoxNo]        INT          NULL,
    [AOI_name]     VARCHAR (5)  NULL,
    [Cdt]          DATETIME     CONSTRAINT [DF_Die_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Die] PRIMARY KEY CLUSTERED ([DieID] ASC)
);














GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Die_LotWafer_Cbin]
    ON [dbo].[Die]([LotWafer] ASC, [Cbin] ASC);




GO

GO


CREATE TRIGGER [dbo].[trg_Die_Delete]
ON [dbo].[Die]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    /* 把“旧”记录插入历史表 */
    INSERT INTO dbo.Die_History
           (DieID, LotWafer, Seqid, Cbin, Die_Location, Dev_ID, Bin, BoxNo, AOI_name, Cdt)
    SELECT DieID, LotWafer, Seqid, Cbin, Die_Location, Dev_ID, Bin, BoxNo, AOI_name, Cdt
    FROM deleted;
END