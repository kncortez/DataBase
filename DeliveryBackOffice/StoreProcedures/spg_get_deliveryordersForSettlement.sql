USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_get_deliveryordersForSettlement]    Script Date: 17/11/2020 18:15:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Bidcar, Herrera>
-- Create date: <2020-05-27>
-- Description:	<Devuelve información para liquidación de ruta>
-- =============================================
ALTER PROCEDURE [dbo].[spg_get_deliveryordersForSettlement]
	@IdManifest AS INT
AS
BEGIN
	SET NOCOUNT ON;	
	
DECLARE @GuidesFound TABLE (
	Guide_Serie NVARCHAR(2),
	Guide_Number INT
)

DECLARE @GuidesDetail TABLE (
	Guide NVARCHAR(16),
	Delivered BIT,
	COD DECIMAL(14,2)
)

INSERT INTO @GuidesFound
SELECT DISTINCT
	dsd.Guide_Serie,
	dsd.Guide_Number
FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement dbs
JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail dsd ON dsd.ID_DeliveryOrderBySettlement = dbs.ID
WHERE dbs.ID = @IdManifest 
AND (dsd.Guide_Settlement = 0 OR dsd.Guide_Settlement IS NULL)

SELECT --*
	dbs.ID,
	Date_Dispatched,
	Pieces_Dry_Dispatched,
	Pieces_Cold_Dispatched,
	Guides_Dispatched,
	dbs.ID_Courier,
	sr.First_Name + ' ' + sr.Last_Name as Courier_Name
FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement dbs
JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = dbs.ID_Courier
WHERE dbs.ID = @IdManifest

INSERT INTO @GuidesDetail
SELECT DISTINCT
	da.Guide_Serie + CONVERT(varchar,da.Guide_Number) AS Guide,
	da.Delivered,
	ISNULL(do.Collect_OnDelivery,0) as Collect_OnDelivery
FROM @GuidesFound gf
JOIN DeliveryBackOffice.dbo.DeliveryAttempt da ON gf.Guide_Serie = da.Guide_Serie AND gf.Guide_Number = da.Guide_Number
JOIN DeliveryBackOffice.dbo.DeliveryOrder do ON do.Guide_Serie = da.Guide_Serie AND do.Guide_Number = da.Guide_Number

SELECT SUM(COD) as COD_Manifest
FROM @GuidesDetail

SELECT * FROM @GuidesDetail gd
ORDER BY gd.Guide ASC

END
GO


