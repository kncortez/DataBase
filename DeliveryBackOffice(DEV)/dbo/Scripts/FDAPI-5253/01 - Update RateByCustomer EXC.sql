BEGIN TRY
BEGIN TRANSACTION

DECLARE @IdRate			INT = (select RheId from RateHeader with(nolock) where RheName ='Tarifario destinos express center' AND CountryId = 'SV'),
        @TypeCustomer   INT = (select IdCustomerType from CustomerType with(nolock) where [Description] = 'REDISTRIBUIDOR');

        update  RatebyCustomer
        set RbcIdRate = @IdRate,
        RbcTokenUpdated = 'SYS-BPEDROZA',
        RbcDateUpdated = GETDATE()
        where RbcIdCustomer IN (select IdCustomer from Customer with(nolock) where CountryID = 'SV' and IdCustomerType = @TypeCustomer);
 
 COMMIT TRANSACTION
    PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    PRINT 'Ocurrió un error al ejecutar la actualización.'
    PRINT ERROR_MESSAGE()
END CATCH