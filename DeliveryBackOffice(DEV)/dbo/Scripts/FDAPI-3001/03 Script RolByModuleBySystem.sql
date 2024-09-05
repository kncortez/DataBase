--SCRIPT PARA HACER RELACION DE ROL CON MODULO Y SISTEMA

--SELECT * FROM DeliveryBackOffice.dbo.RolByModuleBySystem
--WHERE RmsIdModule = 109 --EJEMPLO DEVELOP

BEGIN TRY
    BEGIN TRANSACTION;

	DECLARE @RmsIdRol INT;
	DECLARE @RmsIdSystem INT;
	DECLARE @RmsIdModule INT;

	SELECT @RmsIdRol = RolIdRol FROM DeliveryBackOffice.dbo.CatRol
	WHERE RolName = 'Facturación Honduras'

	SELECT @RmsIdSystem = SysIdSystem FROM DeliveryBackOffice.dbo.CatSystem
	WHERE SysNameSystem = 'Hermes web operaciones'

	SELECT @RmsIdModule = ModIdModule FROM DeliveryBackOffice.dbo.CatModule
	WHERE ModName = 'Administración de lotes'
    
    INSERT INTO [dbo].[RolByModuleBySystem]
           ([RmsIdRol]
           ,[RmsIdSystem]
           ,[RmsIdModule]
           ,[RmsRowStatus]
           ,[RmsTokenCreated]
           ,[RmsDateCreated]
           ,[RmsTokenUpdated]
           ,[RmsDateUpdated]
           ,[RmsModuleMenu]
           ,[RmsHasNewFunction])
     VALUES
           (@RmsIdRol
           ,@RmsIdSystem
           ,@RmsIdModule
           ,1
           ,'SYS-WOROZCO'
           ,GETDATE()
           ,NULL
           ,NULL
           ,1
           ,0)
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;







