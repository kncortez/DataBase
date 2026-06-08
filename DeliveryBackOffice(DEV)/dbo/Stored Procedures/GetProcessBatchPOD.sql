-- =============================================  
-- Author:  <Cristian Suazo  
-- Update date: <2025-02-18>  
-- Description: <Se procesa lote de POD para el servicio>  
-- ============================================= 
-- =============================================  
-- Author:  <Edelman> 
-- Update date: <2025-05-02>  
-- Description: <Obtener guías de contenedores y referencias recolección POD>  
-- ============================================= 
CREATE PROCEDURE [dbo].[GetProcessBatchPOD] 
(
 @IdPickup INT
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        DECLARE @TypeofInOutMoneyId INT = 1,
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
              FROM FinishPickUpHeader WITH (NOLOCK)
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
              FROM FinishPickUpHeader WITH (NOLOCK)
             WHERE SchedulePickupId = @IdPickup
               AND RowStatus = 1

            SELECT @Guides = STRING_AGG(CAST(Guide AS NVARCHAR(MAX)), ',')
              FROM (
                    SELECT (CONCAT(GuideSerie, GuideNumber, '-', GuidePiece)) AS Guide
                      FROM FinishPickUpDetail WITH (NOLOCK)
					   INNER JOIN dbo.DeliveryOrder ord WITH(NOLOCK) ON ord.Guide_Serie = FinishPickUpDetail.GuideSerie AND ord.Guide_Number = FinishPickUpDetail.GuideNumber
                     WHERE SchedulePickupId = @IdPickup AND ord.StatusOrderId NOT IN(7,2,10,19,43,25,5,22)
                     UNION ALL
                    SELECT      
                      (CONCAT(C.GuideSerie, C.GuideNumber, '-', C.NoPiece))
                    FROM   FinishPickUpReferenceDetail A WITH (NOLOCK)
                    INNER JOIN DeliveryOrder B  WITH (NOLOCK)
                    ON A.Reference = B.Ticket_Number
                    INNER JOIN DeliveryOrderPiece C WITH (NOLOCK)
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
                      FROM FinishPickUpContainerDetail A WITH (NOLOCK)
                    INNER JOIN ShippingContainer B WITH (NOLOCK)
                    ON A.Container = B.ReferenceContainer
                    INNER JOIN ShippingContainerDetail C WITH (NOLOCK)
                    ON B.IdContainer = C.IdContainer
                    INNER JOIN DeliveryOrderPiece D WITH (NOLOCK)
                    ON  D.GuideSerie = C.GuideSerie AND
                        D.GuideNumber = C.GuideNumber
                    WHERE SchedulePickupId = @IdPickup
                   ) [Data]

            EXEC [dbo].[SetFinishPickUpBatch] @InGuides = @Guides,
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

			INSERT INTO dbo.RoutePreparationLogError
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