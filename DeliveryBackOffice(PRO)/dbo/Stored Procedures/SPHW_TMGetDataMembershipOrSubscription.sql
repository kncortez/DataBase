-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date, 2023-02-02>
-- Description:	<Description, Sp para obtener data de memebresia y suscripciones >
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_TMGetDataMembershipOrSubscription] 
@CatMembershipId AS INT,
@AccountId AS INT
AS
BEGIN
	
	SET NOCOUNT ON;

 	DECLARE     @IdMemberOrSuscription AS INT
	DECLARE     @inv_cli_email AS  NVARCHAR(50)
	DECLARE     @Name AS NVARCHAR(100)
	DECLARE     @DateExpiration AS DATETIME
	DECLARE     @Url AS Nvarchar(max)
	

	SET NOCOUNT ON;

    BEGIN TRY




	 SET @Url= 'https://portal.forzadelivery.com/design/dashboard' 


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
			WHERE M.AccountId =   @AccountId AND 
				 M.RowStatus = 1 AND 
				 CM.IdCatMembership = @CatMembershipId

				 


	     

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