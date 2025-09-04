
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,12/08/2025>
-- Description:	<Description,Actualizar el estado de la transacción de pasarela de pago PayWayOne SV>
-- =============================================
CREATE PROCEDURE SPHW_UpdateCustomerTransactionPWO 
    @Type AS INT = -1
  , @System AS INT = 1
  , @CardNumber AS NVARCHAR(50) =NULL
  , @Signature AS NVARCHAR(100) = NULL
  , @ReferenceNumber AS VARCHAR(50) = ''
  , @TransactionStain AS VARCHAR(50) = ''
  , @ReasonCode AS NVARCHAR(50) = NULL
  , @ReasonDescription AS NVARCHAR(100) = NULL
  , @StatusSend AS INT = NULL
  , @TokenUpdated AS NVARCHAR(50) = NULL

AS
BEGIN

        DECLARE @IdTransaction BIGINT = 0;
		DECLARE @Code INT=0;
		DECLARE @Description NVARCHAR(50)='ERROR';
    -- Transacción para ingreso de proceso con tarjeta
        BEGIN TRANSACTION LogTransactionTypeOne;
        BEGIN TRY


            -- Flujo normal de spws_set_facapidelcreditcardtransaction
            SELECT @IdTransaction = ISNULL([IdTransaction], 0),
			       @OrderNumber   = ISNULL(OrderNumber,'') 
            FROM [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] CCTBC WITH (NOLOCK)
            WHERE [CCTBC].Signature = @Signature
                  
      
             IF (@IdTransaction > 0)
             BEGIN

			      IF(@CardNumber<>null)
				   BEGIN
						UPDATE [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer]
						SET [System] = @System
						  , CardNumber = @CardNumber
						  , [Signature] = @Signature
						  , ReferenceNumber = @ReferenceNumber
						  , TransactionStain = @TransactionStain
						  , ReasonCode = @ReasonCode
						  , ReasonDescription = @ReasonDescription
						  , StatusSend = @StatusSend
						  , TokenUpdated = @TokenUpdated
						  , DateUpdated = GETDATE()
						WHERE IdTransaction = @IdTransaction
							  AND TransactionStain = @TransactionStain
					END
					   ELSE
					   BEGIN
					        UPDATE [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer]
							SET 
							    ReasonCode = @ReasonCode
							  , ReasonDescription = @ReasonDescription
							  , TokenUpdated = @TokenUpdated
							  , DateUpdated = GETDATE()
							WHERE IdTransaction = @IdTransaction
								  AND TransactionStain = @TransactionStain
					   END
                      
                 SET @Code = 1
				 SET @Description = 'Success';

            END
		    
			 SELECT @Code    AS   'Code',
                    @Description AS [Description],
					@OrderNumber AS 'OrderNumber'

            COMMIT TRANSACTION LogTransactionTypeOne;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION LogTransactionTypeOne;

			SELECT 0    AS   'Code'
             , 'Error' AS [Description]
			 , @OrderNumber AS 'OrderNumber'

        END CATCH;

END


