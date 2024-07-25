-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-07-24>
-- Description:	<Backend - Crear metodo nuevo para sustituir a Catalog/GetDynamicCatalog en el metodo GetTypeVehicle para multipais.>
-- =============================================

CREATE PROCEDURE [dbo].[spGetTypeVehicleMC]
    -- Add the parameters for the stored procedure here
    @pCountryId NVARCHAR(3) = 'GT'
AS
BEGIN

	SELECT
		CONVERT(NVARCHAR, IdTypeVehicle)		AS [Id]
        ,ISNULL(Name, '') + '",'				AS [Name]
		,ISNULL(Description, '')				AS [Description]
    FROM CatTypeVehicle
    WHERE RowStatus = 1 AND IdCountry = @pCountryId
		AND Name IN ('Camión','Panel','Motocicleta')

END;