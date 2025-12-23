/***
-- ACTUALIZACIÓN DE LA TABLA PARA DATOS DE FACUTRACIÓN COORPORATIVO
***/

BEGIN TRANSACTION;
BEGIN TRY

    ALTER TABLE [dbo].[BillingCustomerBySV]
    ADD 
        [TypeIdentificationDocumentCode] NVARCHAR(100) NULL,
        [IdDocument] NVARCHAR(100) NULL,
        [Inv_type] INT NULL;

    -- Agregar comentarios de los campos

    EXEC sp_addextendedproperty @name = N'MS_Description', 
                            @value = N'Tipo de documento de identificación del comprador', 
                            @level2type = N'COLUMN', 
                            @level2name = 'TypeIdentificationDocumentCode', 
                            @level0type = N'SCHEMA', 
                            @level0name = 'dbo', 
                            @level1type = N'TABLE',  
                            @level1name = 'BillingCustomerBySV';

    EXEC sp_addextendedproperty @name = N'MS_Description', 
                            @value = N'Número de identificación', 
                            @level2type = N'COLUMN', 
                            @level2name = 'IdDocument', 
                            @level0type = N'SCHEMA', 
                            @level0name = 'dbo', 
                            @level1type = N'TABLE',  
                            @level1name = 'BillingCustomerBySV';

    EXEC sp_addextendedproperty @name = N'MS_Description',
                            @value = N'tipo de documento que se emite, referencia a tabla CatTypeDocument',
                            @level0type = N'SCHEMA',
                            @level0name = N'dbo',
                            @level1type = N'TABLE',
                            @level1name = N'BillingCustomerBySV',
                            @level2type = N'COLUMN',
                            @level2name = N'Inv_type'

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

END CATCH

