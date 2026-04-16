CREATE TABLE [dbo].[LotWafer_UEC_Mean_Std_History] (
    [History_ID]         BIGINT       IDENTITY (1, 1) NOT NULL,
    [LotWafer]           VARCHAR (11) NOT NULL,
    [CPFileTime]         DATETIME     NULL,
    [Mean]               FLOAT (53)   NULL,
    [Std]                FLOAT (53)   NULL,
    [Cdt]                DATETIME     NULL,
    [Udt]                DATETIME     NULL,
    [FinishDieParameter] BIT          NULL,
    [UpdateUser]         [sysname]    CONSTRAINT [DF_LotWafer_UEC_Mean_Std_UpdateUser] DEFAULT (original_login()) NOT NULL,
    [UpdateDate]         DATETIME     CONSTRAINT [DF_LotWafer_UEC_Mean_Std_UpdateDate] DEFAULT (getdate()) NOT NULL,
    [UpdateHost]         VARCHAR (64) CONSTRAINT [DF_LotWafer_UEC_Mean_Std_UpdateHost] DEFAULT (host_name()) NOT NULL,
    CONSTRAINT [PK_LotWafer_UEC_Mean_Std_History] PRIMARY KEY CLUSTERED ([History_ID] ASC)
);

