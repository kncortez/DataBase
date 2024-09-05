--SCRIPT PARA AGREGAR NUEVO ROL PARA ADMINISTRACION DE LOTES SE LLAMARA FacturacionHonduras

--SELECT * FROM DeliveryBackOffice.dbo.CatRol

BEGIN TRY
    BEGIN TRANSACTION;

	DECLARE @RolIdSystem INT;

	SELECT @RolIdSystem = SysIdSystem FROM DeliveryBackOffice.dbo.CatSystem
	WHERE SysNameSystem = 'Hermes web operaciones'

	INSERT INTO [dbo].[CatRol]
			   ([RolIdSystem]
			   ,[RolName]
			   ,[RolDescription]
			   ,[RolAdminBrothers]
			   ,[RolAdminClient]
			   ,[RolRowStatus]
			   ,[RolTokenCreated]
			   ,[RolDateCreated]
			   ,[RolokenUpdated]
			   ,[RolDateUpdated]
			   ,[RolAdminInternal])
		 VALUES
			   (@RolIdSystem
			   ,'Facturación Honduras'
			   ,'Administración de lotes'
			   ,0
			   ,0
			   ,1
			   ,'SYS-WOROZCO'
			   ,GETDATE()
			   ,NULL
			   ,NULL
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









