USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SPHW_CreateDeliveryLinkCompleted]    Script Date: 3/10/2024 20:37:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2024-10-25>
-- Description:	<Description,Crear  Link de  con estado completado>
-- =============================================
ALTER PROCEDURE [dbo].[SPHW_CreateDeliveryLinkCompleted]
  @AccountId INT=NULL,
  @CodeOfReference INT=NULL,
  @ReceiverName NVARCHAR(200)=NULL,
  @ReceiverPhone BIGINT=NULL,
  @ReceiverSettlementId INT=NULL,
  @ReceiverEmail NVARCHAR(100)=NULL,
  @CatPaymentTypeId INT = NULL,
  @CatTypeServiceId INT= NULL ,
  @IsInsurance BIT = NULL,
  @InsuranceAmount  DECIMAL(14, 2) = NULL,
  @DeliveryFavCODId INT =NULL,
  @CollectOnDelivery DECIMAL(14, 2) =NULL,
  @ProductId INT,
  @Quantity INT,
  @Price  DECIMAL(14,2)
AS 
BEGIN 

   DECLARE @NewStatusId INT =(SELECT  TOP 1 IdDeliveryLinkStatus FROM [DeliveryBackOffice].[dbo].[DeliveryLinkStatus] WITH(NOLOCK) WHERE [Name]='Completado' )
   DECLARE @Stock INT =  (SELECT TOP 1 ISNULL(Stock,0) FROM Product WITH(NOLOCK) WHERE IdProduct = @ProductId)
   DECLARE @StatusCode INT = 0;
   DECLARE @MessageResponse NVARCHAR(250);
   DECLARE @CountryId NVARCHAR(2) = (SELECT TOP 1  ISNULL(C.CountryID,'GT')
                                        FROM [DeliveryBackOffice].[dbo].[Product] P WITH(NOLOCK)
										     INNER JOIN
											 [DeliveryBackOffice].[dbo].[Account] A WITH(NOLOCK)
											  ON P.AccountId = A.AccIdAccount
											 INNER JOIN
											 [DeliveryBackOffice].[dbo].[Customer] C WITH(NOLOCK)
											  ON C.IdCustomer = A.IdCustomer
								   WHERE IdProduct = @ProductId
                         
						 ) 
	DECLARE @SenderPhone NVARCHAR(8) = (SELECT   TOP 1  RIGHT(RU.Phone,8)
	                                                 FROM 
													   [DeliveryBackOffice].[dbo].[Product] P WITH(NOLOCK)
														  INNER JOIN 
													   [DeliveryBackOffice].[dbo].[Account] A WITH(NOLOCK)
														   ON P.AccountId = A.AccIdAccount
														  INNER JOIN
														[DeliveryBackOffice].[dbo].[Customer] C WITH(NOLOCK)
														  ON A.IdCustomer = C.IdCustomer
														  LEFT JOIN 
															[DeliveryBackOffice].[dbo].[RolByUserByAccount] RUBA WITH(NOLOCK)
															ON  RUBA.RuaIdAccount = A.AccIdAccount
														  INNER JOIN 
															[DeliveryBackOffice].[dbo].RegisterUser RU WITH(NOLOCK)
															ON RU.UsrIdUser = RUBA.RuaIdUser
								   WHERE IdProduct = @ProductId
                                      )

    	DECLARE @SenderEmail NVARCHAR(250) = (SELECT   TOP 1  RU.UsrEmail
	                                                 FROM 
													   [DeliveryBackOffice].[dbo].[Product] P WITH(NOLOCK)
														  INNER JOIN 
													   [DeliveryBackOffice].[dbo].[Account] A WITH(NOLOCK)
														   ON P.AccountId = A.AccIdAccount
														  INNER JOIN
														[DeliveryBackOffice].[dbo].[Customer] C WITH(NOLOCK)
														  ON A.IdCustomer = C.IdCustomer
														  LEFT JOIN 
															[DeliveryBackOffice].[dbo].[RolByUserByAccount] RUBA WITH(NOLOCK)
															ON  RUBA.RuaIdAccount = A.AccIdAccount
														  INNER JOIN 
															[DeliveryBackOffice].[dbo].RegisterUser RU WITH(NOLOCK)
															ON RU.UsrIdUser = RUBA.RuaIdUser
								   WHERE IdProduct = @ProductId)

   SET @AccountId = (SELECT TOP 1  AccountId FROM [DeliveryBackOffice].[dbo].[Product] WITH(NOLOCK) WHERE IdProduct = @ProductId)
   
   DECLARE @PBX NVARCHAR(10)= (SELECT [Value] FROM  [dbo].[ConfigParams] WITH(NOLOCK) WHERE IdCountry = @CountryId AND [Name] = 'PBX' AND IdCountry='GT')
   DECLARE @URL NVARCHAR(200) =(Select [Value] From dbo.ConfigParams Where [Name]='URLLinkdeEntrega' AND IdCountry = @CountryId)	
	BEGIN TRANSACTION
	BEGIN TRY

  
				  IF (EXISTS(
							  (SELECT TOP 1 1
											FROM [DeliveryBackOffice].[dbo].[Product] WITH(NOLOCK) WHERE IdProduct = @ProductId AND Rowstatus=1))) 
					BEGIN
							IF(@Stock > = @Quantity)
							  BEGIN

								INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryLink] 
								(Token,
								 AccountId,
								 OriginCodeOfReference,
								 ReceiverName,
								 ReceiverPhone,
								 ReceiverSettlementId,
								 ReceiverEmail,
								 CatPaymentTypeId,
								 CatTypeServiceId,
								 IsInsurance,
								 InsuranceAmount,
								 DeliveryFacCODId,
								 CollectOnDelivery,
								 DeliveryLinkStatusId,
								 ExpirationDate,
								 RowStatus,
								 UserCreated,
								 DateCreated)
								VALUES
								('',
								 @AccountId,
								 @CodeOfReference,
								 @ReceiverName,
								 @ReceiverPhone,
								 @ReceiverSettlementId,
								 @ReceiverEmail,
								 NULL,
								 NULL,
								 NULL,
								 NULL,
								 NULL,
								 NULL,
								 @NewStatusId,
								 DATEADD(DAY, 1, GETDATE()),
								 1,
								 'SYSTEM-TOKEN-COMPLETED',
								 GETDATE())

								DECLARE @DeliveryLinkID INT;
								DECLARE @hash VARBINARY(16); -- El tamaño del hash MD5 es de 16 bytes (128 bits)
								DECLARE @hashResultado VARCHAR(32); -- El hash MD5 en formato hexadecimal tiene 32 caracteres
									SET @DeliveryLinkID = @@IDENTITY;
									SET @hash = HASHBYTES('MD5', CONCAT(CAST(@DeliveryLinkID AS VARCHAR(50)), CAST(@AccountId AS VARCHAR(50))));
									SET @hashResultado = CONVERT(VARCHAR(32), @hash, 2); -- El hash MD5 en hexadecimal tiene 32 caracteres

								UPDATE [DeliveryBackOffice].[dbo].[DeliveryLink]
								     SET Token = @hashResultado
								WHERE IdDeliveryLink = @DeliveryLinkID


								INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryLinkProducts] 
								(DeliveryLinkId,
								 ProductId,
								 Quantity,
								 Price,
								 RowStatus,
								 UserCreated,
								 DateCreated)
								VALUES
								(@DeliveryLinkID,
								 @ProductId,
								 @Quantity,
								 @Price,
								 1
								 ,'SYSTEM-TOKEN-COMPLETED'
								 ,GETDATE())

								SET @StatusCode = 1;
								SET @MessageResponse = 'Token Creado exitosamente';

								END
									  ELSE
									  BEGIN 
		         								SET @StatusCode = 0;
												SET @MessageResponse = 'Token no creado,cantidad de productos insuficiente en inventario.';
									 END
		  
						END					 
							ELSE
								BEGIN
										SET @StatusCode = 0;
										SET @MessageResponse = 'Token no creado, producto no se encuentra disponible';
		
								END

		COMMIT TRANSACTION

						SELECT
						200 AS 'StatusCode',
						@StatusCode AS'CodeResponse',
						'Operación exitosa' AS 'Description',
						@MessageResponse AS 'MessageResponse'

						SELECT
						@DeliveryLinkID AS 'IdDeliveryLink',
						@hashResultado AS 'Token',
						DATEADD(DAY, 1, GETDATE()) AS 'ExpirationDate',
						2 AS 'DeliveryLinkStatusId',
						@PBX AS 'PBX',
						CASE 
						     WHEN @CountryId ='GT' THEN 'Guatemala'
							 ELSE 'Honduras' END
							 AS 'Country',
					    @SenderPhone  AS SenderPhone,
                        @URL+@hashResultado AS [URL], 
                        @SenderEmail  AS [SenderEmail]
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT
		0 AS 'StatusCode',
		'Error al registrar Link de Entrega' AS 'Description',
		'Creación de Token fallo' AS 'MessageResponse', @@ERROR 'err',
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

	END CATCH
END




 