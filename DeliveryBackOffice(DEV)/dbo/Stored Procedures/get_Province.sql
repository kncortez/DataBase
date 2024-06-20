-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-19>
-- Description:	<Retorna los tipos de una ruta>
-- =============================================
CREATE PROCEDURE [dbo].[get_Province]
(
 @IdCountry AS NVARCHAR(2) = 'GT'
)
AS
BEGIN

	select IdProvince, ProvinceName from Province
	where ProvinceStatus = 1
    AND IIF(IdCountry IS NULL, 'GT', IdCountry) = @IdCountry



END
