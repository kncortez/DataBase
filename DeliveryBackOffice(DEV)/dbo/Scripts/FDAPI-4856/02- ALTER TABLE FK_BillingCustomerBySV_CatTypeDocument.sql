BEGIN TRANSACTION;
BEGIN TRY


    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_BillingCustomerBySV_CatTypeDocument'
              AND parent_object_id = OBJECT_ID('dbo.BillingCustomerBySV')
    )
    BEGIN
        ALTER TABLE [dbo].[BillingCustomerBySV] 
        ADD CONSTRAINT [FK_BillingCustomerBySV_CatTypeDocument] 
            FOREIGN KEY([Inv_type])
            REFERENCES [dbo].[CatTypeDocument] ([IdRegister])
    END
    ELSE
    BEGIN
        PRINT 'LLAVE : FK_BillingCustomerBySV_CatTypeDocument YA EXISTE'
    END
    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

END CATCH