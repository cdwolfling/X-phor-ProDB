CREATE TABLE [dbo].[Die_list] (
    [Die_list_ID]        INT          IDENTITY (1, 1) NOT NULL,
    [LotID_Wafer_Die_ID] VARCHAR (25) NOT NULL,
    [Die_ID]             VARCHAR (15) NOT NULL,
    [LotID_Wafer]        VARCHAR (15) NOT NULL,
    [PASS_FAIL]          VARCHAR (15) NULL,
    [UEC_Onchip]         VARCHAR (15) NULL,
    [IL]                 VARCHAR (15) NULL,
    [Loss_range]         VARCHAR (15) NULL,
    [ER]                 VARCHAR (15) NULL,
    [PPI]                VARCHAR (15) NULL,
    [HTU]                VARCHAR (15) NULL,
    [Onchip_loss_MPD]    VARCHAR (15) NULL,
    [MPD_DC]             VARCHAR (15) NULL,
    [MPD_OC]             VARCHAR (15) NULL,
    [Test_Num]           INT          NULL,
    CONSTRAINT [PK_DIE_LIST] PRIMARY KEY CLUSTERED ([Die_list_ID] ASC)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Die_list] TO [Production1]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Die_list] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Die_list] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Die_list] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Die_list] TO [Production1]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Die_list] TO [Production]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Die_list] TO [Production1]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Die_list] TO [Production]
    AS [dbo];

