-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-09-16>
-- Description:	<Administración de lotes - Listado de puntos de ventas>
-- =============================================

CREATE PROCEDURE [dbo].[GetPointSales]
@IdLote		INT =  -1,
@IdCountry	NVARCHAR(3) = 'GT'
AS
BEGIN
BEGIN TRY

	SELECT
		VPC.DescriptionOfClient					AS 'Name',
		ISNULL(VPC.CodeOfReference, '')			AS 'CodeOfReference'
	FROM DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
	LEFT JOIN DeliveryBackOffice.dbo.KindOfVPClient	KOVPC WITH(NOLOCK)
		ON VPC.IdKindOfVPClient = KOVPC.IdKindOfVPClient
	WHERE KOVPC.KindOfVPName = 'Express Center' 
		AND VPC.CountryId = @IdCountry
		AND VPC.StatusClient = 1
		AND (@IdLote = -1 
			OR (VPC.CodeOfReference NOT IN (
				SELECT CodeOfReference FROM DeliveryBackOffice.dbo.InvoiceBatchRelationships WITH(NOLOCK)
					WHERE Id_Lote = @IdLote AND RowStatus = 1)))

END TRY
BEGIN CATCH
	-- Manejo de errores con PRINT
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;
