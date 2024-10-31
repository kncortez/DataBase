-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-09-19>
-- Description: <Se obtiene la información de las guias no entregadas en el proceso de liquidación con incidencias>
-- =============================================
CREATE PROCEDURE [dbo].[GetManifestWithIncidenceDetails]
    @ListOfGuidesAsCSV NVARCHAR(MAX),
	@IdCountry NVARCHAR(2) = 'GT'

AS
BEGIN	
	SET NOCOUNT ON;

	-- Tabla para manejar las guías 
	DECLARE @ListOfGuides TABLE (GuideSerie NVARCHAR(2), GuideNumber INT)
	
	BEGIN TRY

		-- Convertir la lista de guías separadas por coma en una tabla
		INSERT INTO @ListOfGuides
		SELECT SUBSTRING(Item, 1,2) ItemSerie,SUBSTRING(Item,3,len(Item)) ItemNumber 
		FROM DeliveryBackOffice.dbo.SplitUnlimited(@ListOfGuidesAsCSV,',')
		
		-- TABLA 0 obtenemos el Monto total y el numero de piezas 
		SELECT SUM(ISNULL(do.Pieces_Dry,0) + ISNULL(do.Pieces_Cold,0)) AS Pieces
				, SUM(do.PriceShippment + IIF(do.Collect_OnDelivery > IIF(do.IsInsuarance = 1, do.InsuranceAmount,0), do.Collect_OnDelivery,do.InsuranceAmount)) AS Amount
		FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
		INNER JOIN @ListOfGuides t 
			ON do.Guide_Serie = t.GuideSerie 
			AND do.Guide_Number = t.GuideNumber
		WHERE ISNULL(do.SenderCountryId, 'GT') = @IdCountry

		-- TABLA 1 Obtenemos los tipos de incidencias para el proceso de liquidación de rutas de ultima milla
		SELECT  IdIncidenceType AS IncidenceId
			, NameIncidence AS IncidenceName
		FROM DeliveryBackOffice.dbo.CatTypeIncidence  WITH(NOLOCK)
		WHERE ServiceType = 'LAST MILE SETTLEMENT'
			AND ISNULL(CountryId, 'GT') = @IdCountry

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END;
