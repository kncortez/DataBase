-- =============================================
-- Author:	 <Critian Suazo>
-- Modified: <2025-01-22>
-- Description:	<Varifica todas la guias que estan en estado entregado y que no han sido enviado pro WhatsApp>
-- =============================================
CREATE PROCEDURE [dbo].[GetDeliveryMade]
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        DECLARE @Table TABLE
        (
            ReceiverPhone NVARCHAR(15),
            ReceiverName NVARCHAR(50),
            SenderName NVARCHAR(50),
            DescriptionAmount NVARCHAR(300),
            Courier NVARCHAR(50),
            Vehicle NVARCHAR(50),
            Plate NVARCHAR(50),
            GuideSerie NVARCHAR(2),
            GuideNumber INT,
			IdCountry NVARCHAR(2)
        )

        DECLARE @StatusDelivered INT = (
                                           SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription = 'Entregado'
                                       )

        DECLARE @TopBatchId BIGINT = 0
        SELECT @TopBatchId = isnull(MAX(Sent_Batch_Id), 0) + 1
        FROM DeliveryBackOffice.dbo.SMS_Sent WITH (NOLOCK)


        INSERT INTO @Table
        (
            ReceiverPhone,
            ReceiverName,
            SenderName,
            DescriptionAmount,
            Courier,
            Vehicle,
            Plate,
            GuideSerie,
            GuideNumber,
			IdCountry
        )
        SELECT DISTINCT
            REPLACE(
                       REPLACE(
                                  REPLACE(
                                             REPLACE(
                                                        REPLACE(
                                                                   REPLACE(LTRIM(RTRIM(DO.Receiver_Phone)), '''', ';'),
                                                                   '"',
                                                                   ';'
                                                               ),
                                                        ' ',
                                                        ';'
                                                    ),
                                             '/',
                                             ';'
                                         ),
                                  ',',
                                  ';'
                              ),
                       '-',
                       (CASE
                            WHEN CHARINDEX('-', LTRIM(RTRIM(DO.Receiver_Phone))) > 8 THEN
                                ';'
                            ELSE
                                ''
                        END
                       )
                   ) '_Phone',
            CONCAT(DO.Receiver_FirstName, DO.Receiver_LastName) AS ReceiverName,
            CONCAT(DO.Sender_FirstName, DO.Sender_LastName) AS SenderName,
            CASE
                WHEN DO.IsCollect = 1
                     AND DO.TypeService = 'COD' THEN
                    CONCAT(
                              'Debes Cancelar el Monto ',
                              DO.Collect_OnDelivery,
                              CCU.Symbol,
                              ' al recibir tu paquete o hacer una transferencia a la Cta.',
                              DBK.DCBA_Num_account,
                              'de ',
                              DB.Name,
                              '  a nombre de Delivery Express S.A.'
                          )
                WHEN DO.IsCollect = 1 THEN
                    CONCAT(
                              'Debes cancelar el Monto ',
                              DO.PriceShippment,
                              CCU.Symbol,
                              ' al recibir tu paquete o en la opción de pagar envío.'
                          )
            END AS DescriptionAmount,
            CONCAT(SR.First_Name, SR.Last_Name) AS Courier,
            CTV.Name AS Vehicle,
            CVE.Plate,
            DOD.Guide_Serie,
            DOD.Guide_Number,
			DO.ReceiverCountryId
        FROM DeliveryOrder DO WITH (NOLOCK)
            INNER JOIN DeliveryOrderDetail DOD WITH (NOLOCK)
                ON DO.Guide_Number = DOD.Guide_Number
                   AND DO.Guide_Serie = DOD.Guide_Serie
            INNER JOIN DeliverySettlementDetail DOS WITH (NOLOCK)
                ON DOS.Guide_Number = DO.Guide_Number
                   AND DOS.Guide_Serie = DO.Guide_Serie
            INNER JOIN DeliveryOrderBySettlement DOBS WITH (NOLOCK)
                ON DOS.ID_DeliveryOrderBySettlement = DOBS.ID
            INNER JOIN CatVehicle CVE WITH (NOLOCK)
                ON DOBS.CatVehicleId = CVE.IdVehicle
            INNER JOIN CatTypeVehicle CTV WITH (NOLOCK)
                ON CVE.IdTypeVehicle = CTV.IdTypeVehicle
            INNER JOIN SenderReceiver SR WITH (NOLOCK)
                ON SR.ID = DOBS.ID_Courier
            INNER JOIN DeliveryCurrency DC WITH (NOLOCK)
                ON DO.SenderCountryId = DC.Currency_IdCountry
            INNER JOIN CatCurrencyCOD CCU WITH (NOLOCK)
                ON CCU.IdCatCurrencyCOD = DC.IdCurrencyCOD
            LEFT JOIN DeliveryCustomerBankAccount DBK WITH (NOLOCK)
                ON DO.DCBA_ID = DBK.DCBA_ID
            LEFT JOIN DeliveryBank DB WITH (NOLOCK)
                ON DBK.DCBA_Bank_Id = DB.Id_bank
        WHERE DOD.StatusOrderId = @StatusDelivered
              AND CAST(DOD.DateCreatedInSystem AS DATE) <= CAST(GETDATE() AS DATE)
              AND CAST(DOD.DateCreatedInSystem AS DATE) >= CAST('2025-01-20' as date)
              AND DOS.StatusOrderId = @StatusDelivered
              AND DC.DefaultPerCountry = 1
              AND NOT EXISTS
        (
            SELECT TOP 1
                1
            FROM SMS_Sent SM WITH (NOLOCK)
            WHERE DOD.Guide_Number = SM.Sent_Guide_Number
                  AND DOD.Guide_Serie = SM.Sent_Guide_Series
                  AND SM.StatusOrderId = @StatusDelivered
        )
        ORDER BY DOD.Guide_Number DESC

        SELECT ReceiverPhone,
               ReceiverName,
               SenderName,
               DescriptionAmount,
               Courier,
               Vehicle,
               Plate,
               GuideSerie,
               GuideNumber,
			   IdCountry
        FROM @Table


        INSERT INTO SMS_Sent
        (
            Sent_Guide_Series,
            Sent_Guide_Number,
            Sent,
            Sent_Batch_Id,
            RowStatus,
            TokenCreated,
            CreatedDatetime,
            StatusOrderId
        )
        SELECT GuideSerie,
               GuideNumber,
               1,
               @TopBatchId,
               1,
               'GetDeliveryMade',
               GETDATE(),
               @StatusDelivered
        FROM @Table

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT ERROR_MESSAGE() AS Error,
               ERROR_LINE() AS ErrorLine
    END CATCH
END