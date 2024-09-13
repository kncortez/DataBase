
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-04-27>
-- Description:	<Devuelve información para liquidación de ruta>
-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Create date: <2024-06-05>
-- Description:	<Se agrega parametro para filtrar por pais de origen de guia asociada>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_LinehaulsReturnSettlement]
	@IdManifest AS INT,
	@subservice as INT,
	@IdCountry AS NVARCHAR(2) = 'GT'
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

declare @contador int = (SELECT COUNT(DISTINCT  sbpd.GuideNumber ) from SettlementByPickup sbp WITH(NOLOCK)
						inner join SettlementByPickupDetail sbpd WITH(NOLOCK) on sbp.Id = sbpd.SettlementByPickupId						
						inner join DeliveryOrder dro WITH(NOLOCK) on sbpd.GuideNumber = dro.Guide_Number and sbpd.GuideSerie = dro.Guide_Serie
						where sbp.SequenceCode = @IdManifest and sbp.SubTypeServiceManagmentId = @subservice and (sbpd.IsReturn is null or sbpd.IsReturn = 0 ) and  (sbpd.IsPieceLiquidaded is null or sbpd.IsPieceLiquidaded = 0)
						and iif(dro.SenderCountryId is null, 'GT', dro.SenderCountryId)=@IdCountry)

select dbs.ID,
	Date_Created as Date_Dispatched,
	PiecesDry as Pieces_Dry_Dispatched,
	PiecesCold as Pieces_Cold_Dispatched,
	GuidesQuantity as Guides_Dispatched,
	dbs.IdCourier,
	sr.First_Name + ' ' + sr.Last_Name as Courier_Name
from SettlementByPickup dbs WITH(NOLOCK)
inner join SettlementByPickupDetail sbpd WITH(NOLOCK) on dbs.Id = sbpd.SettlementByPickupId
inner join DeliveryOrder dro WITH(NOLOCK) on sbpd.GuideNumber = dro.Guide_Number and sbpd.GuideSerie = dro.Guide_Serie
INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr WITH(NOLOCK) ON sr.ID = dbs.IdCourier
WHERE dbs.SequenceCode = @IdManifest and dbs.SubTypeServiceManagmentId = @subservice 
and iif(dro.SenderCountryId is null, 'GT', dro.SenderCountryId)=@IdCountry

INSERT INTO @GuidesDetail
SELECT DISTINCT
	sbpd.GuideSerie + CONVERT(varchar,sbpd.GuideNumber)+'-'+ CONVERT(varchar,sbpd.NoPiece) AS Guide,
	0 as Delivered,
	0.00 as COD
	from SettlementByPickup sbp WITH(NOLOCK)
	inner join SettlementByPickupDetail sbpd WITH(NOLOCK) on sbp.Id = sbpd.SettlementByPickupId and sbpd.RowStatus = 1	
	inner join DeliveryOrder dro WITH(NOLOCK) on sbpd.GuideNumber = dro.Guide_Number and sbpd.GuideSerie = dro.Guide_Serie
	where sbp.SequenceCode = @IdManifest and sbp.SubTypeServiceManagmentId = @subservice and (sbpd.IsReturn is null or sbpd.IsReturn = 0 ) and  (sbpd.IsPieceLiquidaded is null or sbpd.IsPieceLiquidaded = 0)
	and iif(dro.SenderCountryId is null, 'GT', dro.SenderCountryId)=@IdCountry

INSERT INTO @GuidesDetailLiquid
SELECT DISTINCT
	null AS StatusCode,
	null as Description,
	null as NumTransferID,
	sbpd.GuideSerie + CONVERT(varchar,sbpd.GuideNumber)+'-'+ CONVERT(varchar,sbpd.NoPiece) AS Guide,
	0.00 as COD,
	0 as Delivered
	from SettlementByPickup sbp WITH(NOLOCK)
	inner join SettlementByPickupDetail sbpd WITH(NOLOCK) on sbp.Id = sbpd.SettlementByPickupId and sbpd.RowStatus = 1
	inner join DeliveryOrder dro WITH(NOLOCK) on sbpd.GuideNumber = dro.Guide_Number and sbpd.GuideSerie = dro.Guide_Serie
	where sbp.SequenceCode = @IdManifest and sbp.SubTypeServiceManagmentId = @subservice and (sbpd.IsReturn  = 1  or sbpd.IsPieceLiquidaded = 1)
	and iif(dro.SenderCountryId is null, 'GT', dro.SenderCountryId)=@IdCountry 	 
	 


SELECT isnull(SUM(COD), 0) as COD_Manifest
FROM @GuidesDetail

SELECT * FROM @GuidesDetail gd
ORDER BY gd.Guide ASC

SELECT  * FROM @GuidesDetailLiquid gdl
ORDER BY gdl.Guide ASC

select COUNT(*) as PIECES from @GuidesDetail

select @contador as GUIDES

END