
-- =============================================
-- Author:		<César, Aquino>
-- Create date: <2021-04-19>
-- Description:	<Devuelve los tipos de tarifas que existen>
-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <2024-06-04>
-- Description:	<Se agrega parametro para filtrar por pais>
-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Create date: <2024-06-04>
-- Description:	<Se elimina filtro>
-- =============================================
 CREATE PROCEDURE [dbo].[sphd_get_TypeRate]
 @IdCountry AS NVARCHAR(2)= 'GT'
AS
BEGIN
	select IdTypeRate AS Id, Name as Name
	from dbo.CatTypeRate
	where RowStatus = 'true'
	--AND IIF(IdCountry IS NULL, 'GT',IdCountry) = @IdCountry
END