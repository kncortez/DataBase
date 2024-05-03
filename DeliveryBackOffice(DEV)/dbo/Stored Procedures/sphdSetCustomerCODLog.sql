CREATE PROCEDURE [dbo].[sphdSetCustomerCODLog]
    @CustomerId INT
  , @isCOD INT = NULL
  , @CODExcludePriceShipping INT = NULL
  , @CODExcludeComission INT = NULL
  , @CODIdBank INT = NULL
  , @CODAccountName VARCHAR(100) = ''
  , @CODAccountNumber INT = NULL
  , @CODAccountTypeId INT = NULL
  , @CODCurrencyId INT = NULL
  , @CODCatBatchType INT = NULL
  , @CODCatBatchFrequency INT = NULL
  , @CODBillingTimeId INT = NULL
  , @CODBillingVolumeId INT = NULL
  , @CODBillingCutOfDate DATETIME = NULL
  , @Token VARCHAR(50) = ''
  , @ActionType INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;
    BEGIN TRY
	
		INSERT INTO [DeliveryBackOffice].[dbo].[CustomerCODLog]
				(
					[CustomerId]
				  , [IsCOD]
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
				(   @CustomerId, @isCOD, @CODExcludePriceShipping, @CODExcludeComission, @CODIdBank
				  , @CODAccountName, @CODAccountNumber, @CODAccountTypeId, @CODCurrencyId
				  , @CODCatBatchType, @CODCatBatchFrequency, @CODBillingTimeId, @CODBillingVolumeId
				  , @CODBillingCutOfDate, GETDATE(), @Token, NULL, NULL);

		IF (@ActionType = 1)
		BEGIN
			UPDATE vpcf
			SET vpcf.CODAccountBankID = NULL,
				vpcf.CODAccountName = NULL,
				vpcf.CODAccountNumber = NULL,
				vpcf.CODAccountBankTypeID = NULL,
				vpcf.CODAccountCurrencyID = NULL,
				vpcf.TokenUpdated = @Token,
				vpcf.DateUpdated = GETDATE()
			FROM [DeliveryBackOffice].[dbo].[VisitPointConfiguration] vpcf
			INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc ON vpcf.VisitPointID = vpc.CodeOfReference
			INNER JOIN [DeliveryBackOffice].[dbo].[Customer] AS cs ON cs.IdCustomer = vpc.CustomerID
			WHERE cs.IdCustomer = @CustomerId
			AND vpcf.CODAccountBankID IS NOT NULL;

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
			SELECT @CustomerId, vpcf.VisitPointID, @isCOD
				  , NULL, NULL, NULL, NULL, NULL, NULL, NULL
				  , NULL, NULL, NULL, NULL, NULL,  GETDATE(), @Token, NULL, NULL
			FROM [DeliveryBackOffice].[dbo].[VisitPointConfiguration] vpcf
			INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc ON vpcf.VisitPointID = vpc.CodeOfReference
			INNER JOIN [DeliveryBackOffice].[dbo].[Customer] AS cs ON cs.IdCustomer = vpc.CustomerID
			WHERE cs.IdCustomer = @CustomerId
			AND vpcf.CODAccountBankID IS NOT NULL;
		END

			SELECT 'TRUE'                       [blnResult]
				 , CAST(@CustomerId AS VARCHAR) [IdResult]
				 , ''                           AS [ErrorNumber]
				 , ''                           AS [ErrorSeverity]
				 , ''                           AS [ErrorState]
				 , ''                           AS [ErrorProcedure]
				 , ''                           AS [ErrorLine]
				 , 'Success'                    AS [Message];

		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SELECT 'FALSE'                                [blnResult]
             , CAST(ERROR_NUMBER() AS VARCHAR)        AS [ErrorNumber]
             , CAST(ERROR_SEVERITY() AS VARCHAR)      AS [ErrorSeverity]
             , CAST(ERROR_STATE() AS VARCHAR)         AS [ErrorState]
             , CAST(ERROR_PROCEDURE() AS VARCHAR)     AS [ErrorProcedure]
             , CAST(ERROR_LINE() AS VARCHAR)          AS [ErrorLine]
             , CAST(ERROR_MESSAGE() AS NVARCHAR(MAX)) AS [Message];
        ROLLBACK TRANSACTION;
    END CATCH;
END;