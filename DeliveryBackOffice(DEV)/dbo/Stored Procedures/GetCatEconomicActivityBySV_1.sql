-- =============================================
-- Author:      <Cristian, Azurdia>
-- Create date: <2024-06-15>
-- Description: <Desplegar listado de Actividades Economicas, por Defecto el Salvador>
-- =============================================
CREATE PROCEDURE [dbo].[GetCatEconomicActivityBySV]
(
 @IdCountry VARCHAR(4)= 'SV'
)
AS
BEGIN

        SELECT [Id],[CodeActivity], [Description] 
          FROM DeliveryBackOffice.[dbo].[CatEconomicActivityBySV] WITH(NOLOCK)
         WHERE RowStatus = 1

END