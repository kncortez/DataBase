-- =============================================  
-- Author:  <Cristian Suazo  
-- Update date: <2025-02-18>  
-- Description: <Se procesa lote de POD para el servicio>  
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
    END CATCH
END