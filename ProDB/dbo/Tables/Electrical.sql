CREATE TABLE [dbo].[Electrical] (
    [Electrical_ID]        INT             IDENTITY (1, 1) NOT NULL,
    [LotID_Wafer_Die_ID]   VARCHAR (25)    NOT NULL,
    [Die_ID]               VARCHAR (15)    NOT NULL,
    [LotID_Wafer]          VARCHAR (15)    NOT NULL,
    [PPI_CH01]             DECIMAL (15, 6) NULL,
    [PPI_CH02]             DECIMAL (15, 6) NULL,
    [PPI_CH03]             DECIMAL (15, 6) NULL,
    [PPI_CH04]             DECIMAL (15, 6) NULL,
    [HTU_CH01]             DECIMAL (15, 6) NULL,
    [HTU_CH02]             DECIMAL (15, 6) NULL,
    [HTU_CH03]             DECIMAL (15, 6) NULL,
    [HTU_CH04]             DECIMAL (15, 6) NULL,
    [Onchip_loss_CH01_MPD] DECIMAL (15, 6) NULL,
    [Onchip_loss_CH02_MPD] DECIMAL (15, 6) NULL,
    [Onchip_loss_CH03_MPD] DECIMAL (15, 6) NULL,
    [Onchip_loss_CH04_MPD] DECIMAL (15, 6) NULL,
    [IMPD_CH01_C]          DECIMAL (15, 6) NULL,
    [OMPDM_CH01_C]         DECIMAL (15, 6) NULL,
    [OMPDM_CH02_C]         DECIMAL (15, 6) NULL,
    [OMPDM_CH03_C]         DECIMAL (15, 6) NULL,
    [OMPDM_CH04_C]         DECIMAL (15, 6) NULL,
    [OMPDS_CH01_C]         DECIMAL (15, 6) NULL,
    [OMPDS_CH02_C]         DECIMAL (15, 6) NULL,
    [OMPDS_CH03_C]         DECIMAL (15, 6) NULL,
    [OMPDS_CH04_C]         DECIMAL (15, 6) NULL,
    [Test_Num]             INT             NULL,
    CONSTRAINT [PK_ELECTRICAL] PRIMARY KEY CLUSTERED ([Electrical_ID] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [Electrical_PK]
    ON [dbo].[Electrical]([Electrical_ID] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Electrical] TO [Production1]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Electrical] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Electrical] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Electrical] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Electrical] TO [Production1]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Electrical] TO [Production]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Electrical] TO [Production1]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Electrical] TO [Production]
    AS [dbo];

