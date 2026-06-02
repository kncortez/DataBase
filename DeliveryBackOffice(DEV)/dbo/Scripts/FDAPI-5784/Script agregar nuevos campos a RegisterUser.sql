BEGIN TRY
    BEGIN TRANSACTION;

    -- Agregar nuevos campos
    ALTER TABLE [dbo].[RegisterUser]
    ADD 
        [UsrPasswordLastUpdate] DATETIME NULL,
        [UsrPasswordUpdatedBy] INT NULL;

    -- Agregar comentarios de los campos
    EXEC sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Fecha de última actualización de contraseña', 
        @level0type = N'SCHEMA',
        @level0name = N'dbo', 
        @level1type = N'TABLE',
        @level1name = N'RegisterUser', 
        @level2type = N'COLUMN',
        @level2name = N'UsrPasswordLastUpdate';

    EXEC sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Usuario que realizó la última actualización de contraseña', 
        @level0type = N'SCHEMA',
        @level0name = N'dbo', 
        @level1type = N'TABLE',
        @level1name = N'RegisterUser', 
        @level2type = N'COLUMN',
        @level2name = N'UsrPasswordUpdatedBy';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();

    PRINT 'Error: ' + @ErrorMessage;
END CATCH;