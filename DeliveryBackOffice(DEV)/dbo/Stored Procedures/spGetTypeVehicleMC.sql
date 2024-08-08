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
    WHERE RowStatus = 1 AND (IdCountry = @pCountryId OR (@pCountryId = 'GT' AND IdCountry IS NULL))
		AND Name IN ('Camión','Panel','Motocicleta')

END;