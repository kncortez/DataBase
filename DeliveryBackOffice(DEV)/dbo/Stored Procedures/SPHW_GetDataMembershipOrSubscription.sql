-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create 2023-01-09>
-- Description:	<Description, SP para obtener data de membresía o suscripción recien adquirida>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetDataMembershipOrSubscription]
	@TypeSalePackage AS NVARCHAR(50),
	@IdSalePackage AS INT,        -- id membership or suscription
	@IdAccount AS INT
	
AS
BEGIN

	DECLARE     @IdMemberOrSuscription AS INT
	DECLARE     @inv_cli_email AS  NVARCHAR(50)
	DECLARE     @Name AS NVARCHAR(100)
	DECLARE     @DateExpiration AS DATETIME
	DECLARE     @Url AS Nvarchar(max)
	DECLARE     @LastInvoiceId AS INT
	
	SET NOCOUNT ON;

    BEGIN TRY

	 SET @Url= 'https://portal.forzadelivery.com/design/dashboard' 

	 IF(@TypeSalePackage = 'Membership' COLLATE Latin1_General_CI_AI)
		BEGIN
  
		  SELECT TOP 1      
		        @inv_cli_email  = M.InvoiceEmail,
				@IdMemberOrSuscription = M.IdMembership,
				@Name = c.[Name],
				@DateExpiration = M.ExpirationDate
		    FROM [DeliveryBackOffice].[dbo].[Membership] M WITH (NOLOCK)
					INNER JOIN [dbo].[CatMembership] CM WITH (NOLOCK)
				 ON M.CatMembershipId = CM.IdCatMembership
					INNER JOIN [dbo].[Customer] c WITH (NOLOCK)
				 ON M.CustomerId = c.IdCustomer
			WHERE M.AccountId =   @IdAccount AND 
				 M.RowStatus = 1 AND 
				 CM.IdCatMembership = @IdSalePackage

			SELECT 
				TOP (1) 
					@LastInvoiceId = [InH].[inv_pk_id]
			FROM 
				[dbo].[invoiceHeader] InH  WITH(NOLOCK) 
				INNER JOIN
					[dbo].[invoiceDetail] InD  WITH(NOLOCK) 
					ON
						[InH].[inv_pk_id] = [InD].[dti_fk_header]
			WHERE
				[InD].[MembershipId] = @IdMemberOrSuscription
				AND
				ISNULL([InH].[inv_certificationFEL], '') = ''
				AND
				ISNULL([InH].[inv_invoiceOfCreditNote], 0) = 0
				AND
				ISNULL([InH].[inv_creditNote], 0) = 0
				AND
				DATEDIFF(DAY, [InH].[inv_date], GETDATE()) < 5;


		END
		ELSE
		BEGIN
		

			Select  TOP 1
					@inv_cli_email  = M.InvoiceEmail,
					@IdMemberOrSuscription = S.IdSubscription,
					@Name = c.[Name],
					@DateExpiration = S.ExpirationDate
				From [dbo].[Membership] M WITH (NOLOCK)
					Inner Join [dbo].[Subscription] S WITH (NOLOCK)
				ON M.IdMembership = s.MembershipId
					Inner Join [dbo].[CatSubscription] CS WITH (NOLOCK)
				ON s.CatSubscriptionId= cs.IdCatSubscription
				    INNER JOIN [dbo].[Customer] c WITH (NOLOCK)
				ON  S.CustomerId =c.IdCustomer
				WHERE M.AccountId =   @IdAccount AND 
					  M.RowStatus = 1 AND 
				      CS.IdCatSubscription = @IdSalePackage
				ORDER BY M.DateCreated DESC

			SELECT 
				TOP (1) 
					@LastInvoiceId = [InH].[inv_pk_id]
			FROM 
				[dbo].[invoiceHeader] InH  WITH(NOLOCK) 
				INNER JOIN
					[dbo].[invoiceDetail] InD  WITH(NOLOCK) 
					ON
						[InH].[inv_pk_id] = [InD].[dti_fk_header]
			WHERE
				[InD].[SubscriptionId] = @IdMemberOrSuscription
				AND
				ISNULL([InH].[inv_certificationFEL], '') = ''
				AND
				ISNULL([InH].[inv_invoiceOfCreditNote], 0) = 0
				AND
				ISNULL([InH].[inv_creditNote], 0) = 0
				AND
				DATEDIFF(DAY, [InH].[inv_date], GETDATE()) < 5;
		
		END
	     

		 SELECT @inv_cli_email Mail, 
		        @IdMemberOrSuscription Id,
				@Name [Name],
				CONVERT(VARCHAR, @DateExpiration, 101) [DateExpirate],
				@Url as [Url],
				ISNULL(@LastInvoiceId, -1) [IdInvoice],
				200 [ResultCode],
				'' [ResultMessage]

	END TRY
	BEGIN CATCH

		  SELECT 
			  Result = 0 
			  , ERROR_MESSAGE() [Description] 
			  , 500 [ResultCode]
			  , ERROR_MESSAGE() [ResultMessage]
	END Catch
END