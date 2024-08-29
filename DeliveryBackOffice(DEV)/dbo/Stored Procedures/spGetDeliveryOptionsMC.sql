-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-06-28>
-- Description:	<Crear Guias - Crear nuevo método en lugar de Catalog/GetDynamicCatalog(GetDeliveryOptions) para cargar opciones de entrega por país.>
-- =============================================

CREATE PROCEDURE [dbo].[spGetDeliveryOptionsMC]
    -- Add the parameters for the stored procedure here
    @pCountryId NVARCHAR(3) = 'GT'
AS
BEGIN

	SELECT
		CONVERT(NVARCHAR, IdDeliveryOption)		AS [Id]
		,ISNULL(Name, 'N/A')					AS [Name]
		,ISNULL(Description, 'N/A')				AS [Description]
	FROM DeliveryBackOffice.dbo.CatDeliveryOptions WITH(NOLOCK)
		WHERE RowStatus = 1 AND IdCountry = @pCountryId

END;