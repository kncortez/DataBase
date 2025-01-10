
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2024-12-12>
-- Description:	<Description,credenciales de producción>
-- =============================================
CREATE PROCEDURE [dbo].[SPWHProductionCredentialsRegistration]
@IdCustomer INT,
@IsCorporate INT,
@IdCountry NVARCHAR(2),
@Token NVARCHAR(100)

AS
BEGIN
	
	----------EJECUTAR SP PARA CREAR CREDENCIALES------------

DECLARE @Url nvarchar(100) = ''
DECLARE @Name nvarchar(100) = (SELECT [Name] FROM [dbo].[Customer] WHERE IdCustomer = @IdCustomer);
DECLARE @CodApp nvarchar(50) = 'SICOMLAXAPIECOM200920231525'
DECLARE @KeyEncrypt nvarchar(100) = 'n4IapUw4C49ehE+S6YCvJdpxvnh9XPScSLTCCNcE6epnri1ohPmBhSAkXv7DhJEm'



		INSERT INTO [dbo].[Ecommerce]
				   ([EcomerceName]
				   ,[EcommerceDescription]
				   ,[IsPaymentGateway]
				   ,[IdCountry]
				   ,[ApiWSEndPoint]
				   ,[ApiWSPort]
				   ,[ApiWSResource]
				   ,[ApiWSController]
				   ,[ApiWSMethod]
				   ,[UserKey]
				   ,[Passkey]
				   ,[SecretKey]
				   ,[CertSourceKey]
				   ,[EcommerceStatus]
				   ,[TokenCreated]
				   ,[DateCreated]
				   ,[TokenUpdate]
				   ,[DateUpdated]
				   ,[IdCustomer])
			 VALUES
				   (@Url --esta url debe de venir en el correo de solicitud
				   ,@Name --nombre del negocio 
				   ,'FALSE'
				   ,'GT'
				   ,'forza.systems'
				   ,''
				   ,''
				   ,''
				   ,''
				   ,@CodApp-- SE CONSTRUYE CON : PALABRA "SI" + "NOMBRE DE CLIENTE" + "APICOM" + FECHA Y HORA
				   ,''
				   ,@KeyEncrypt --CONTRASEÑA ENCRIPTADA
				   ,''
				   ,'TRUE'
				   ,@Token
				   ,GETDATE()
				   ,NULL
				   ,NULL
				   ,@IdCustomer)--IdCustomer sacado de tabla Customer


             SELECT 1 [IdResult],
							  'Proceso de registro de credenciales exitoso' [Message],
							  @Name AS 'EcomerceName',
							  @Name AS 'EcommerceDescription',
							  @CodApp AS 'UserKey',
							  @KeyEncrypt AS 'SecretKey'

END
GO

