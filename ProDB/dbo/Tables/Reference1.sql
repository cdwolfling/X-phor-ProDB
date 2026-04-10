CREATE TABLE [dbo].[Reference1] (
    [Reference_ID]       INT             IDENTITY (1, 1) NOT NULL,
    [LotID_Wafer_Die_ID] VARCHAR (25)    NOT NULL,
    [Die_ID]             VARCHAR (15)    NOT NULL,
    [LotID_Wafer]        VARCHAR (15)    NOT NULL,
    [IMPD_CH01_OC]       DECIMAL (15, 6) NULL,
    [OMPDM_CH01_OC]      DECIMAL (15, 6) NULL,
    [OMPDM_CH02_OC]      DECIMAL (15, 6) NULL,
    [OMPDM_CH03_OC]      DECIMAL (15, 6) NULL,
    [OMPDM_CH04_OC]      DECIMAL (15, 6) NULL,
    [OMPDS_CH01_OC]      DECIMAL (15, 6) NULL,
    [OMPDS_CH02_OC]      DECIMAL (15, 6) NULL,
    [OMPDS_CH03_OC]      DECIMAL (15, 6) NULL,
    [OMPDS_CH04_OC]      DECIMAL (15, 6) NULL,
    [IMPD_CH01_db]       DECIMAL (15, 6) NULL,
    [OMPDM_CH01_db]      DECIMAL (15, 6) NULL,
    [OMPDM_CH02_db]      DECIMAL (15, 6) NULL,
    [OMPDM_CH03_db]      DECIMAL (15, 6) NULL,
    [OMPDM_CH04_db]      DECIMAL (15, 6) NULL,
    [OMPDS_CH01_db]      DECIMAL (15, 6) NULL,
    [OMPDS_CH02_db]      DECIMAL (15, 6) NULL,
    [OMPDS_CH03_db]      DECIMAL (15, 6) NULL,
    [OMPDS_CH04_db]      DECIMAL (15, 6) NULL,
    [Test_Num]           INT             NULL,
    CONSTRAINT [PK_REFERENCE1] PRIMARY KEY CLUSTERED ([Reference_ID] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [Reference_PK]
    ON [dbo].[Reference1]([Reference_ID] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Reference1] TO [Production1]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Reference1] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Reference1] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Reference1] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Reference1] TO [Production1]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Reference1] TO [Production]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Reference1] TO [Production1]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Reference1] TO [Production]
    AS [dbo];

