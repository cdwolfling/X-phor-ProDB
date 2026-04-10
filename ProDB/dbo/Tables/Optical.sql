CREATE TABLE [dbo].[Optical] (
    [Optical_ID]         INT             IDENTITY (1, 1) NOT NULL,
    [LotID_Wafer_Die_ID] VARCHAR (25)    NOT NULL,
    [Die_ID]             VARCHAR (15)    NOT NULL,
    [LotID_Wafer]        VARCHAR (15)    NOT NULL,
    [UGC_CW]             DECIMAL (15, 6) NULL,
    [UGC]                DECIMAL (15, 6) NULL,
    [UEC]                DECIMAL (15, 6) NULL,
    [UEC_Onchip]         DECIMAL (15, 6) NULL,
    [CH01]               DECIMAL (15, 6) NULL,
    [CH02]               DECIMAL (15, 6) NULL,
    [CH03]               DECIMAL (15, 6) NULL,
    [CH04]               DECIMAL (15, 6) NULL,
    [Loss_range]         DECIMAL (15, 6) NULL,
    [ER_CH01]            DECIMAL (15, 6) NULL,
    [ER_CH02]            DECIMAL (15, 6) NULL,
    [ER_CH03]            DECIMAL (15, 6) NULL,
    [ER_CH04]            DECIMAL (15, 6) NULL,
    [Test_Num]           INT             NULL,
    CONSTRAINT [PK_OPTICAL] PRIMARY KEY CLUSTERED ([Optical_ID] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [Optical_PK]
    ON [dbo].[Optical]([Optical_ID] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Optical] TO [Production1]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Optical] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Optical] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Optical] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Optical] TO [Production1]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Optical] TO [Production]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Optical] TO [Production1]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Optical] TO [Production]
    AS [dbo];

