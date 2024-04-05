-- =============================================
-- Author:		<Oscar Rodriguez>
-- Update date: <2024-03-25>
-- Description:	<Actualiza informacion sobre el tamaño de paquete en base al tamaño del vehiculo, para informacion necesaria en integracion con DispatchTrack>
-- =============================================
BEGIN TRY
	BEGIN TRANSACTION;

	UPDATE [DeliveryBackOffice].[dbo].[CatTypeVehicle]
	SET PackageSize = 'Paquete grande'
	WHERE Name = 'Camión';

	UPDATE [DeliveryBackOffice].[dbo].[CatTypeVehicle]
	SET PackageSize = 'Paquete mediano'
	WHERE Name = 'Panel';

	UPDATE [DeliveryBackOffice].[dbo].[CatTypeVehicle]
	SET PackageSize = 'Paquete pequeño'
	WHERE Name = 'Motocicleta';

	UPDATE [DeliveryBackOffice].[dbo].[CatTypeVehicle]
	SET PackageSize = ''
	WHERE Name <> 'Camión' AND Name <> 'Panel' AND Name <> 'Motocicleta';

	UPDATE [DeliveryBackOffice].[dbo].[CatTypeVehicle]
	SET TokenUpdated = 'SYS-ORODRIGUEZ';

	UPDATE [DeliveryBackOffice].[dbo].[CatTypeVehicle]
	SET DateUpdated = GETDATE();

	COMMIT TRANSACTION;		
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
	PRINT 'Error:' + ERROR_MESSAGE();
END CATCH;