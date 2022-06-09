-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-19>
-- Description:	<Retorna los tipos de una ruta>
-- =============================================
CREATE PROCEDURE [dbo].[get_Province]
AS
BEGIN

	select IdProvince, ProvinceName from Province
	where ProvinceStatus = 1




END
