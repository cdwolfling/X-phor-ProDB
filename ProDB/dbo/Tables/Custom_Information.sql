CREATE TABLE [dbo].[Custom_Information] (
    [CustomerID]    INT            IDENTITY (1, 1) NOT NULL,
    [Customer_Code] VARCHAR (50)   NULL,
    [Supplier_Code] VARCHAR (50)   NULL,
    [Material_PN]   VARCHAR (50)   NULL,
    [Dev_name]      NVARCHAR (15)  NULL,
    [PN]            VARCHAR (50)   NULL,
    [Description]   NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Custom_Information] PRIMARY KEY CLUSTERED ([CustomerID] ASC)
);






GO
GRANT UPDATE
    ON OBJECT::[dbo].[Custom_Information] TO [Production1]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Custom_Information] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Custom_Information] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Custom_Information] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Custom_Information] TO [Production1]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Custom_Information] TO [Production]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Custom_Information] TO [Production1]
    AS [dbo];


GO



GO

CREATE TRIGGER [dbo].[trg_Custom_Information_Update]
ON [dbo].[Custom_Information]
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    /* 把“旧”记录插入历史表 */
    INSERT INTO dbo.Custom_Information_History
           ([CustomerID],[Customer_Code],[Supplier_Code],[Material_PN],[Dev_name],[PN],[Description])
    SELECT [CustomerID],[Customer_Code],[Supplier_Code],[Material_PN],[Dev_name],[PN],[Description]
    FROM deleted;
END
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Custom_Information_Customer_Code_PN]
    ON [dbo].[Custom_Information]([Customer_Code] ASC, [PN] ASC);

