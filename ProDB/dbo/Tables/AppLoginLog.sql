CREATE TABLE [dbo].[AppLoginLog] (
    [LogID]       BIGINT         IDENTITY (1, 1) NOT NULL,
    [ClientIP]    VARCHAR (45)   NOT NULL,
    [AppID]       INT            NULL,
    [LoginTime]   DATETIME2 (7)  DEFAULT (sysutcdatetime()) NOT NULL,
    [UserName]    NVARCHAR (128) NULL,
    [WorkStation] NVARCHAR (128) NULL,
    CONSTRAINT [PK_AppLoginLog] PRIMARY KEY CLUSTERED ([LogID] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_AppLoginLog_LoginTime]
    ON [dbo].[AppLoginLog]([LoginTime] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_AppLoginLog_AppVer]
    ON [dbo].[AppLoginLog]([AppID] ASC);


GO
GRANT SELECT
    ON OBJECT::[dbo].[AppLoginLog] TO [Production]
    AS [dbo];

