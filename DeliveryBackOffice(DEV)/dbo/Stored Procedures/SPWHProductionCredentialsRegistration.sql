
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

DECLARE @RandomPassword NVARCHAR(32)
DECLARE @Characters NVARCHAR(MAX) = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
DECLARE @Length INT = 32
DECLARE @Index INT = 0

SET @RandomPassword = ''

WHILE @Index < @Length
BEGIN
    SET @RandomPassword = @RandomPassword + SUBSTRING(@Characters, ABS(CHECKSUM(NEWID())) % LEN(@Characters) + 1, 1)
    SET @Index = @Index + 1
END

	----------EJECUTAR SP PARA CREAR CREDENCIALES------------
DECLARE @Password NVARCHAR(32) = @RandomPassword
DECLARE @Key NVARCHAR(32) = 'ClaveSecreta'
DECLARE @HashedPassword VARBINARY(32)

-- Concatenar contraseña y clave para HMAC
SET @HashedPassword = HASHBYTES('SHA2_256', @Key + @Password)

DECLARE @Date NVARCHAR(15) = (SELECT 
								CONCAT(
									FORMAT(GETDATE(), 'yyyy'),
									FORMAT(GETDATE(), 'MM'),
									FORMAT(GETDATE(), 'dd'),
									FORMAT(GETDATE(), 'hh'),
									FORMAT(GETDATE(), 'mm')
								) AS FechaHoraSinSeparadores);

DECLARE @Url nvarchar(100) = ''
DECLARE @Name nvarchar(100) = (SELECT TOP 1 [Name] FROM [dbo].[Customer] WIY WHERE IdCustomer = @IdCustomer);
DECLARE @NameAbrev nvarchar(100) = (SELECT TOP 1 [Abbreviation] FROM [dbo].[Customer] WHERE IdCustomer = @IdCustomer);
DECLARE @ClientEmail nvarchar(100) = (SELECT TOP 1 [ContactEmail] FROM [dbo].[Customer] WHERE IdCustomer = @IdCustomer);
DECLARE @SoportEmail nvarchar(100) = (SELECT TOP 1[Value] FROM dbo.ConfigParams WHERE [Name]='SupportEmailByCountry' AND					IdCountry=@IdCountry)
DECLARE @CodeOfReference INT =(
                                SELECT TOP 1 CodeOfReference FROM dbo.VisitPointClient
                                                                        WHERE CustomerId=@IdCustomer)

DECLARE @IdAccount INT = (SELECT TOP 1 AccIdAccount FROM dbo.Account
                                                       WHERE IdCustomer= @IdCustomer)

SET @NameAbrev = LTRIM(RTRIM(@NameAbrev)); -- Elimina espacios al principio y al final
SET @NameAbrev = REPLACE(@NameAbrev, '.', ''); -- Elimina el carácter especial '.'
SET @NameAbrev = REPLACE(@NameAbrev, ' ', ''); -- Elimina los espacios internos

DECLARE @CodApp nvarchar(50) = 'SI'+ @NameAbrev + 'APICOM' + @Date --PALABRA "SI" + "NOMBRE DE CLIENTE" + "APICOM" + FECHA Y HORA
DECLARE @KeyEncrypt nvarchar(100) = @HashedPassword--'n4IapUw4C49ehE+S6YCvJdpxvnh9XPScSLTCCNcE6epnri1ohPmBhSAkXv7DhJEm'




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
							  @KeyEncrypt AS 'SecretKey',
							  'https://sandbox.apicore.forzadelivery.io:40467/ecommerce/GetListTownshipByHeaderCode' AS 'Endpoint',
							  @ClientEmail AS 'UsrEmail',
							  @SoportEmail AS 'SoportEmail',
							  CAST(@CodeOfReference AS nvarchar) AS 'CodeOfReference',
							  CAST(@IdAccount AS nvarchar) AS 'IdAccount'


END
GO




