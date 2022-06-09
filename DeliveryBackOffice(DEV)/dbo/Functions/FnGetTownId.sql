
--Devuelve el ID de un HUB dando como entrada el ID del Township(Municipio)
CREATE FUNCTION [dbo].[FnGetTownId](
    @Town VARCHAR(MAX), @Dep VARCHAR(MAX)
)
RETURNS INT
AS
BEGIN
    
    DECLARE @Hub INT =
	(SELECT IdTownship FROM [DeliveryBackOffice].[dbo].[Township]
								WHERE TownshipName = DeliveryBackOffice.dbo.FnClearString(@Town)
								AND IdProvince = (SELECT IdProvince FROM [DeliveryBackOffice].[dbo].[Province] 
												  WHERE ProvinceName = DeliveryBackOffice.dbo.FnClearString(@Dep)));

    
    RETURN @Hub
 
END
