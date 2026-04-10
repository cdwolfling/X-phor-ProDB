CREATE TABLE [dbo].[CPTest_Chip] (
    [ChipTestId]   BIGINT       IDENTITY (1, 1) NOT NULL,
    [FileId]       BIGINT       NOT NULL,
    [TestTime]     DATETIME     NULL,
    [Die_Location] VARCHAR (3)  NOT NULL,
    [Dev_name]     VARCHAR (10) NULL,
    [Dev_number]   VARCHAR (10) NULL,
    [Dev_ID]       VARCHAR (3)  NOT NULL,
    [ChipSN]       VARCHAR (7)  NOT NULL,
    CONSTRAINT [PK_CPTest_Chip] PRIMARY KEY CLUSTERED ([ChipTestId] ASC),
    CONSTRAINT [FK_CPTest_Chip_File] FOREIGN KEY ([FileId]) REFERENCES [dbo].[CPTest_File] ([FileId])
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CPTest_Chip_Key]
    ON [dbo].[CPTest_Chip]([FileId] ASC, [ChipSN] ASC);

