--SCRIPT PARA AGREGAR NUEVO MODULO QUE SE LLAMA ADMINISTRACIÓN DE LOTES

SELECT * FROM DeliveryBackOffice.dbo.CatModule

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated]
           ,[ModGroup])
     VALUES
           ('Administración de lotes'
           ,NULL --modulo padre
           ,'/operaciones/administracion-lotes'
           ,'Módulo de administración de lotes, facturación'
           ,10 --<ModOrder, int,>
           ,'bi bi-receipt' --icon
           ,1
           ,1
           ,'SYS-WOROZCO'
           ,GETDATE()
           ,NULL
           ,NULL
           ,NULL)
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;














