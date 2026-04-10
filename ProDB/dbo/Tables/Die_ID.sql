CREATE TABLE [dbo].[Die_ID] (
    [ID]                 INT          IDENTITY (1, 1) NOT NULL,
    [LotID_Wafer_Die_ID] VARCHAR (25) NULL,
    [Die_ID]             VARCHAR (15) NOT NULL,
    [LotID_Wafer]        VARCHAR (15) NOT NULL,
    [Dev_ID]             VARCHAR (15) NULL,
    [Die_Location]       VARCHAR (15) NULL,
    [Dev_number]         VARCHAR (15) NULL,
    CONSTRAINT [PK_DIE_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Die_ID] TO [Production1]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Die_ID] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Die_ID] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Die_ID] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Die_ID] TO [Production1]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Die_ID] TO [Production]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Die_ID] TO [Production1]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Die_ID] TO [Production]
    AS [dbo];

