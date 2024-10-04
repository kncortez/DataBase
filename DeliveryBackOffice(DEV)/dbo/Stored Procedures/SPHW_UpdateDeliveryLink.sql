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
  DECLARE @StatusId INT =(SELECT TOP 1  IdDeliveryLinkStatus FROM [dbo].[DeliveryLinkStatus] WITH(NOLOCK) WHERE [Name]='Aperturado' )
  DECLARE @OriginCodeOfReference INT =(SELECT	TOP 1 OriginCodeOfReference FROM dbo.DeliveryLink WITH(NOLOCK) WHERE Token = @Token)
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
											WHERE VPC.CodeOfReference = @OriginCodeOfReference
															)

  BEGIN TRANSACTION
	BEGIN TRY


IF(EXISTS(SELECT TOP 1 * FROM [dbo].[DeliveryLink] WHERE Token = @Token AND DeliveryLinkStatusId = @StatusId))
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
	  
	COMMIT TRANSACTION;

	IF(@Result=1)
	BEGIN
	     SELECT 1 AS [StatusCode], 'Datos Actualizados exitosamente' AS[MessageResponse], @NickName [NickName] 
	   END
	     ELSE
		    SELECT 0 AS [StatusCode], 'Token no vigente' AS[MessageResponse], @NickName [NickName] 
		

	END TRY
	
		BEGIN CATCH
		
			ROLLBACK TRANSACTION;

			SELECT 0 AS [StatusCode], 'Actualización de datos fallida' AS[MessageResponse]

		 END CATCH

END

