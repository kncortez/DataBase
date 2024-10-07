-- =============================================
-- Author:		<César, Aquino>
-- Create date: <2021-04-22>
-- Description:	<Retorna los tarifarios>
-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <2024-06-04>
-- Description:	<Se agrega parametro para filtrar por pais>
-- =============================================
create PROCEDURE [dbo].[sphd_get_Rate]
@IdCountry AS NVARCHAR(2)='GT'
AS
BEGIN

	select rd.RheId [Id]
		,rd.RheName [Name]
		,rd.RateTypeId [TypeRate]
	from dbo.RateHeader rd
	WHERE rd.RheRowStatus ='true'
	AND rd.IsTemplate = 'true'
	AND IIF(rd.CountryId IS NULL, 'GT',rd.CountryId) = @IdCountry

END