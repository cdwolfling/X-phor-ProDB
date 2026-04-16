CREATE TABLE [dbo].[LotWafer_Die_CP_Parameter] (
    [ID]                       BIGINT       IDENTITY (1, 1) NOT NULL,
    [LotWafer]                 VARCHAR (11) NOT NULL,
    [ChipSN]                   VARCHAR (7)  NULL,
    [dark_current_low]         FLOAT (53)   NULL,
    [dark_current_high]        FLOAT (53)   NULL,
    [uec_onchip_low]           FLOAT (53)   NULL,
    [uec_conchip_high]         FLOAT (53)   NULL,
    [onchip_loss_optical_low]  FLOAT (53)   NULL,
    [onchip_loss_optical_high] FLOAT (53)   NULL,
    [heater_resistance_low]    FLOAT (53)   NULL,
    [heater_resistance_high]   FLOAT (53)   NULL,
    [ppi_low]                  FLOAT (53)   NULL,
    [ppi_high]                 FLOAT (53)   NULL,
    [onchip_loss_mpd_low]      FLOAT (53)   NULL,
    [onchip_loss_mpd_high]     FLOAT (53)   NULL,
    [ER_low]                   FLOAT (53)   NULL,
    [loss_range_high]          FLOAT (53)   NULL,
    [mpd_loss_range_high]      FLOAT (53)   NULL,
    [ompd_range_high]          FLOAT (53)   NULL,
    [mpdm_mpds_dev]            FLOAT (53)   NULL,
    [uec_onchip_std]           FLOAT (53)   NULL,
    [Cdt]                      DATETIME     CONSTRAINT [DF_LotWafer_Die_CP_Parameter_Cdt] DEFAULT (getdate()) NULL,
    [Udt]                      DATETIME     CONSTRAINT [DF_LotWafer_Die_CP_Parameter_Udt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_LotWafer_Die_CP_Parameter] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_LotWafer_Die_CP_Parameter_LotWafer_ChipSN]
    ON [dbo].[LotWafer_Die_CP_Parameter]([LotWafer] ASC, [ChipSN] ASC);

