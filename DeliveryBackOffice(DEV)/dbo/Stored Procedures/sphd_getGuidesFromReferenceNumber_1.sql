-- =============================================
-- Author:		<Tito García>
-- Create date: <2024-10-29>
-- Description:	<Se obtienen las guías según el número de referencia>
-- =============================================
-- Author:		<Tito García>
-- Updated date: <2025-01-08>
-- Description:	<Se agrega filtro para obtner las guias que no estan en estados terminales y se valida la referencia si existe en el país>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_getGuidesFromReferenceNumber]
	@ReferenceNumber NVARCHAR(150),
	@IdCountry VARCHAR(2) = 'GT'
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY

        -- Verificamos si existen guías en el país solicitado
        IF EXISTS (
            SELECT 1
            FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
            WHERE DO.Ticket_Number = @ReferenceNumber
              AND DO.SenderCountryId = @IdCountry
              AND ISNULL(DO.GuideType, 'DOM') = 'DOM'
        )
        BEGIN
		    SELECT 1 AS StatusCode,
                   'Exito' AS Description;

            SELECT TOP 10 
                CONCAT(Guide_Serie, Guide_Number) AS Guide
            FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
                INNER JOIN [dbo].[StatusOrder] SO WITH (NOLOCK)
                    ON DO.StatusOrderId = SO.StatusOrderId
            WHERE SO.CatCheckpointTypeId <> 3
              AND SO.RowStatus = 1
              AND DO.Ticket_Number = @ReferenceNumber
              AND DO.SenderCountryId = @IdCountry
            ORDER BY DO.DateCreated DESC;

        END
        ELSE IF EXISTS (
            SELECT 1
            FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
            WHERE DO.Ticket_Number = @ReferenceNumber
              AND DO.SenderCountryId <> @IdCountry
              AND ISNULL(DO.GuideType, 'DOM') = 'DOM'
        )
        BEGIN

            SELECT 2 AS StatusCode,
                   'La referencia que intentas procesar pertenece a otro país' AS Description;
        END
        ELSE
        BEGIN

            SELECT 3 AS StatusCode,
                   'No se encontraron guías con la referencia proporcionada' AS Description;
        END

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                'No se pudieron procesar los datos, por favor intente de nuevo o comuníquese con el administrador del sistema. \n' + ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END