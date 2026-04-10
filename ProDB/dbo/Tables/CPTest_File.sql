CREATE TABLE [dbo].[CPTest_File] (
    [FileId]              BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProductModel]        VARCHAR (20)  NULL,
    [LotWafer]            VARCHAR (11)  NOT NULL,
    [FileModifiedTime]    DATETIME      NOT NULL,
    [FilePath]            VARCHAR (400) NOT NULL,
    [Station]             VARCHAR (20)  NULL,
    [CPTest_TrackOutTime] DATETIME      NULL,
    [isRecent]            BIT           CONSTRAINT [DF_CPTest_File_isRecent] DEFAULT ((1)) NULL,
    [Cdt]                 DATETIME      CONSTRAINT [DF_CPTest_File_Cdt] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_CPTest_File] PRIMARY KEY CLUSTERED ([FileId] ASC),
    CONSTRAINT [UQ_CPTest_File] UNIQUE NONCLUSTERED ([LotWafer] ASC, [FileModifiedTime] ASC)
);










GO
CREATE NONCLUSTERED INDEX [IX_CPTest_File_LotWafer]
    ON [dbo].[CPTest_File]([LotWafer] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CPTest_File_FileModifiedTime]
    ON [dbo].[CPTest_File]([FileModifiedTime] ASC);

