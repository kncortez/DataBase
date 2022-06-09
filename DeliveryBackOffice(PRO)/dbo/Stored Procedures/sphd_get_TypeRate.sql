
-- =============================================
-- Author:		<César, Aquino>
-- Create date: <2021-04-19>
-- Description:	<Devuelve los tipos de tarifas que existen>
-- =============================================
 create PROCEDURE [dbo].[sphd_get_TypeRate]

AS
BEGIN
	select IdTypeRate AS Id, Name as Name
	from dbo.CatTypeRate
	where RowStatus = 'true'
END