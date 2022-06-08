USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <07-06-2022>
-- Description:	<Para saber si generar un comprobante de entrega especial o normal - GetReportApp>
-- =============================================
CREATE PROCEDURE [dbo].[GetTypeVoucherDelivery]
	-- Add the parameters for the stored procedure here
	@Serie NVARCHAR(2)
	,@Number INT
	,@Type TINYINT--1 por manifiesto, 2 por orden.
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Abbreviation NVARCHAR(25)

	SET @Abbreviation = (SELECT TOP 1
			cu.Abbreviation
		FROM DeliveryOrder do WITH (NOLOCK)
		LEFT JOIN VisitPointClient vpc
			ON vpc.CodeOfReference = do.Sender_ID
		LEFT JOIN Customer cu
			ON cu.IdCustomer = COALESCE(do.IdCustomer, vpc.CustomerID)
		WHERE (@Type = 2
		AND do.Guide_Serie = @Serie
		AND do.Guide_Number = @Number)
		OR (@Type = 1
		AND do.Manifest_Serie = @Serie
		AND do.Manifest_Number = @Number))


	SELECT
		CASE
			WHEN @Abbreviation IS NULL THEN -1 --Si no se encuentra registro
			WHEN @Abbreviation IN ('IGSS', 'RENAP') THEN 1 --Si se genera el reporte ComprobanteEntregaEsp
			ELSE 0 --Se genera ComprobanteEntrega
		END Esp

END
GO
