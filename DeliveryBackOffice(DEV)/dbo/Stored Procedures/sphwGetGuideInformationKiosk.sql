-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-11-20>
-- Description:	<Kiosko - Metodo para obtener informacion de guia>
-- =============================================
-- Author:      <Brandon Pedroza>
-- Modified:    <2024-11-21>
-- Description: <Se agrega parametro para busqueda de estacion>
-- =============================================
-- =============================================
-- Author:      <Juan Ramirez > <2025-10-02>
-- Description: <Se ajusta el mensaje de error>
-- =============================================
CREATE PROCEDURE [dbo].[sphwGetGuideInformationKiosk]
    @GuideNumber INT,
    @GuideSerie NVARCHAR(5),
    @IdCountry NVARCHAR(2),
    @CodeOfReference INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION
    BEGIN TRY


        DECLARE @StatusOrderSolicitado AS INT,
                @StatusOrderGenerado AS INT,
                @StatusOrderRecepcionado AS INT,
				@IdStation AS INT;

        SET @StatusOrderSolicitado =
        (
            SELECT StatusOrderId
            FROM StatusOrder WITH (NOLOCK)
            WHERE OrderDescription = 'Solicitado'
        )
        SET @StatusOrderGenerado =
        (
            SELECT StatusOrderId
            FROM StatusOrder WITH (NOLOCK)
            WHERE OrderDescription = 'Generado'
        )

		SET @IdStation = (SELECT TOP 1 IdStation FROM CatStation With(NOLOCK) WHERE CodeOfReference = @CodeOfReference)

        IF NOT EXISTS
        (
            SELECT 1
            FROM DeliveryOrder WITH (NOLOCK)
            WHERE Guide_Serie = @GuideSerie
                  AND Guide_Number = @GuideNumber
                  AND ISNULL(SenderCountryId, 'GT') = @IdCountry
                  AND StatusOrderId IN ( @StatusOrderSolicitado, @StatusOrderGenerado )
        )
        BEGIN
			ROLLBACK TRANSACTION
            SELECT 400 AS 'StatusCode',
                   'La guía escaneada no es válida o no se reconoce. Verifica que el código ' +
                   'de la guía sea el correcto o ingrésalo manualmente. 'AS 'Description'
            RETURN
        END
        COMMIT TRANSACTION

        SELECT 200																AS 'StatusCode',
               'Informacion Obtenida'											AS 'Description',
               DO.Guide_Number													AS 'GuideNumber',
               DO.Guide_Serie													AS 'GuideSerie',
               Pieces_Dry + Pieces_Cold											AS 'Pieces',
               --DE
               CONCAT(DO.Sender_FirstName, ' ', DO.Sender_LastName)				AS 'SenderName',
               ISNULL(dbo.GetPhone(DO.Sender_Phone, 1, DO.SenderCountryId), '') AS 'SenderNirPhone',
               ISNULL(dbo.GetPhone(DO.Sender_Phone, 0, DO.SenderCountryId), '') AS 'SenderPhone',
               ''			AS 'SenderSettlement',
               dbo.CapitalizeFirstLetter(DO.Sender_Town)						AS 'SenderTown',
               dbo.CapitalizeFirstLetter(DO.Sender_Department)					AS 'SenderDepartment',
               --PARA
               CONCAT(DO.Receiver_FirstName, ' ', DO.Receiver_LastName)			AS 'ReceiverName',
               DO.Receiver_Address												AS 'ReceiverAddress',
               dbo.CapitalizeFirstLetter(ISNULL(SD.Settlement, ''))				AS 'ReceiverSettlement',
               dbo.CapitalizeFirstLetter(DO.Receiver_Town)						AS 'ReceiverTownship',
           dbo.CapitalizeFirstLetter(DO.Receiver_Department)				AS 'ReceiverDepartment',
               ISNULL(dbo.GetPhone(DO.Receiver_Phone, 1, DO.ReceiverCountryId), '') AS 'ReceiverNirPhone',
               ISNULL(dbo.GetPhone(DO.Receiver_Phone, 0, DO.ReceiverCountryId), '') AS 'ReceiverPhone'
        FROM DeliveryOrder DO WITH (NOLOCK)
            --LEFT JOIN Settlement SO WITH (NOLOCK)
            --    ON DO.SenderIdSettlement = SO.IdSettlement
            LEFT JOIN Settlement SD WITH (NOLOCK)
                ON DO.ReceiverIdSettlement = SD.IdSettlement
        WHERE DO.Guide_Number = @GuideNumber
              AND DO.Guide_Serie = @GuideSerie
              AND DO.SenderCountryId = @IdCountry
        ORDER BY DO.DateCreated DESC;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SELECT 400 AS 'StatusCode',
               'Error al registrar checkpoint' AS 'Description',
               ERROR_MESSAGE() AS 'ErrorMessage'
    END CATCH
END;