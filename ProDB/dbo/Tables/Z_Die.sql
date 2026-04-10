CREATE TABLE [dbo].[Z_Die] (
    [LotWafer] VARCHAR (20) NOT NULL,
    [Seqid]    INT          NOT NULL,
    [Cbin]     VARCHAR (7)  NULL
);




GO
CREATE NONCLUSTERED INDEX [IX_Z_Die_LotWafer_Cbin]
    ON [dbo].[Z_Die]([LotWafer] ASC, [Cbin] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Z_Die] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Z_Die] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Z_Die] TO [Production]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Z_Die] TO [Production]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[Z_Die] TO [Production]
    AS [dbo];

