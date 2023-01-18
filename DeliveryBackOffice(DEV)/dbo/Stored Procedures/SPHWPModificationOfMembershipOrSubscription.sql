-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,2022-07-25>
-- Description:	<Description,Modifiar Autorenovación automatica y tipo de pago (en usuarios corporativos se puede cambiar a credito)>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWPModificationOfMembershipOrSubscription]
	-- Add the parameters for the stored procedure here
	@IdCard AS INT,
	@TypeSalePackage AS NVARCHAR(50), -- membership or subscription
	@IdSalePackage AS INT,
	@IdAccount AS BIGINT,
	@TypeOfInMoneyId INT,  -- Tipo de pago
	@ModulId AS INT = NULL, --  pagina o form desde donde se hizo la operación 
	@SystemId AS INT , --  1 y 2 web o 
 	@Token AS NVARCHAR(50),
	@IsAutoRenewable AS bit = 0,
	@UpdateCustomerPaymentId AS INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
	DECLARE @StatusMembershipt INT = (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[Membership] WITH   (NOLOCK) WHERE AccountId =   @IdAccount    AND RowStatus = 1 AND IdMembership = @IdSalePackage)​
	DECLARE @StatusSubcription INT = (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[Subscription] WITH (NOLOCK) WHERE AccountId =   @IdAccount    AND RowStatus = 1 AND IdSubscription = @IdSalePackage)​
	DECLARE @JsonResponse NVARCHAR(MAX) = '';
	DECLARE @HasCredit BIT = 0;
	DECLARE @ClientType INT = 0;
	DECLARE @ClientId INT = 0;
	DECLARE @msg NVARCHAR(20);

		--Validar credito para cliente corporativo
	IF(ISNULL(@IdCard,0) = 0)
		SET @IdCard = NULL;
		
	
	SELECT 
		@ClientId = Ac.idcustomer
		,@ClientType = Cu.IdCustomerType
		,@HasCredit = IIF(ccop.ConditionOfPaymenAbbreviation LIKE '%CREDIT%', 1, 0)
	FROM 
		dbo.account Ac WITH (NOLOCK)
		INNER JOIN 
			dbo.customer Cu WITH (NOLOCK)
			ON 
				Ac.idcustomer = Cu.idcustomer
		LEFT JOIN
			dbo.CatConditionOfPayment ccop WITH (NOLOCK)
			ON
				Cu.ConditionOfPaymentID = ccop.IdConditionOfPayment
	WHERE  
		Ac.accidaccount = @IdAccount

  IF(@TypeSalePackage = 'Membership' COLLATE Latin1_General_CI_AI AND  @StatusMembershipt  > 0)
	BEGIN
	BEGIN TRANSACTION 
		  BEGIN TRY
					
					
						UPDATE  [dbo].[Membership] 
						   SET IsAutoRenewable   = @IsAutoRenewable,
						       CustomerPaymentId = IIF(@IdCard = 0 AND @ClientType = 1 AND @HasCredit = 1, NULL, @IdCard)
						WHERE AccountId = @IdAccount AND IdMembership = @IdSalePackage

					

         SET @JsonResponse  =
            (
                SELECT STUFF(
                                (
                                    SELECT '{{"IdResult":200,' + '"Message": "Modificación de  membresia realizada exitosamente....!!" }'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );

	COMMIT TRANSACTION 
		END TRY
		BEGIN CATCH
						ROLLBACK TRANSACTION 
		END CATCH
	

	END
	ELSE IF(@TypeSalePackage = 'Subscription' COLLATE Latin1_General_CI_AI AND  @StatusSubcription   > 0)
	BEGIN
	BEGIN TRANSACTION 
		  BEGIN TRY
				
				
					UPDATE  [dbo].[Subscription] 
								   SET IsAutoRenewable   = @IsAutoRenewable,
									   CustomerPaymentId = IIF(@IdCard = 0 AND @ClientType = 1 AND @HasCredit = 1, NULL, @IdCard)
								WHERE AccountId = @IdAccount AND IdSubscription = @IdSalePackage

			

         SET @JsonResponse  =
            (
                SELECT STUFF(
                                (
                                    SELECT '{{"IdResult":200,' + '"Message": "Suscripción Modificada exitosamente....!!" }'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );


		COMMIT TRANSACTION 
		END TRY
		BEGIN CATCH
						ROLLBACK TRANSACTION 
		END CATCH
	END
	ELSE
	BEGIN 
	 SET @JsonResponse  =
            (
                SELECT STUFF(
                                (
                                    SELECT '{{"IdResult":500,' + '"Message":"Renovación de :'+ @TypeSalePackage  +' no fue posible...!!" }'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
	END

		SELECT  ( '[' + @JsonResponse + ']' )  JsonOutput 
   
END