
CREATE PROCEDURE [dbo].[SupportSetConfigurationExcGuideManual] 
@Guide INT
AS
BEGIN

   

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.DeliveryOrder 
		SET	 Receiver_ID =0
		, IdDeliveryOption = 1
		WHERE Guide_Serie ='fd' AND Guide_Number = @Guide
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT ERROR_LINE(),
               ERROR_MESSAGE(),
               ERROR_NUMBER(),
               ERROR_PROCEDURE(),
               ERROR_STATE();
    END CATCH;

END;