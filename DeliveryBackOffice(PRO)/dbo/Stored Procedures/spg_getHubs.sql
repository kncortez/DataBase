-- =============================================
-- Author:		<Godínez,Carlos>
-- Create date: <2020-12-18,>
-- Description:	<Obtencion de catalogo de sucursales>
-- =============================================
CREATE PROCEDURE [dbo].[spg_getHubs]
AS
BEGIN

select IdHubLogistic Id,HubName Name 
from DeliveryBackOffice.dbo.HubLogistics
UNION
select '-1' Id,
'Todos los establecimientos' Name		
END
