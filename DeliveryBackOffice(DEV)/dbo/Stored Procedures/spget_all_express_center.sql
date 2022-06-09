
CREATE PROCEDURE [dbo].[spget_all_express_center]
AS
BEGIN

DECLARE @StatusClient INT = 1;
DECLARE @CountryId VARCHAR(2) = 'GT';
DECLARE @IdKindOfVPClient INT = 1;

SELECT CodeOfReference, 
	   DescriptionOfClient
FROM DeliveryBackOffice.dbo.VisitPointClient
WHERE StatusClient = @StatusClient
AND CountryId = @CountryId
AND IdKindOfVPClient = @IdKindOfVPClient;

END

