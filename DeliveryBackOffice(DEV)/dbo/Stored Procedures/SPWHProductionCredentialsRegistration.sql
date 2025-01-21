
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2024-12-12>
-- Description:	<Description,credenciales de producción>
-- =============================================
CREATE PROCEDURE [dbo].[SPWHProductionCredentialsRegistration]
@IdCustomer INT,
@IsCorporate INT,
@IdCountry NVARCHAR(2),
@Token NVARCHAR(100),
@HashedPasswordHex NVARCHAR(100)

AS
BEGIN




DECLARE @Date NVARCHAR(15) = (SELECT 
								CONCAT(
									FORMAT(GETDATE(), 'yyyy'),
									FORMAT(GETDATE(), 'MM'),
									FORMAT(GETDATE(), 'dd'),
									FORMAT(GETDATE(), 'hh'),
									FORMAT(GETDATE(), 'mm')
								) AS FechaHoraSinSeparadores);

DECLARE @Url nvarchar(100) = (SELECT TOP 1[Value] FROM dbo.ConfigParams WHERE [Name]='APIUrl')
DECLARE @Name nvarchar(100) = (SELECT TOP 1 [Name] FROM [dbo].[Customer] WITH (NOLOCK) WHERE IdCustomer = @IdCustomer);
DECLARE @NameAbrev nvarchar(100) = (SELECT TOP 1 [Abbreviation] FROM [dbo].[Customer] WITH (NOLOCK) WHERE IdCustomer = @IdCustomer);
DECLARE @ClientEmail nvarchar(100) = (SELECT TOP 1 [ContactEmail] FROM [dbo].[Customer] WITH (NOLOCK) WHERE IdCustomer = @IdCustomer);
DECLARE @SoportEmail nvarchar(100) = (SELECT TOP 1[Value] FROM dbo.ConfigParams WHERE [Name]='SupportEmailByCountry' AND					IdCountry=@IdCountry)
DECLARE @CodeOfReference INT =(
                                SELECT TOP 1 CodeOfReference FROM dbo.VisitPointClient WITH (NOLOCK)
                                                                        WHERE CustomerId=@IdCustomer)

DECLARE @IdAccount INT = (SELECT TOP 1 AccIdAccount FROM dbo.Account WITH (NOLOCK)
                                                       WHERE IdCustomer= @IdCustomer)

SET @NameAbrev = LTRIM(RTRIM(@NameAbrev)); -- Elimina espacios al principio y al final
SET @NameAbrev = REPLACE(@NameAbrev, '.', ''); -- Elimina el carácter especial '.'
SET @NameAbrev = REPLACE(@NameAbrev, ' ', ''); -- Elimina los espacios internos

DECLARE @CodApp nvarchar(50) = 'SI'+ @NameAbrev + 'APICOM' + @Date --PALABRA "SI" + "NOMBRE DE CLIENTE" + "APICOM" + FECHA Y HORA





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
				   ,@HashedPasswordHex --@KeyEncrypt --CONTRASEÑA ENCRIPTADA
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
							  @HashedPasswordHex AS 'SecretKey',
							  @Url AS 'Endpoint',
							  @ClientEmail AS 'UsrEmail',
							  @SoportEmail AS 'SoportEmail',
							  CAST(@CodeOfReference AS nvarchar) AS 'CodeOfReference',
							  CAST(@IdAccount AS nvarchar) AS 'IdAccount'


END
