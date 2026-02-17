BEGIN TRY
    SET XACT_ABORT ON;
    BEGIN TRAN;

    ALTER TABLE BillingCustomerBySV
    ADD IdProvince INT NULL;

    ALTER TABLE BillingCustomerBySV 
    ADD CONSTRAINT FK_BillingCustomerBySV_Province
        FOREIGN KEY (IdProvince) 
        REFERENCES dbo.Province(IdProvince);

    EXEC sp_addextendedproperty 
        @name = N'MS_Description',
        @value = N'Id de departamento asociado a cliente(Customer) para El Salvador',
        @level0type = N'SCHEMA',
        @level0name = N'dbo',
        @level1type = N'TABLE',
        @level1name = N'BillingCustomerBySV',
        @level2type = N'COLUMN',
        @level2name = N'IdProvince';

    ALTER TABLE BillingCustomerBySV
    ADD IdTownship INT NULL;

    ALTER TABLE BillingCustomerBySV 
    ADD CONSTRAINT FK_BillingCustomerBySV_Township
        FOREIGN KEY (IdTownship) 
        REFERENCES dbo.Township(IdTownship);

    EXEC sp_addextendedproperty 
        @name = N'MS_Description',
        @value = N'Id de township relacionado a cliente para El Salvador',
        @level0type = N'SCHEMA',
        @level0name = N'dbo',
        @level1type = N'TABLE',
        @level1name = N'BillingCustomerBySV',
        @level2type = N'COLUMN',
        @level2name = N'IdTownship';

    COMMIT TRAN;
	PRINT 'SCRIPT EJECUTADO CORRECTAMENTE';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    PRINT 'Error al ejecutar el script: ' + ERROR_MESSAGE();
END CATCH;
