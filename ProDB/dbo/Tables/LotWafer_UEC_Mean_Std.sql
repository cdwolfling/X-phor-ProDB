CREATE TABLE [dbo].[LotWafer_UEC_Mean_Std] (
    [LotWafer]   VARCHAR (11) NOT NULL,
    [CPFileTime] DATETIME     NULL,
    [Mean]       FLOAT (53)   NULL,
    [Std]        FLOAT (53)   NULL,
    [Cdt]        DATETIME     CONSTRAINT [DF_LotWafer_UEC_Mean_Std_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_LotWafer_UEC_Mean_Std] PRIMARY KEY CLUSTERED ([LotWafer] ASC)
);

