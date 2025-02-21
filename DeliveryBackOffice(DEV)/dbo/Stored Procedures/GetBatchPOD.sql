
-- =============================================  
-- Author:  <Cristian Suazo  
-- Update date: <2025-02-17>  
-- Description: <Se obtienen todos los lotes que aun no han sido procesados para el servicio>  
-- ============================================= 
CREATE PROCEDURE [dbo].[GetBatchPOD]
AS
BEGIN
	DECLARE @CreateStatus INT

	SET @CreateStatus = (SELECT IdServiceStatus FROM CatServiceStatus WITH(NOLOCK) WHERE Name = 'Creado')

	SELECT SchedulePickupId,
		   DateCreated
	FROM FinishPickUpHeader WITH (NOLOCK)
	WHERE ServiceStatusId = @CreateStatus 
	ORDER BY DateCreated DESC 
END