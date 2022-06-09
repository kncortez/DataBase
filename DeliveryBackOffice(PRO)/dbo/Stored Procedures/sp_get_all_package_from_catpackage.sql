
CREATE PROCEDURE [dbo].[sp_get_all_package_from_catpackage]
AS
BEGIN

DECLARE @FlagEnabledPackage INT = 1;

SELECT PckId, PckName
FROM dbo.CatPackage
WHERE PckRowStatus = @FlagEnabledPackage;

END

