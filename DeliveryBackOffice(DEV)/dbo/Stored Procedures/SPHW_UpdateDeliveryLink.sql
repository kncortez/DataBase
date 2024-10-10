-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2024-10-25>
-- Description:	<Description,Actualizar estado Link de entrega >
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_UpdateDeliveryLink] 
@Token         NVARCHAR(250),
@ReceiverName  NVARCHAR(200),
@ReceiverPhone NVARCHAR(50),
@ReceiverEmail NVARCHAR(100),
@ReceiverZone  NVARCHAR(100),
@ReceiverCatCityPlaceId INT,
@ReceiverNeighborhood   NVARCHAR(50),
@ReceiverAddress        NVARCHAR(600),
@ReceiverAdditionalInstuctions NVARCHAR(250),
@ReceiverLatitude  NVARCHAR(50),
@ReceiverLongitude NVARCHAR(50),
@IsDeliveryLink BIT = 1,
@ReceiverSettlementId INT
AS
BEGIN

  DECLARE @Result INT=0;
  DECLARE @NewStatusId INT =(SELECT  TOP 1IdDeliveryLinkStatus FROM [dbo].[DeliveryLinkStatus] WITH(NOLOCK) WHERE [Name]='Completado' )
  DECLARE @StatusId INT =(SELECT TOP 1  IdDeliveryLinkStatus FROM [dbo].[DeliveryLinkStatus]WITH(NOLOCK)  WHERE  [Name]='Aperturado' )
  DECLARE @Canceled    INT =(SELECT TOP 1  IdDeliveryLinkStatus FROM [DeliveryBackOffice].[dbo].[DeliveryLinkStatus] WITH(NOLOCK) WHERE [Name]='Anulado' );
  DECLARE @OriginCodeOfReference INT =(SELECT	TOP 1 OriginCodeOfReference FROM dbo.DeliveryLink WITH(NOLOCK) WHERE Token = @Token)
  DECLARE @IdAccount INT =(SELECT	TOP 1 AccountId FROM dbo.DeliveryLink WITH(NOLOCK) WHERE Token = @Token)
  DECLARE @NickName NVARCHAR(100) = ( SELECT    TOP 1    
                                            RU.UsrNickName
							              FROM 
											 [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
											INNER JOIN
											 [DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
												ON VPC.CustomerId= Cu.IdCustomer
											 INNER JOIN 
											  [DeliveryBackOffice].[dbo].[Account] A WITH(NOLOCK)
												 ON Cu.IdCustomer = A.IdCustomer
											INNER JOIN 
											  [DeliveryBackOffice].[dbo].[RolByUserByAccount] RUBA WITH(NOLOCK)
												ON  RUBA.RuaIdAccount = A.AccIdAccount
											  INNER JOIN 
											  [DeliveryBackOffice].[dbo].RegisterUser RU WITH(NOLOCK)
												 ON RU.UsrIdUser = RUBA.RuaIdUser
											WHERE A.AccIdAccount = @IdAccount
										)

    DECLARE @CountryId NVARCHAR(2) = (SELECT TOP 1  ISNULL(Cu.CountryID,'GT')
                                         FROM 
											 [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
											INNER JOIN
											 [DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
												ON VPC.CustomerId= Cu.IdCustomer
											 INNER JOIN 
											  [DeliveryBackOffice].[dbo].[Account] A WITH(NOLOCK)
												 ON Cu.IdCustomer = A.IdCustomer
											INNER JOIN 
											  [DeliveryBackOffice].[dbo].[RolByUserByAccount] RUBA WITH(NOLOCK)
												ON  RUBA.RuaIdAccount = A.AccIdAccount
											  INNER JOIN 
											  [DeliveryBackOffice].[dbo].RegisterUser RU WITH(NOLOCK)
												 ON RU.UsrIdUser = RUBA.RuaIdUser
											WHERE A.AccIdAccount = @IdAccount
															)
                         
					
   DECLARE @SenderPhone NVARCHAR(8) = (
                                         SELECT TOP 1  RIGHT(RU.Phone,8)
                                         FROM 
											 [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
											INNER JOIN
											 [DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
												ON VPC.CustomerId= Cu.IdCustomer
											 INNER JOIN 
											  [DeliveryBackOffice].[dbo].[Account] A WITH(NOLOCK)
												 ON Cu.IdCustomer = A.IdCustomer
											INNER JOIN 
											  [DeliveryBackOffice].[dbo].[RolByUserByAccount] RUBA WITH(NOLOCK)
												ON  RUBA.RuaIdAccount = A.AccIdAccount
											  INNER JOIN 
											  [DeliveryBackOffice].[dbo].RegisterUser RU WITH(NOLOCK)
												 ON RU.UsrIdUser = RUBA.RuaIdUser
											WHERE A.AccIdAccount = @IdAccount
									)

   
   DECLARE @PBX NVARCHAR(10)= (SELECT [Value] FROM  [dbo].[ConfigParams] WITH(NOLOCK) WHERE IdCountry = @CountryId AND [Name] = 'PBX')
   DECLARE @URL NVARCHAR(200) =(Select [Value] From dbo.ConfigParams Where [Name]='URLLinkdeEntrega' AND IdCountry= @CountryId)
  BEGIN TRANSACTION
	BEGIN TRY
	   
		IF(EXISTS(SELECT TOP 1 1 FROM [dbo].[DeliveryLink] WITH(NOLOCK) WHERE Token = @Token AND DeliveryLinkStatusId = @Canceled))
		  BEGIN
				SET @Result =3;

			END
				 ELSE
					  BEGIN
							IF(EXISTS(SELECT TOP 1 1 FROM [dbo].[DeliveryLink] WITH(NOLOCK) WHERE Token = @Token AND DeliveryLinkStatusId = @StatusId))
							   BEGIN

	
		
		
							   
											  UPDATE [dbo].[DeliveryLInk]
												 SET DeliveryLinkStatusId = @NewStatusId,
													 ReceiverName  = @ReceiverName,
													 ReceiverPhone = @ReceiverPhone,
													 ReceiverEmail = @ReceiverEmail,
													 ReceiverCatCityPlaceId = @ReceiverCatCityPlaceId,
													 ReceiverSettlementId = @ReceiverSettlementId,
													 ReceiverZone = @ReceiverZone,
													 ReceiverNeighborhood = @ReceiverNeighborhood,
													 ReceiverAddress = @ReceiverAddress,
													 ReceiverAdditionalInstuctions = @ReceiverAdditionalInstuctions,
													 ReceiverLatitude  = @ReceiverLatitude,
													 ReceiverLongitude = @ReceiverLongitude
											  WHERE TOKEN = @Token

											  SET @Result =1;
										  END 
			END


	  
	COMMIT TRANSACTION;

	IF(@Result=1)
	BEGIN
	     SELECT 1 AS [StatusCode], 'Datos Actualizados exitosamente' AS[MessageResponse], @NickName [NickName],@PBX AS 'PBX',
						CASE 
						     WHEN @CountryId ='GT' THEN 'Guatemala'
							 ELSE 'Honduras' END
							 AS 'Country',
							 @URL + @Token AS [URL],
							 @SenderPhone AS  [SenderPhone] 
	   END
	     ELSE IF (@Result=0)
		 BEGIN
		    SELECT 0 AS [StatusCode], 'Token no vigente' AS[MessageResponse], @NickName [NickName],@PBX AS 'PBX',
						CASE 
						     WHEN @CountryId ='GT' THEN 'Guatemala'
							 ELSE 'Honduras' END
							 AS 'Country' 
			END
			  ELSE
		          SELECT 3 AS [StatusCode], 'Token Anulado' AS[MessageResponse], @NickName [NickName],@PBX AS 'PBX',
						CASE 
						     WHEN @CountryId ='GT' THEN 'Guatemala'
							 ELSE 'Honduras' END
							 AS 'Country' 

	END TRY
	
		BEGIN CATCH
		
			ROLLBACK TRANSACTION;

			SELECT 0 AS [StatusCode], 'Actualización de datos fallida' AS[MessageResponse]

		 END CATCH

END



 