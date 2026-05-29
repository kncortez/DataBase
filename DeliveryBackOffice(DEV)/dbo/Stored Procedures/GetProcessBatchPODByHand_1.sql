/* =================================================
   SP:        [dbo].[GetProcessBatchPODByHand]
   Propósito: <Se procesa lote de POD para el servicio recolección Manual.>
   Autor:     Caleb Loarca
   Historia:  <FDAPI-5681>
   Fecha:     <2026-03-30>
   === CHANGELOG ============================
2026-03-30 | Historia/épica: <FDAPI-5681> | Autor: Caleb Loarca | Se usa de base SP GetProcessBatchPOD, para modificar y consumir en recolecciones manuales
=========================================== */
                       
CREATE PROCEDURE [dbo].[GetProcessBatchPODByHand]
(
 @IdPickup INT
)
AS
BEGIN
PRINT @IdPickup
    BEGIN TRY
        BEGIN TRANSACTION
        DECLARE 
				@TypeofInOutMoneyId INT = 1,
                @Token NVARCHAR(300) = NULL,
                @Observations NVARCHAR(200) = NULL,
                @Amount DECIMAL(12, 2) = 0,
                @Voucher NVARCHAR(200) = ' ',
                @PuSignaturePath NVARCHAR(250) = ' ',
                @StartDate DATETIME = NULL,
                @EndDate DATETIME = NULL,
                @PickupLatitude NVARCHAR(20) = NULL,
                @PickupLongitude NVARCHAR(20) = NULL,
                @PickUpEmail NVARCHAR(200),
                @Guides NVARCHAR(MAX)

        IF EXISTS
        (
            SELECT TOP 1 1
              FROM DeliveryBackOffice.dbo.FinishPickUpHeader WITH (NOLOCK)
             WHERE SchedulePickupId = @IdPickup
               AND RowStatus = 1
        )
        BEGIN
            SELECT @TypeofInOutMoneyId = TypeofInOutMoneyId,
                   @Token = TokenCreated,
                   @Observations = ISNULL(Observation, ' '),
                   @Amount = Amount,
                   @Voucher = ISNULL(Voucher, ' '),
                   @PuSignaturePath = [Signature],
                   @StartDate = StartDate,
                   @EndDate = EndDate,
                   @PickUpEmail = PickupEmail,				   
                   @PickupLatitude = PickupLatitude,
                   @PickupLongitude = PickupLongitude
              FROM DeliveryBackOffice.dbo.FinishPickUpHeader WITH (NOLOCK)
             WHERE SchedulePickupId = @IdPickup
               AND RowStatus = 1

            SELECT @Guides = STRING_AGG(CAST(Guide AS NVARCHAR(MAX)), ',')
              FROM (
                    SELECT (CONCAT(GuideSerie, GuideNumber, '-', GuidePiece)) AS Guide
                      FROM DeliveryBackOffice.dbo.FinishPickUpDetail WITH (NOLOCK)
                     WHERE SchedulePickupId = @IdPickup
                     UNION ALL
                    SELECT      
                      (CONCAT(C.GuideSerie, C.GuideNumber, '-', C.NoPiece))
                    FROM   DeliveryBackOffice.dbo.FinishPickUpReferenceDetail A WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder B  WITH (NOLOCK)
                    ON A.Reference = B.Ticket_Number
                    INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece C WITH (NOLOCK)
                    ON  B.Guide_Serie = C.GuideSerie AND
                      B.Guide_Number = C.GuideNumber
                    WHERE SchedulePickupId = @IdPickup
                    AND B.StatusOrderId <> 7 --Quitar guías anuladas
                    AND NOT EXISTS(
                     SELECT 1 FROM DeliveryBackOffice.dbo.DeliveryOrderDetail A1 WITH(NOLOCK)
                     WHERE A1.Guide_Serie = B.Guide_Serie
                     AND  A1.Guide_Number = B.Guide_Number
                     AND A1.StatusOrderId = 2 --No volver a marcar como recolectada una guía
                     )

                    UNION ALL
                    SELECT 
                    (CONCAT(D.GuideSerie, D.GuideNumber, '-', D.NoPiece))
                      FROM DeliveryBackOffice.dbo.FinishPickUpContainerDetail A WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.ShippingContainer B WITH (NOLOCK)
                    ON A.Container = B.ReferenceContainer
                    INNER JOIN DeliveryBackOffice.dbo.ShippingContainerDetail C WITH (NOLOCK)
                    ON B.IdContainer = C.IdContainer
                    INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece D WITH (NOLOCK)
                    ON  D.GuideSerie = C.GuideSerie AND
                        D.GuideNumber = C.GuideNumber
                    WHERE SchedulePickupId = @IdPickup
                   ) [Data]


            EXEC [dbo].[SetFinishPickUpBatchByHand] @InGuides = @Guides,
                                              @IdPickup = @IdPickup,
                                              @TypeofInOutMoneyId = @TypeofInOutMoneyId,
                                              @Token = @Token,
                                              @Observations = @Observations,
                                              @Amount = @Amount,
                                              @Voucher = @Voucher,
                                              @PuSignaturePath = @PuSignaturePath,
                                              @StartDate = @StartDate,
                                              @EndDate = @EndDate,
                                              @PickupLatitude = @PickupLatitude,
                                              @PickupLongitude = @PickupLongitude,
                                              @PickUpEmail = @PickUpEmail
        END
        ELSE
        BEGIN
            SELECT 0 AS StatusCode,
                   'No se encontro la recoleccion en los lotes' AS [Message],
                   '' Token,
                   '' Email
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SELECT 0 AS StatusCode,
               ERROR_MESSAGE() AS [Message],
               '' Token,
               '' Email

            ROLLBACK TRANSACTION;

			INSERT INTO DeliveryBackOffice.dbo.RoutePreparationLogError
			(
			    ErrorDescription,
			    ErrorNumber,
			    ErrorProcedure,
			    ErrorLine,
			    GuideSerie,
			    GuideNumber,
			    TokenCreated,
			    DateCreated
			)
			VALUES
			(   ERROR_MESSAGE(),     -- ErrorDescription - varchar(300)
			    ERROR_NUMBER(),     -- ErrorNumber - int
			    ERROR_PROCEDURE(),     -- ErrorProcedure - varchar(100)
			    ERROR_LINE(),     -- ErrorLine - int
			    NULL,     -- GuideSerie - nvarchar(2)
			    NULL,     -- GuideNumber - int
			    '',       -- TokenCreated - varchar(50)
			    GETDATE() -- DateCreated - datetime
			    )
    END CATCH



END