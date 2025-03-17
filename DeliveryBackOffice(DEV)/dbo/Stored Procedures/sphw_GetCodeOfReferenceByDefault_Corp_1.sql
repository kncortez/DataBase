-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-10-10>
-- Description:	<Link de entregas - Obtener el resumen de la información para realizar envío sin login>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_GetCodeOfReferenceByDefault_Corp]
	@IdCountry as varchar(2)
AS
BEGIN
	declare @CodeOfReference as VARCHAR(8)
	
	SELECT @CodeOfReference = [value] 
	FROM ConfigParams
	WHERE [name] = 'InvoicesCodeOfReferenceCorp'
		AND IdCountry = @IdCountry

	SELECT @CodeOfReference [CodeOfReference]

END