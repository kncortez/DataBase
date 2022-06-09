
-- =============================================
-- Author:		<Andres Ruiz>
-- Create date: <2022-03-08>
-- Description:	< Obtiene los servicios activos que pueden ser configurables desde base de datos >
-- =============================================
CREATE PROCEDURE [dbo].[GetConfigurableServices]
	@AllServices BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@AllServices =  0)
	BEGIN

		-- Solo los servicios activos
		SELECT
			CCS.IdCatConfigurableService 'Identificador'
			,CCS.CatConfigurableServiceName 'Servicio'
			,CCS.CatConfigurableServiceDescription 'Descripcion'
		FROM
			[DeliveryBackOffice].[dbo].[CatConfigurableService] CCS WITH(NOLOCK)
		WHERE
			CCS.RowStatus = 1
		ORDER BY
			CCS.IdCatConfigurableService

	END
	ELSE
	BEGIN

		-- Todos los servicios
		SELECT
			CCS.IdCatConfigurableService 'Identificador'
			,CCS.CatConfigurableServiceName 'Servicio'
			,CCS.CatConfigurableServiceDescription 'Descripcion'
		FROM
			[DeliveryBackOffice].[dbo].[CatConfigurableService] CCS WITH(NOLOCK)
		ORDER BY
			CCS.IdCatConfigurableService

	END

END


