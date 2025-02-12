-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2024-10-23>
-- Description:	<Devuelve listado de guias despachadas por manifiesto para reimprimir los documentos asociados en el modulo de nuevo despacho>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_GetSettlementGuidesToReprint] 
	@ManifestId AS INT,
	@CountryId AS VARCHAR(2)='GT'
AS
BEGIN	
	SET NOCOUNT ON;

	BEGIN TRY

		--TABLA 0, Guías de clientes Iggs, Renap
		SELECT do.Guide_Serie, do.Guide_Number AS GuidesEsp
		FROM [dbo].[DeliverySettlementDetail] dsd WITH (NOLOCK)  
			INNER JOIN [dbo].[DeliveryOrder] do WITH (NOLOCK)
				ON dsd.Guide_Serie = do.Guide_Serie AND dsd.Guide_Number = do.Guide_Number 
			LEFT JOIN VisitPointClient vpc WITH(NOLOCK)
				ON vpc.CodeOfReference = do.Sender_ID
			LEFT JOIN Customer cu WITH(NOLOCK)
				ON cu.IdCustomer = COALESCE(do.IdCustomer, vpc.CustomerID)
		WHERE cu.IsVoucherRequired = 1
			AND cu.Abbreviation IN ('IGSS','RENAP')
			AND vpc.CountryId = @CountryId
			AND dsd.ID_DeliveryOrderBySettlement = @ManifestId

		--TABLA 1, Guías para todos los clientes 
		SELECT do.Guide_Serie, do.Guide_Number AS Guides
		FROM [dbo].[DeliverySettlementDetail] dsd WITH (NOLOCK)  
			INNER JOIN [dbo].[DeliveryOrder] do WITH (NOLOCK)
				ON dsd.Guide_Serie = do.Guide_Serie AND dsd.Guide_Number = do.Guide_Number
			LEFT JOIN VisitPointClient vpc WITH(NOLOCK)
				ON vpc.CodeOfReference = do.Sender_ID
			LEFT JOIN Customer cu WITH(NOLOCK)
				ON cu.IdCustomer = COALESCE(do.IdCustomer, vpc.CustomerID)
		WHERE cu.IsVoucherRequired = 1
			AND cu.Abbreviation NOT IN ('IGSS','RENAP')
			AND vpc.CountryId = @CountryId
			AND dsd.ID_DeliveryOrderBySettlement = @ManifestId

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END;