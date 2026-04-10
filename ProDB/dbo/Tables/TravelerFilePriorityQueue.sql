CREATE TABLE [dbo].[TravelerFilePriorityQueue] (
    [Id]              BIGINT        IDENTITY (1, 1) NOT NULL,
    [LotWafer]        VARCHAR (11)  NOT NULL,
    [ProcessedCount]  INT           CONSTRAINT [DF_TravelerFilePriorityQueue_ProcessedCount] DEFAULT ((0)) NOT NULL,
    [SourceName]      VARCHAR (200) NOT NULL,
    [SourceDir]       VARCHAR (200) NULL,
    [Reason]          VARCHAR (500) NULL,
    [RequestedBy]     VARCHAR (100) NULL,
    [Cdt]             DATETIME      CONSTRAINT [DF_TravelerFilePriorityQueue_Cdt] DEFAULT (getdate()) NOT NULL,
    [LastProcessedAt] DATETIME      NULL,
    CONSTRAINT [PK_TravelerFilePriorityQueue] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_TravelerFilePriorityQueue_LotWafer] UNIQUE NONCLUSTERED ([LotWafer] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_TravelerFilePriorityQueue_ProcessedCount]
    ON [dbo].[TravelerFilePriorityQueue]([ProcessedCount] ASC);

