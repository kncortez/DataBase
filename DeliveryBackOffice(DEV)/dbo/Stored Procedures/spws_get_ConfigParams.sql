-- =============================================
-- Author:		<Freddy, Monterroso>
-- Create date: <2021-11-03>
-- Description:	<Devuelve el valor de la configuracion de un parámetros de configuración>
-- =============================================
-- =============================================
-- Author:		<Walter, Orozco>
-- Create date: <2024-06-25>
-- Description:	<Cambio de reestructuración de JSON y multipais>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_ConfigParams]
    @pName AS NVARCHAR(100),
	@pIdCountry as NVARCHAR(3) = 'GT',
	@pCurrency as INT = NULL
AS
BEGIN

SELECT 
	ISNULL(REPLACE(pms.Name, '"', ''), '')				[Name]
	,ISNULL(REPLACE(pms.Description, '"', ''), '')		[Description]
	,ISNULL(REPLACE(pms.Value, '"', ''), '')			[Value]
FROM DeliveryBackOffice.dbo.ConfigParams pms WITH(NOLOCK)
	WHERE pms.Name = @pName	AND pms.Status = 1
	AND (pms.IdCountry = @pIdCountry OR (@pIdCountry = 'GT' AND pms.IdCountry IS NULL))
	AND (pms.IdCurrencyCOD = @pCurrency OR pms.IdCurrencyCOD IS NULL)

END
