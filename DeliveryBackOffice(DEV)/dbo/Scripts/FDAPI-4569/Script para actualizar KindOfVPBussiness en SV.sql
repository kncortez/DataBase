--Ajustar el tipo de visitPoint para EXC del salvador, tipo EXC

BEGIN TRY
    BEGIN TRANSACTION;
    
    UPDATE VisitPointClient 
       SET IdKindOfVPBusiness = 23
    WHERE CodeOfReference = 1378846

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
