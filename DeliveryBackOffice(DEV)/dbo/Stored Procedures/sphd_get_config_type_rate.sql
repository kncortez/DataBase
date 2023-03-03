
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-12-22>
-- Description:	<Devuelve las configuraciones para un tipo de tarifa>
-- =============================================
 CREATE PROCEDURE [dbo].[sphd_get_config_type_rate]

AS
BEGIN
	SELECT
		[Name] [Name]
	   ,[Value] [Value]
	FROM ConfigParams
	WHERE [Status] = 1
	AND ([Name] LIKE '%Head'
	OR [Name] LIKE '%Departamental'
	OR [Name] LIKE '%Special'
	OR [Name] = 'RateCODLimit')
END