-- =============================================
-- Author:		<Brandon, Pedroza >
-- Create date: <2024-07-04>
-- Description:	<Obtiene el listado de paises>
-- =============================================
-- Author:		<Cristian, Azurdia>
-- Create date: <2025-04-08>
-- Description:	<Obtener listado de paises activos para Multipais>
-- =============================================
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

        SELECT   cc.[IdCountry]  [IdCountry]
            ,UPPER(cc.[CountryNameES])  [CountryName]
        FROM [DeliveryBackOffice].[dbo].[CatCountry] cc
        INNER JOIN [DeliveryBackOffice].[dbo].[DefaultValuesPerCountry] dvpc
            ON dvpc.IdCountry = cc.IdCountry
        WHERE dvpc.UseMultiCountry  = 1

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