

CREATE TRIGGER [Trig_Log_DDL_DATABASE_LEVEL_EVENTS]
	ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS
AS
/*
-- =============================================
Author:					Andreas Wolter, Microsoft
Create date:			11-2020
Revision History:	

Description:			Database-scope DDL-Trigger to log all Schema-changes

Permissions:			DDL Triggers are executed under the context of the caller - or can be executed under a specific user name using the EXECUTE AS-clause
							Unless a specific User account is used, it needs to be made sure that every potential user who can run DDL statements has also INSERT-Permission to the DDL_Log-Table. It may be fine to use public.

Change log:
01/12/2024 JC: Add "SET ANSI_PADDING ON;" to fix below error while processing replication
	the error message is: "SELECT failed because the following SET options have incorrect settings: 'ANSI_PADDING'. Verify that SET options are correct for use with indexed views and/or .."
-- =============================================
*/
SET NOCOUNT ON;
SET ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_PADDING ON;
-- XML data operations, such as @data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)'), require both to be ON.

DECLARE
			@EventData			xml
		,	@EventType			nvarchar(50)
		,	@TSQLCommand	nvarchar(max)
		,	@PostTime			datetime2(2)
		,	@SPID					int
		,	@ServerName		nvarchar(128)
		,	@LoginName			nvarchar(128)
		,	@Original_Login		nvarchar(128)
		,	@UserName			nvarchar(128)
		,	@Application			nvarchar( 250 )
		,	@DatabaseName	nvarchar(128)
		,	@SchemaName		nvarchar(128)
		,	@ObjectName		nvarchar(128)
		,	@ObjectType			nvarchar(100)

SET @EventData		= EVENTDATA()
SET @EventType		= @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(50)' )
SET @TSQLCommand	= @EventData.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'nvarchar(max)' )
--CONVERT(NVARCHAR(max), @EventData.query('data(//TSQLCommand//CommandText)'))
SET @PostTime			= @EventData.value('(/EVENT_INSTANCE/PostTime)[1]', 'datetime2(2)' )
SET @SPID				= @EventData.value('(/EVENT_INSTANCE/SPID)[1]', 'int' )
SET @ServerName		= HOST_NAME()
SET @LoginName		= SYSTEM_USER
SET @Original_Login	= ORIGINAL_LOGIN()
SET @UserName		= USER_NAME()
SET @Application		= COALESCE(APP_NAME(), '** NA **' )
SET @DatabaseName	= DB_NAME()
SET @SchemaName	= CASE WHEN (COALESCE(@EventData.value('(/EVENT_INSTANCE/SchemaName)[1]', 'sysname' ), '** no schema **') = '') THEN '** no schema **' ELSE COALESCE(@EventData.value('(/EVENT_INSTANCE/SchemaName)[1]', 'sysname' ), '** no schema **') END	   -- some events like "GRANT" on a Database return empty string for schema instead of NULL
SET @ObjectName		= @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname' )
SET @ObjectType		= @EventData.value('(/EVENT_INSTANCE/ObjectType)[1]', 'sysname' )

-- disallowing the removal of the DDL-Log Table
-- Disable or Drop the trigger beforehand
IF		@EventType	= 'DROP_TABLE'
  AND	@ObjectName	= 'DDL_Log'
  AND	@SchemaName	= 'Administration'
	BEGIN
		ROLLBACK
	END

-- Filter out operations that do not need to be looged such as Index Maintenance
IF (@EventType NOT IN (
				'UPDATE_STATISTICS'
			--,	'ALTER_INDEX'	-- We do want to include Disabling of indexes
		)
	AND NOT (@EventType = 'ALTER_INDEX' AND @TSQLCommand NOT LIKE '%DISABLE%')
	)
BEGIN

	INSERT INTO Administration.DDL_Log
			   (EventType
			   ,SPID
			   ,ServerName
			   ,LoginName
			   ,OriginalLogin
			   ,UserName
			   ,Application
			   ,DatabaseName
			   ,SchemaName
			   ,ObjectName
			   ,ObjectType
			   ,TSQLCommand
			   , EventData)
		 VALUES
			   (@EventType
			   ,@SPID
			   ,@ServerName
			   ,@LoginName
			   ,@Original_Login
			   ,@UserName
			   ,@Application
			   ,@DatabaseName
			   ,@SchemaName
			   ,@ObjectName
			   ,@ObjectType
			   ,@TSQLCommand
			   ,@EventData)


END;

