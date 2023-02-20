-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <13-10-2022>
-- Description:	<Obtiene el catálogo de tipos de incidencia>
-- =============================================
CREATE PROCEDURE spHM_GetIncidentTypeCatalog
	@TypeService NVARCHAR(20) --Posibles valores: PICKUP,RETURN,DELIVERY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
        SAVE TRANSACTION SPspHM_GetIncidentTypeCatalog
    ELSE  
		BEGIN TRANSACTION;  


	BEGIN TRY

		SELECT			  
			1 AS 'StatusCode',
			'Registros obtenidos' AS 'Description';


        SELECT 
			IdIncidenceType 'Id',
			NameIncidence 'Name',
			DescriptionIncidence 'Description'
        FROM DeliveryBackOffice.dbo.CatTypeIncidence WITH(NOLOCK)
        WHERE RowStatus = 1
		AND ServiceType = @TypeService
       


		IF @TranCounter = 0  
			COMMIT TRANSACTION; 
	END TRY
	BEGIN CATCH
        IF @TranCounter = 0  
            ROLLBACK TRANSACTION;  
        ELSE IF XACT_STATE() <> -1  
                ROLLBACK TRANSACTION SPspHM_GetIncidentTypeCatalog;  
		SELECT			  
			0 AS 'StatusCode',
			ERROR_MESSAGE() AS 'Description';
	END CATCH
END