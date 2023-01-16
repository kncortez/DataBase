-- =============================================
-- Author:		<Author,Edelman Vásquez,Name>
-- Create date: <Create Date,2022-07-25>
-- Description:	<Description,SP para activar Membresias o Subscripciones>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWPMembershipOrSubscriptionActivation]

 @IdCard AS BIGINT = 0,
 @IdAccount AS BIGINT,
 @Token AS NVARCHAR(50),
 @MembershipCode AS NVARCHAR(50),
 @InvoiceName AS NVARCHAR(100),
 @TaxIdNumber AS NVARCHAR(50),
 @InvoiceEmail AS NVARCHAR(50),
 @FiscalAddress AS NVARCHAR(200)
        

AS
BEGIN

    DECLARE @CodeResult AS INT
	DECLARE @TypeSalePackage AS NVARCHAR(20);
	DECLARE @ExpirationDateMembership    AS DATETIME = (SELECT ExpirationDate FROM dbo.Membership   WITH (NOLOCK) WHERE MembershipCode = @MembershipCode)
	DECLARE @ExpirationDateSubscription  AS DATETIME = (SELECT ExpirationDate FROM dbo.Subscription WITH (NOLOCK) WHERE SubscriptionCode = @MembershipCode)
	DECLARE @JsonResponse NVARCHAR(MAX) = '';
	-- Variables de control de flujo
	DECLARE @HasCredit BIT = 0;
	DECLARE @ClientType INT = 0;
	DECLARE @ClientId INT = 0;
	SET NOCOUNT ON;

		IF EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[Membership] WITH (NOLOCK) WHERE   MembershipCode = @MembershipCode)
			SET @TypeSalePackage = 'MEMBERSHIP';
		

		IF EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[Subscription] WITH (NOLOCK) WHERE  SubscriptionCode = @MembershipCode)
		   SET @TypeSalePackage = 'SUBSCRIPTION';
		
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
	
	
				IF ( @TypeSalePackage = 'MEMBERSHIP' AND NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[Membership] WITH (NOLOCK)   WHERE AccountId =  @IdAccount   AND RowStatus = 1)​)
					BEGIN	
		
								IF(@ExpirationDateMembership > GETDATE())
								BEGIN
							
											UPDATE dbo.Membership 
											SET AccountId = @IdAccount, 
												CustomerId = @ClientId,
												InvoiceName=@InvoiceName, 
												TaxIdNumber = @TaxIdNumber, 
												InvoiceEmail =@InvoiceEmail,
												CustomerPaymentId = IIF(@IdCard = 0 AND @ClientType = 1 AND @HasCredit = 1, NULL, @IdCard),
												FiscalAddress = @FiscalAddress,
												TokenUpdated = @Token,
												DateUpdated = GETDATE()
											WHERE MembershipCode = @MembershipCode

	
									   SET @JsonResponse  =
												(
													SELECT STUFF(
																	(
																		SELECT '{{"IdResult":200,' + '"Message":"Membresía Activada exitosa...!!"}'
																		FOR XML PATH(''), TYPE
																	).value('.', 'varchar(max)'),
																	1,
																	1,
																	''
																)
												);

					  

									END
								ELSE
									BEGIN
									 SET @JsonResponse  =
														(
															SELECT STUFF(
																			(
																				SELECT '{{"IdResult":500,' + '"Message":"Membresia no  vigente, no es posible activarla...!!"}'
																				FOR XML PATH(''), TYPE
																			).value('.', 'varchar(max)'),
																			1,
																			1,
																			''
																		)
														);
									
		
								  END
							
					END;	
				
		
---Valaidaciones para suscripciones, confirmar que si tenga una membresia activa
IF (@TypeSalePackage = 'SUBSCRIPTION' 
     AND EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[Membership] WITH (NOLOCK)   
	      WHERE AccountId =  @IdAccount   AND RowStatus = 1)​
    )

		   SET @CodeResult =   
				CASE   
					-- Valdiar que exista la subscripción
					WHEN NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[Subscription] WITH (NOLOCK) 
									WHERE AccountId =  @IdAccount   
										   AND RowStatus = 1 AND SubscriptionCode = @MembershipCode)   
						 AND @ExpirationDateSubscription > GETDATE()
						THEN 1 
						ELSE 3
  
				 END;  
    IF (@CodeResult = 1)
							UPDATE dbo.Subscription 
							SET AccountId = @IdAccount, 
								MembershipId = (SELECT tOP 1 IdMembership FROM [dbo].[Membership] WITH (NOLOCK) Where AccountId = @IdAccount  AND RowStatus = 1 ),
								CustomerId = @ClientId,
								CustomerPaymentId =IIF(@IdCard = 0 AND @ClientType = 1 AND @HasCredit = 1, NULL, @IdCard),
								TokenUpdated = @Token,
								DateUpdated = GETDATE()
							WHERE SubscriptionCode = @MembershipCode

										   SET @JsonResponse  =
													(
														SELECT STUFF(
																		(
																			SELECT '{{"IdResult":200,' + '"Message":"Subscription Activada exitosa...!!"}'
																			FOR XML PATH(''), TYPE
																		).value('.', 'varchar(max)'),
																		1,
																		1,
																		''
																	)
													);


	 IF (@JsonResponse IS NULL OR @JsonResponse='' )
	   BEGIN
		 SET @JsonResponse  =
					(
						SELECT STUFF(
										(
											SELECT '{{"IdResult":500,' + '"Message":"No se Actualizarón registros '+@TypeSalePackage +'"}'
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