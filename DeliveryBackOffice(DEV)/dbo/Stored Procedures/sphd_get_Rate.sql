-- =============================================
-- Author:		<César, Aquino>
-- Create date: <2021-04-22>
-- Description:	<Retorna los tarifarios>
-- =============================================
create PROCEDURE [dbo].[sphd_get_Rate]
AS
BEGIN

	select rd.RheId [Id]
		,rd.RheName [Name]
		,rd.RateTypeId [TypeRate]
	from dbo.RateHeader rd
	WHERE rd.RheRowStatus ='true'
	AND rd.IsTemplate = 'true'
	

END