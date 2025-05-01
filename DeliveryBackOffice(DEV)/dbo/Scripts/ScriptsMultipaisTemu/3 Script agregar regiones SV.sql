SELECT * FROM DeliveryBackOffice.dbo.CatRegion WITH(NOLOCK) --Regiones
BEGIN TRY
    BEGIN TRANSACTION;

INSERT INTO [dbo].[CatRegion]([RegionName],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[IdCountry])VALUES('OCCIDENTE',1,'SYS-WOROZCO',GETDATE(),NULL,NULL,'SV')
INSERT INTO [dbo].[CatRegion]([RegionName],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[IdCountry])VALUES('CENTRAL',1,'SYS-WOROZCO',GETDATE(),NULL,NULL,'SV')
INSERT INTO [dbo].[CatRegion]([RegionName],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[IdCountry])VALUES('ORIENTE',1,'SYS-WOROZCO',GETDATE(),NULL,NULL,'SV')


 COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
