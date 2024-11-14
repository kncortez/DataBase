
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2024-11-12>
-- Description:	<Description,Notificación de estados de guía vía whatsapp>
-- =============================================
CREATE PROCEDURE [dbo].[SphwGuideStatusNotification]
@NirPhoner NVARCHAR(6) ='+502',
@Phone INT ,
@GuideSerie NVARCHAR(2),
@GuideNumber INT,
@CountryId NVARCHAR(2) NULL='GT'
AS
BEGIN


DECLARE @StatusCode INT=0;
DECLARE @Description NVARCHAR(500);
DECLARE @IsStatusTerminal INT =(SELECT Top 1 IIF(b.CatCheckpointTypeId=3,1,0)
                                     From [dbo].[DeliveryOrderDetail] a WITH(NOLOCK)
									 Inner Join
									       [dbo].[StatusOrder] b WITH(NOLOCK)
									ON a.StatusOrderId=b.StatusOrderId
								WHERE a.Guide_serie = @Guideserie AND  a.Guide_Number = @GuideNumber
								ORDER BY a.DateCreated DESC);

  BEGIN TRANSACTION LogTransactionTypeOne;
        BEGIN TRY
      

IF(NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[GuideStatusNotification] WITH(NOLOCK) WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber ))
BEGIN

   INSERT INTO [dbo].[GuideStatusNotification] (NirPhoner,
												Phone,
												GuideSerie,
												GuideNumber,
												CountryId,
												LastChangeDate,
												FinalStatus,
												RowStatus,
												TokenCreated,
												DateCreated
										)
		VALUES(
		@NirPhoner,
		@Phone,
		@GuideSerie,
		@GuideNumber,
		@CountryId,
		GETDATE(),
		@IsStatusTerminal,
		1,
		'NOTIFICATION-STATUS',
		GETDATE()
		)

		SET @StatusCode = 200;
		SET @Description = '!Registro de notificación exitoso¡';

END
   ELSE
	BEGIN

	    SET @StatusCode = 0;
		SET @Description = '!Registro de notificación ya existe¡';
	END

	SELECT @StatusCode AS 'IdResult', @Description AS 'MessageResult'

	COMMIT TRANSACTION LogTransactionTypeOne;

 END TRY
    BEGIN CATCH

	    SET @StatusCode = 3;
		
		SELECT 3 AS 'IdResult', '!Error en transacción¡' AS 'MessageResult'

        ROLLBACK TRANSACTION LogTransactionTypeOne;

 END CATCH;


 
END
GO


 