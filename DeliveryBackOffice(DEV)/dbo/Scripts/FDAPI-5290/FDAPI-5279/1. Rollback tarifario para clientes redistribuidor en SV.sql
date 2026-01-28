/* =================================================
   Script:    Rollback tarifario para clientes redistribuidor en SV.
   Propósito: Modificación de tarifario asignado a clientes redistribuidor en SV.
   Autor:     Walter Orozco
   Historia:  FDAPI-5290[FDAPI-5279]
   Fecha:     2025-12-23
================================================= */

BEGIN TRY
	BEGIN TRANSACTION

	DECLARE
		@Token			NVARCHAR(100)	= 'SYS-RBDESCUENTOEXC',
		@DateUpdate		DATETIME		= GETDATE(),
		@IdCountry		NVARCHAR(2)		= 'SV';

	DECLARE @IdRate			INT = (SELECT RheId FROM RateHeader WITH(NOLOCK) WHERE RheName ='Tarifario de servicio estandar' AND CountryId = @IdCountry),
			@TypeCustomer   INT = (SELECT IdCustomerType FROM CustomerType WITH(NOLOCK) WHERE [Description] = 'REDISTRIBUIDOR');

	UPDATE  RatebyCustomer
	SET 
		RbcIdRate		= @IdRate,
		RbcTokenUpdated = @Token,
		RbcDateUpdated	= @DateUpdate
	WHERE RbcIdCustomer IN (SELECT IdCustomer FROM Customer WITH(NOLOCK) WHERE CountryID = @IdCountry and IdCustomerType = @TypeCustomer);
 
	COMMIT TRANSACTION;
	PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;