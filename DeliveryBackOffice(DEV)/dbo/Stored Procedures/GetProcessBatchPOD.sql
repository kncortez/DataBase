-- =============================================  
-- Author:  <Cristian Suazo  
-- Update date: <2025-02-18>  
-- Description: <Se procesa lote de POD para el servicio>  
-- ============================================= 
CREATE PROCEDURE [dbo].[GetProcessBatchPOD] 
				@IdPickup INT = 1250129
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
				@PickUpEmail NVARCHAR(200)

        DECLARE @Guides NVARCHAR(MAX),
                @BatchStatus INT

        SET @BatchStatus =
        (
            SELECT IdServiceStatus
            FROM CatServiceStatus WITH (NOLOCK)
            WHERE Name = 'Recolectado'
        )

        IF EXISTS
        (
            SELECT TOP 1
                1
            FROM FinishPickUpHeader WITH (NOLOCK)
            WHERE SchedulePickupId = @IdPickup
        )
        BEGIN
            SELECT @TypeofInOutMoneyId = TypeofInOutMoneyId,
                   @Token = TokenCreated,
                   @Observations = ISNULL(Observation, ' '),
                   @Amount = Amount,
                   @Voucher = ISNULL(Voucher, ' '),
                   @PuSignaturePath = Signature,
                   @StartDate = StartDate,
                   @EndDate = EndDate,
				   @PickUpEmail = PickupEmail,
                   @PickupLatitude = PickupLatitude,
                   @PickupLongitude = PickupLongitude
            FROM FinishPickUpHeader WITH (NOLOCK)
            WHERE SchedulePickupId = @IdPickup


            SELECT @Guides = STRING_AGG(Guide, ',')
            FROM
            (
                SELECT (CONCAT(GuideSerie, GuideNumber, '-', GuidePiece)) AS Guide
                FROM FinishPickUpDetail WITH (NOLOCK)
                WHERE SchedulePickupId = @IdPickup
            ) [Data]

			SELECT 200 AS StatusCode,
                   'Se procesaron las guías con exito' AS Message,
				   @Token AS Token,
				   @PickUpEmail AS Email

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
                                         @PickupLongitude = @PickupLongitude

            UPDATE FinishPickUpHeader
            SET ServiceStatusId = @BatchStatus,
                TokenUpdated = 'SYS-GetProcessBatchPOD',
                DateUpdated = GETDATE()
            WHERE SchedulePickupId = @IdPickup
        END
        ELSE
        BEGIN
            SELECT 0 AS StatusCode,
                   'No se encontro la recoleccion en los lotes' AS Message
        END

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 0 AS StatusCode,
               ERROR_MESSAGE() AS Description,
               ERROR_LINE() AS ErrorLine
    END CATCH
END