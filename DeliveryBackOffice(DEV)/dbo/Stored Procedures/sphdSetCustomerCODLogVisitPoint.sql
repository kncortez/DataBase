-- =============================================
-- Author:		<Oscar,Rodriguez>
-- Create date: <2024-04-26>
-- Description:	<Inserta registros de historial sobre modificaciones en cuentas bancarias para clientes COD en Puntos de Visita Hermes Desktop>
-- =============================================
CREATE PROCEDURE [dbo].[sphdSetCustomerCODLogVisitPoint]
    @CustomerId INT
  , @VisitPointId INT = NULL
  , @isCOD INT = NULL
  , @CODExcludePriceShipping INT = NULL
  , @CODExcludeComission INT = NULL
  , @CODIdBank INT = NULL
  , @CODAccountName VARCHAR(100) = ''
  , @CODAccountNumber INT = NULL
  , @CODAccountTypeId INT = NULL
  , @CODCurrencyId INT = NULL
  , @Token VARCHAR(50) = ''
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;
    BEGIN TRY

		INSERT INTO [DeliveryBackOffice].[dbo].[CustomerCODLog]
                (
                    [CustomerId]
				  , [VisitPointId]
                  , [isCOD]
                  , [CODExcludePriceShipping]
                  , [CODExcludeComission]
                  , [CODIdBank]
                  , [CODAccountName]
                  , [CODAccountNumber]
                  , [CODAccountTypeId]
                  , [CODCurrencyId]
                  , [CODCatBatchType]
                  , [CODCatBatchFrequency]
                  , [CODBillingTimeId]
                  , [CODBillingVolumeId]
                  , [CODBillingCutOfDate]
                  , [DateRegister]
                  , [TokenRegister]
                  , [DateUpdated]
                  , [TokenUpdated]
                )
                VALUES
                (   @CustomerId, @VisitPointId, @isCOD, @CODExcludePriceShipping, @CODExcludeComission, @CODIdBank
                  , @CODAccountName, @CODAccountNumber, @CODAccountTypeId, @CODCurrencyId
                  , NULL, NULL, NULL, NULL, NULL, GETDATE(), @Token, NULL, NULL);

				  

		SELECT 'TRUE' [blnResult],
			CAST(@VisitPointId AS VARCHAR(50)) [IdResult],
			'' AS [ErrorNumber],
			'' AS [ErrorSeverity],
			'' AS [ErrorState],
			'' AS [ErrorProcedure],
			'' AS [ErrorLine],
			'Success' AS [Message]

		PRINT 'Commit Transaction'

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        SELECT 'FALSE' [blnResult],
			CAST(@VisitPointId AS VARCHAR(10)) AS [IdResult],
            CAST(ERROR_NUMBER() AS VARCHAR) AS [ErrorNumber],
            CAST(ERROR_SEVERITY() AS VARCHAR) AS [ErrorSeverity],
            CAST(ERROR_STATE() AS VARCHAR) AS [ErrorState],
            CAST(ERROR_PROCEDURE() AS VARCHAR) AS [ErrorProcedure],
            CAST(ERROR_LINE() AS VARCHAR) AS [ErrorLine],
            CAST(ERROR_MESSAGE() AS NVARCHAR(MAX)) AS [Message]
			PRINT 'Catch Exception Rollback Transaction;'
        ROLLBACK TRANSACTION;
    END CATCH;
END;