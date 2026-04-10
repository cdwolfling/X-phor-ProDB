CREATE TABLE [dbo].[TrayMapCell] (
    [TrayMapId] BIGINT       NOT NULL,
    [RowNo]     TINYINT      NOT NULL,
    [ColNo]     TINYINT      NOT NULL,
    [SeqAtTray] INT          NULL,
    [ChipSN]    VARCHAR (50) NULL,
    [Udt]       DATETIME     CONSTRAINT [DF_TrayMapCell_Cdt] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_TrayMapCell] PRIMARY KEY CLUSTERED ([TrayMapId] ASC, [RowNo] ASC, [ColNo] ASC),
    CONSTRAINT [FK_TrayMapCell_TrayMapHeader_TrayMapId] FOREIGN KEY ([TrayMapId]) REFERENCES [dbo].[TrayMapHeader] ([TrayMapId]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_TrayMapCell_ChipSN]
    ON [dbo].[TrayMapCell]([TrayMapId] ASC, [ChipSN] ASC);

