
CREATE PROCEDURE [dbo].[SetAuthorizationLogCOD]
    @GuideSerie [varchar](4) ,	
	@GuideNumber INT ,	
	@Voucher [nvarchar](800) = '' ,	
	@AuthorizedBy [varchar](MAX),	
	@ReasonId BIGINT ,	
	@NewCODAmount [decimal](14, 2),
	@TokenCreated nvarchar(max),
	@CountryId nvarchar(2) = 'GT'
AS
BEGIN
	
	DECLARE @OldCODAmount DECIMAL (14,2)

	BEGIN TRANSACTION;

	BEGIN TRY

	IF EXISTS(SELECT * FROM DeliveryBackOffice.dbo.DeliveryOrder DOR
    INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail DORD
        ON DOR.Guide_Serie = DORD.Guide_Serie
           AND DOR.Guide_Number = DORD.Guide_Number
		   WHERE DORD.Guide_Serie = @GuideSerie AND DORD.Guide_Number = @GuideNumber AND  DORD.StatusOrderId NOT IN (5) AND IIF(SenderCountryId IS NULL, 'GT', SenderCountryId) = @CountryId )
	BEGIN
	SET @OldCODAmount = (SELECT Collect_OnDelivery FROM DeliveryBackOffice.dbo.DeliveryOrder  
	WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber )

	UPDATE DeliveryBackOffice.dbo.DeliveryOrder  
	SET LastCollectOnDelivery = Collect_OnDelivery,  Collect_OnDelivery = @NewCODAmount
	WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber

	INSERT INTO [dbo].[AuthorizationLogCOD]
           ([GuideSerie]
           ,[GuideNumber]
           ,[Voucher]
           ,[AuthorizedBy]
           ,[ReasonId]
           ,[OldCODAmount]
           ,[NewCODAmount]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           (@GuideSerie
           ,@GuideNumber
           ,@Voucher
           ,@AuthorizedBy
           ,@ReasonId
           ,@OldCODAmount
           ,@NewCODAmount
           ,1
           ,@TokenCreated
           ,GETDATE()
           ,NULL
           ,NULL)

	END
								
	END TRY
	BEGIN CATCH
		SELECT 'RollBackTransactionLOGCOD' AS message,
				'FALSE'	blnResult,
				CAST(-1 AS VARCHAR(5)) IdResult,
				CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber,
				CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity,
				CAST(ERROR_STATE() AS VARCHAR) AS ErrorState,
				CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure,
				CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine,
				CAST(ERROR_MESSAGE() AS VARCHAR) AS ResultMessage;

		ROLLBACK TRANSACTION;
	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
		
		SELECT  'TRUE' AS blnResult 		

		COMMIT TRANSACTION;
	END
	ELSE
	BEGIN
	SELECT  'FALSE' AS blnResult 
		COMMIT TRANSACTION;
	END
END
