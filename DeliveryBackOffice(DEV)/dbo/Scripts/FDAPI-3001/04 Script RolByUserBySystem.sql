--SCRIPT PARA UNIR ROL, SISTEMA Y USUARIO

--SELECT * FROM DeliveryBackOffice.dbo.RolByUserBySystem
--WHERE RusIdSystem = 13 AND RusIdRol = 32 AND RusIdUser = 79690

BEGIN TRY
    BEGIN TRANSACTION;

	DECLARE @RusIdRol INT;
	DECLARE @RusIdSystem INT;
	DECLARE @RusIdUser INT;
	DECLARE @StationId INT;

	SELECT @RusIdRol = RolIdRol FROM DeliveryBackOffice.dbo.CatRol
	WHERE RolName = 'Facturación Honduras'

	SELECT @RusIdSystem = SysIdSystem FROM DeliveryBackOffice.dbo.CatSystem
	WHERE SysNameSystem = 'Hermes web operaciones'

	SELECT @RusIdUser = UsrIdUser FROM DeliveryBackOffice.dbo.RegisterUser
	WHERE UsrEmail = 'cristi.contreras@forzadelivery.com' --CAMBIAR AL USUARIO QUE SE LE QUIERA ASIGNAR

	SELECT @StationId = IdStation FROM DeliveryBackOffice.dbo.CatStation
	WHERE StationName = 'FD EXC CHOLUTECA' --DEPENDE DEL USUARIO

    INSERT INTO [dbo].[RolByUserBySystem]
           ([RusIdRol]
           ,[RusIdSystem]
           ,[RusIdUser]
           ,[RusRowStatus]
           ,[RusTokenCreated]
           ,[RusDateCreated]
           ,[RusTokenUpdated]
           ,[RusDateUpdated]
           ,[StationId])
     VALUES
           (@RusIdRol
           ,@RusIdSystem
           ,@RusIdUser
           ,1
           ,'SYS-WOROZCO'
           ,GETDATE()
           ,NULL
           ,NULL
           ,@StationId)
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;

