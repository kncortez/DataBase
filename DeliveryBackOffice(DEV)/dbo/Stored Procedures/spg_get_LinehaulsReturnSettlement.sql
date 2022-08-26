
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-04-27>
-- Description:	<Devuelve información para liquidación de ruta>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_LinehaulsReturnSettlement]
	@IdManifest AS INT,
	@subservice as INT
AS
BEGIN
	SET NOCOUNT ON;	


DECLARE @GuidesDetail TABLE (
	Guide NVARCHAR(25),
	Delivered BIT,
	COD DECIMAL(14,2)
)

DECLARE @GuidesDetailLiquid TABLE (
	StatusCode varchar null,
	Description varchar null,
	NumTransferID varchar null,
	Guide NVARCHAR(25),
	COD DECIMAL(14,2),
	Delivered BIT
	
)

declare @contador int = (SELECT COUNT(DISTINCT  sbpd.GuideNumber ) from SettlementByPickup sbp 
						inner join SettlementByPickupDetail sbpd on sbp.Id = sbpd.SettlementByPickupId
						where sbp.SequenceCode = @IdManifest and sbp.SubTypeServiceManagmentId = @subservice and (sbpd.IsReturn is null or sbpd.IsReturn = 0 ) and  (sbpd.IsPieceLiquidaded is null or sbpd.IsPieceLiquidaded = 0))

select dbs.ID,
	Date_Created as Date_Dispatched,
	PiecesDry as Pieces_Dry_Dispatched,
	PiecesCold as Pieces_Cold_Dispatched,
	GuidesQuantity as Guides_Dispatched,
	dbs.IdCourier,
	sr.First_Name + ' ' + sr.Last_Name as Courier_Name
from SettlementByPickup dbs
join  DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = dbs.IdCourier
WHERE dbs.SequenceCode = @IdManifest and dbs.SubTypeServiceManagmentId = @subservice 


INSERT INTO @GuidesDetail
SELECT DISTINCT
	sbpd.GuideSerie + CONVERT(varchar,sbpd.GuideNumber)+'-'+ CONVERT(varchar,sbpd.NoPiece) AS Guide,
	0 as Delivered,
	0.00 as COD
	from SettlementByPickup sbp 
	inner join SettlementByPickupDetail sbpd on sbp.Id = sbpd.SettlementByPickupId and sbpd.RowStatus = 1
	where sbp.SequenceCode = @IdManifest and sbp.SubTypeServiceManagmentId = @subservice and (sbpd.IsReturn is null or sbpd.IsReturn = 0 ) and  (sbpd.IsPieceLiquidaded is null or sbpd.IsPieceLiquidaded = 0)

INSERT INTO @GuidesDetailLiquid
SELECT DISTINCT
	null AS StatusCode,
	null as Description,
	null as NumTransferID,
	sbpd.GuideSerie + CONVERT(varchar,sbpd.GuideNumber)+'-'+ CONVERT(varchar,sbpd.NoPiece) AS Guide,
	0.00 as COD,
	0 as Delivered
	from SettlementByPickup sbp 
	inner join SettlementByPickupDetail sbpd on sbp.Id = sbpd.SettlementByPickupId and sbpd.RowStatus = 1
	where sbp.SequenceCode = @IdManifest and sbp.SubTypeServiceManagmentId = @subservice and (sbpd.IsReturn  = 1  or sbpd.IsPieceLiquidaded = 1)
	 	 
	 


SELECT isnull(SUM(COD), 0) as COD_Manifest
FROM @GuidesDetail

SELECT * FROM @GuidesDetail gd
ORDER BY gd.Guide ASC

SELECT  * FROM @GuidesDetailLiquid gdl
ORDER BY gdl.Guide ASC

select COUNT(*) as PIECES from @GuidesDetail

select @contador as GUIDES

END