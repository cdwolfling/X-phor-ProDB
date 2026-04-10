CREATE TABLE [dbo].[Tray_Track_Log] (
    [Id]              BIGINT       IDENTITY (1, 1) NOT NULL,
    [LotWaferTrayKey] VARCHAR (30) NOT NULL,
    [ProcessStepName] VARCHAR (20) NOT NULL,
    [LotWafer]        VARCHAR (11) NULL,
    [Station]         VARCHAR (20) NULL,
    [Operator]        VARCHAR (10) NULL,
    [TrackIn]         DATETIME     NOT NULL,
    [TrackOut]        DATETIME     NULL,
    [Cdt]             DATETIME     CONSTRAINT [DF_Tray_Track_Log_Cdt] DEFAULT (getdate()) NULL,
    [Udt]             DATETIME     CONSTRAINT [DF_Tray_Track_Log_Udt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK__Tray_Track_Log] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Tray_Track_Log_LotWafer]
    ON [dbo].[Tray_Track_Log]([LotWafer] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Tray_Track_Log_LotWaferTrayKey_ProcessStepName]
    ON [dbo].[Tray_Track_Log]([LotWaferTrayKey] ASC, [ProcessStepName] ASC);

