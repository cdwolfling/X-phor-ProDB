CREATE TABLE [Administration].[DDL_Log] (
    [DDL_Log_ID]    INT            IDENTITY (1, 1) NOT NULL,
    [EventType]     NVARCHAR (50)  NOT NULL,
    [PostTime]      DATETIME2 (2)  CONSTRAINT [DF_DDL_Log_PostTime] DEFAULT (sysdatetime()) NULL,
    [SPID]          INT            NOT NULL,
    [ServerName]    NVARCHAR (100) NOT NULL,
    [LoginName]     NVARCHAR (100) NOT NULL,
    [OriginalLogin] NVARCHAR (100) NOT NULL,
    [UserName]      NVARCHAR (100) NOT NULL,
    [Application]   NVARCHAR (250) NOT NULL,
    [DatabaseName]  NVARCHAR (100) NOT NULL,
    [SchemaName]    NVARCHAR (100) NOT NULL,
    [ObjectName]    NVARCHAR (100) NOT NULL,
    [ObjectType]    NVARCHAR (100) NOT NULL,
    [TSQLCommand]   NVARCHAR (MAX) NOT NULL,
    [EventData]     XML            NOT NULL,
    CONSTRAINT [PKCL_Administration_DDL_Log_DDL_Log_ID] PRIMARY KEY CLUSTERED ([DDL_Log_ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Stores all relevant DDL Statements against the current database, inserted by DDL Trigger.', @level0type = N'SCHEMA', @level0name = N'Administration', @level1type = N'TABLE', @level1name = N'DDL_Log';


GO
EXECUTE sp_addextendedproperty @name = N'Referenced by', @value = N'PROC: del_DDL_Log_by_oldest_date, TRIGGER: Trig_Log_DDL_DATABASE_LEVEL_EVENTS', @level0type = N'SCHEMA', @level0name = N'Administration', @level1type = N'TABLE', @level1name = N'DDL_Log';

