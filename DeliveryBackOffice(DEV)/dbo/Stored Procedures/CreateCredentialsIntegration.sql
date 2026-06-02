
CREATE PROCEDURE [dbo].[CreateCredentialsIntegration]
@Url NVARCHAR (100) = '', --url de pagina web si tuviera
@Name NVARCHAR (100), --nombre del cliente
@CodApp NVARCHAR (50), 
@KeyEncrypt NVARCHAR (100), --Contraseña encriptada
@IdCustomer INT, --Id customer del cliente,
@IdCountry VARCHAR(50) = '', --Id de País
@Token NVARCHAR (50)

AS

	BEGIN

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
				   ,@IdCountry
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

	END
GO
GRANT ALTER
    ON OBJECT::[dbo].[CreateCredentialsIntegration] TO [cvaldes]
    AS [dbo];

