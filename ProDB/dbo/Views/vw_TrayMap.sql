




/*
2026-03-27 JC: 用于显示Tray信息

Change Log:
*/
CREATE VIEW [dbo].[vw_TrayMap] AS
select h.TrayMapId,h.LotWaferTrayKey,h.ProductModel,h.LotNo,h.Wafer,h.LotWafer, h.TrayNo, h.OQCTrackOutTime, h.Cdt as TrayCdt, h.Udt as TrayUdt
	, c.RowNo, c.ColNo, c.SeqAtTray, c.ChipSN, c.Udt as ChipUdt
	from dbo.TrayMapHeader h
	join dbo.TrayMapCell c on h.TrayMapId=c.TrayMapId