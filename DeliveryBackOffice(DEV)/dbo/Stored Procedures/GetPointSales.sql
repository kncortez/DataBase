
/* =========================================
   SP:        [DeliveryBackOffice].[dbo].[GetPointSales]
   Propósito: Obtener listado de puntos de venta para asignación de lotes
   Autor:     Walter Orozco
   Historia:  FDAPI-3048
   Fecha:     2024-09-05
==== CHANGELOG ============================
2025-12-05 | Historia/épica: FDAPI-5271 | Autor: Cristian Azurdia |
2024-09-05 | Historia/épica: FDAPI-3048 | Autor: Walter Orozco |
=========================================== */

CREATE PROCEDURE [dbo].[GetPointSales]
@IdLote		INT =  -1,
@IdCountry	NVARCHAR(3) = 'GT'
AS
BEGIN
BEGIN TRY

	DECLARE @TypeDocument INT;

	SELECT @TypeDocument = TypeDocument 
	FROM DeliveryBackOffice.dbo.InvoiceBatchHeader WITH(NOLOCK)
	WHERE Id_Lote = @IdLote;

	SELECT
		VPC.DescriptionOfClient                 AS 'Name',
		ISNULL(VPC.CodeOfReference, '0')         AS 'CodeOfReference',
		ISNULL(IBR.RowStatus,0)   [RowStatus],
		ISNULL(IBR.Emision_Point,'0') [Emision_Point],
		ISNULL(IBR.Establishment,'0') [Establishment],
		ISNULL(IBR.CAI,'0')           [CAI],
		ISNULL(IBR.TypeDocument,0)    [TypeDocument]
	FROM DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
	LEFT JOIN DeliveryBackOffice.dbo.KindOfVPClient KOVPC WITH(NOLOCK)
		ON VPC.IdKindOfVPClient = KOVPC.IdKindOfVPClient
	OUTER APPLY (
		SELECT IBR.RowStatus      [RowStatus]
			,IBH.Emision_Point  [Emision_Point]
			,IBH.Establishment  [Establishment]
			,IBH.CAI            [CAI]
			,IBH.TypeDocument   [TypeDocument]
		FROM DeliveryBackOffice.dbo.InvoiceBatchHeader IBH   WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.InvoiceBatchRelationships IBR WITH(NOLOCK)
			ON IBR.Id_Lote = IBH.Id_Lote
		WHERE IBR.RowStatus = 1
		AND IBH.TypeDocument = @TypeDocument
		AND VPC.CodeOfReference = IBR.CodeOfReference
			AND IBH.Id_Lote != @IdLote
				) IBR
	WHERE KOVPC.KindOfVPName = 'Express Center'
		AND VPC.CountryId = @IdCountry
		AND VPC.StatusClient = 1

END TRY
BEGIN CATCH
	-- Manejo de errores con PRINT
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;