CREATE PROCEDURE [dbo].[sphwGetCatCountry] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	    DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
        SAVE TRANSACTION SPGetPendingRecolectionServices;  
    ELSE  
        BEGIN TRANSACTION;  
	BEGIN TRY

		SELECT 
			1 AS 'StatusCode', 
			'Registros obtenidos' AS 'Description';
		SELECT   [IdCountry]  [IdCountry]
			,UPPER([CountryNameES])  [CountryName]
		FROM [DeliveryBackOffice].[dbo].[CatCountry]
			WHERE CountryRowStatus  = 'TRUE'
				  AND IdCountry in ('GT','HN') 

		IF @TranCounter = 0  
            COMMIT TRANSACTION;  
	END TRY
	BEGIN CATCH
        IF @TranCounter = 0  
            ROLLBACK TRANSACTION;  
        ELSE IF XACT_STATE() <> -1  
                ROLLBACK TRANSACTION SPGetPendingRecolectionServices;  
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description';
	END CATCH
	
END