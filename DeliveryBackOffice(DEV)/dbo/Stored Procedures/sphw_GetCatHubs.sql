-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <22-09-2022>
-- Description:	<Método que obitene el catálogo de hubs activos>
-- =============================================
CREATE PROCEDURE sphw_GetCatHubs
	-- Add the parameters for the stored procedure here
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
		SELECT 
			IdHubLogistic,
			HubName,
			HubAbbreviation,
			IdStation,
			IdCountry
		FROM DBO.HubLogistics 
			WHERE HubStatus =1;

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