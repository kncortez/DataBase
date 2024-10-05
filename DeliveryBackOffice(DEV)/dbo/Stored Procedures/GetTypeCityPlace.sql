
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2024-10-24>
-- Description:	<Description,obtener tipo de dirección>
-- =============================================
CREATE PROCEDURE [dbo].[GetTypeCityPlace]
@IdCountry NVARCHAR(2)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT 
	     [IdCityPlace],	
         [CityPlace]
	      FROM [DeliveryBackOffice].[dbo].[CatCityPlace] CCP WITH(NOLOCK)
	WHERE CityPlaceRowStatus =1 AND IdCountry = @IdCountry
		   
END
GO
