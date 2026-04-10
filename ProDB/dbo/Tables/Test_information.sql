CREATE TABLE [dbo].[Test_information] (
    [Test_ID]               INT          IDENTITY (1, 1) NOT NULL,
    [LotID_Wafer]           VARCHAR (15) NOT NULL,
    [Tester]                VARCHAR (15) NULL,
    [Test_Num]              INT          NULL,
    [Test_Start_Time]       DATETIME     NULL,
    [Test_End_Time]         DATETIME     NULL,
    [Operator]              VARCHAR (15) NULL,
    [Test_Software_version] VARCHAR (15) NULL,
    [SPEC_version]          VARCHAR (15) NULL,
    [Dev_name]              VARCHAR (15) NULL,
    [Wafer_ID]              VARCHAR (15) NULL,
    [Lot_ID]                VARCHAR (15) NULL,
    CONSTRAINT [PK_TEST_INFORMATION] PRIMARY KEY CLUSTERED ([Test_ID] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [Test_information_PK]
    ON [dbo].[Test_information]([Test_ID] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Test_information] TO [Production1]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Test_information] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Test_information] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Test_information] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Test_information] TO [Production1]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Test_information] TO [Production]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Test_information] TO [Production1]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Test_information] TO [Production]
    AS [dbo];

