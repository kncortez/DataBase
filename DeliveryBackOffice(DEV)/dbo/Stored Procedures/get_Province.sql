-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-19>
-- Description:	<Retorna los tipos de una ruta>
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-06-03>
-- Description: <Se agrega filtro por pais, por defecto GT>
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
