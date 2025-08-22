BEGIN TRY
    BEGIN TRANSACTION;
    
    USE DeliveryBackOffice;
    -- Insertar valores iniciales
    INSERT INTO [EntityTypeByBillingSV] (TypeName, [Description],DateCreated,TokenCreated) VALUES
    ('Seller', 'Entidad que vende productos o servicios',GETDATE(), 'JRAMIREZ-SYS'),
    ('Buyer', 'Entidad que compra productos o servicios',GETDATE(), 'JRAMIREZ-SYS');
    
    -- Consulta para verificar los datos
    SELECT * FROM [EntityTypeByBillingSV];

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
