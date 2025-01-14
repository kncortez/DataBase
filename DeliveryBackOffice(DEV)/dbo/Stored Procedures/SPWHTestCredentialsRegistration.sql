
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2024-10-12>
-- Description:	<Description,Registrar credenciales de prueba para usuario Individual>
-- =============================================
CREATE PROCEDURE [dbo].[SPWHTestCredentialsRegistration]
@IdCustomer INT,
@IsCorporate INT,
@IdCountry NVARCHAR(2),
@Token NVARCHAR(100)

AS
BEGIN

		SET NOCOUNT ON;

	DECLARE @EcomerceName NVARCHAR(200) =(SELECT [Description] FROM [dbo].[ConfigParams] WITH (NOLOCK) WHERE [Name]='EcomerceName');
    DECLARE @EcommerceDescription NVARCHAR(200) =(SELECT [Description] FROM [dbo].[ConfigParams] WITH (NOLOCK) WHERE [Name]='EcommerceDescription');
    DECLARE @UserKey NVARCHAR(200)  =(SELECT [Description] FROM [dbo].[ConfigParams] WITH (NOLOCK) WHERE [Name]='UserKey');
    DECLARE @SecretKey NVARCHAR(200)  =(SELECT [Description] FROM [dbo].[ConfigParams] WITH (NOLOCK) WHERE [Name]='SecretKeyQA');

	DECLARE @ClientEmail nvarchar(100) = (SELECT TOP 1 [ContactEmail] FROM [dbo].[Customer] WITH (NOLOCK) WHERE IdCustomer = @IdCustomer);
    DECLARE @SoportEmail nvarchar(100) = (SELECT TOP 1[Value] FROM dbo.ConfigParams WITH (NOLOCK) WHERE [Name]='SupportEmailByCountry' AND					IdCountry=@IdCountry)
    DECLARE @CodeOfReference INT =(
                                SELECT TOP 1 CodeOfReference FROM dbo.VisitPointClient WITH (NOLOCK)
                                                                        WHERE CustomerId=@IdCustomer)

    DECLARE @IdAccount INT = (SELECT TOP 1 AccIdAccount FROM dbo.Account WITH (NOLOCK)
                                                       WHERE IdCustomer= @IdCustomer)

    DECLARE @Url nvarchar(100) = (SELECT TOP 1 [Value] FROM dbo.ConfigParams WHERE [Name]='APIUrlQA')

	BEGIN TRANSACTION
	BEGIN TRY

	IF ( NOT EXISTS(SELECT TOP 1 1			  
	                FROM [DeliveryBackOffice].[dbo].[Ecommerce] WITH (NOLOCK)
			   WHERE IdCustomer = @IdCustomer AND EcommerceDescription = 'Credenciales de prueba para  integracion'
			   AND EcommerceStatus =1)
	   )
	   BEGIN
				INSERT INTO [dbo].[Ecommerce] (
					EcomerceName,
					EcommerceDescription,
					IsPaymentGateway,
					IdCountry,
					ApiWSEndPoint,
					UserKey,
					SecretKey,
					EcommerceStatus,
					TokenCreated,
					DateCreated,
				   IdCustomer

				)
				VALUES(
				@EcomerceName,
				@EcommerceDescription,
				0,
				@IdCountry,
				'forza.systems',
				@UserKey,
				@SecretKey,
				1,
				@Token,
				GETDATE(),
				@IdCustomer

				)

		
				 SELECT 1 [IdResult],
							  'Proceso de registro de credenciales exitoso' [Message],
							  @EcomerceName AS 'EcomerceName',
							  @EcommerceDescription AS 'EcommerceDescription',
							  @UserKey AS 'UserKey',
							  @SecretKey AS 'SecretKey',
							  @Url AS 'Endpoint',
							  @ClientEmail AS 'UsrEmail',
							  @SoportEmail AS 'SoportEmail',
							  CAST(@CodeOfReference AS nvarchar) AS 'CodeOfReference',
							  CAST(@IdAccount AS nvarchar) AS 'IdAccount'

        END
		  ELSE
		  BEGIN

		      	 SELECT 0 [IdResult],
							  'Credenciales ya existen' [Message],
							  @EcomerceName AS 'EcomerceName',
							  @EcommerceDescription AS 'EcommerceDescription',
							  @UserKey AS 'UserKey',
							  @SecretKey AS 'SecretKey',
							  @Url AS 'Endpoint',
							  @ClientEmail AS 'UsrEmail',
							  @SoportEmail AS 'SoportEmail',
							  CAST(@CodeOfReference AS nvarchar) AS 'CodeOfReference',
							  CAST(@IdAccount AS nvarchar) AS 'IdAccount'

		  END
	COMMIT TRANSACTION

	END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION;
		
     SELECT 209 [IdResult],
                  'Error en proceso' [Message],
				  ERROR_MESSAGE() AS [ErrorMessage];

END CATCH 





   
END
