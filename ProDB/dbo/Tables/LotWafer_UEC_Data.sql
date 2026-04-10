CREATE TABLE [dbo].[LotWafer_UEC_Data] (
    [LotWafer]  VARCHAR (11) NOT NULL,
    [uec_upper] FLOAT (53)   NULL,
    [uec_lower] FLOAT (53)   NULL,
    [Cdt]       DATETIME     CONSTRAINT [DF_LotWafer_UEC_Data_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_LotWafer_UEC_Data] PRIMARY KEY CLUSTERED ([LotWafer] ASC)
);

