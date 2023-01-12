-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create 2023-01-09>
-- Description:	<Description, SP para obtener data de membresía o suscripción recien adquirida>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetDataMembershipOrSubscription]
	@TypeSalePackage AS nvarchar(50),
	@IdSalePackage AS INT,        -- id membership or suscription
	@IdAccount AS INT
	
AS
BEGIN


	DECLARE     @IdMemberOrSuscription AS INT
	DECLARE     @inv_cli_email AS  NVARCHAR(50)
	DECLARE     @Name AS NVARCHAR(100)
	DECLARE     @DateExpiration AS DATETIME
	DECLARE     @Url AS Nvarchar(max)
	

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
		
		END
	     

		 SELECT @inv_cli_email Mail, 
		        @IdMemberOrSuscription Id,
				@Name [Name],
				CONVERT(VARCHAR, @DateExpiration, 101) [DateExpirate],
				@Url as [Url]

	END TRY
	BEGIN CATCH

	  SELECT Result = 0 , ERROR_MESSAGE() [Description] 
	END Catch
END