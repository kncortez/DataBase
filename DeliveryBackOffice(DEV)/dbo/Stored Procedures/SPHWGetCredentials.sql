-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,09-12-2024>
-- Description:	<Description,Obtener credenciales de prueba o de producción si el usuario posee>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWGetCredentials]
@IdCustomer INT,
@IsCorporate INT
AS
BEGIN
	
	SET NOCOUNT ON;


	DECLARE @EndPointTest  NVARCHAR(200)
	DECLARE @UserKeyTest   NVARCHAR(200)
	DECLARE @SecretKeyTest NVARCHAR(200)


	DECLARE @EndPointProduction  NVARCHAR(200)
	DECLARE @UserKeyProduction   NVARCHAR(200)
	DECLARE @SecretKeyProduction NVARCHAR(200)
	DECLARE @Email NVARCHAR(50)

	IF (@IsCorporate=1)
	BEGIN 
	 
	 SET  @Email= ( SELECT Top 1  RegexEmail 
	                      FROM [dbo].[Customer] WITH (NOLOCK)
	                           WHERE  IdCustomer = @IdCustomer 
	           );
	END
		ELSE
		BEGIN
	
	     SET       @Email= ( SELECT Top 1  RegexEmail 
								  FROM [dbo].[Customer] WITH (NOLOCK)
									   WHERE  IdCustomer = @IdCustomer);
		END

	/* Obtener Credenciales de prueba si el cliente posee */
	SELECT TOP 1			  
	 @EndPointTest = [EcomerceName],
	 @UserKeyTest  = [UserKey] ,
	 @SecretKeyTest=[SecretKey]
	FROM [DeliveryBackOffice].[dbo].[Ecommerce] WITH (NOLOCK)
	   WHERE IdCustomer = @IdCustomer AND EcommerceDescription = 'Credenciales de prueba para  integracion'
	   AND EcommerceStatus =1
	   ORDER BY DateCreated DESC
	 /* Obtener Credenciales de Producción si el cliente posee */
	SELECT TOP 1
	 @EndPointProduction = [EcomerceName],
	 @UserKeyProduction  = [UserKey],
	 @SecretKeyProduction=[SecretKey]
	FROM [DeliveryBackOffice].[dbo].[Ecommerce] WITH (NOLOCK)
	   WHERE IdCustomer = @IdCustomer
	 AND EcommerceDescription <> 'Credenciales de prueba para  integracion'
	 AND EcommerceStatus =1
	 ORDER BY DateCreated DESC
 

   SELECT 
         CASE  
		      WHEN  LEN(@EndPointTest) > 0 THEN 1
		 ELSE 0 END AS 'IsTest',
		 ISNULL(@EndPointTest,'')  AS 'EndPointTest',
		 ISNULL(@UserKeyTest,'')   AS 'UserKeyTest', 
		 ISNULL(@SecretKeyTest,'') AS 'SecretKeyTest',
		  CASE  
		      WHEN  LEN(@UserKeyProduction) > 0 THEN 1
		 ELSE 0 END AS 'IsProduction',
		 ISNULL(@EndPointProduction ,'') AS 'EndPointProduction',
		 ISNULL(@UserKeyProduction,'')   AS 'UserKeyProduction',
		 ISNULL(@SecretKeyProduction,'') AS 'SecretKeyProduction',
		 ISNULL(@Email,'') AS Email
		 
   






END
