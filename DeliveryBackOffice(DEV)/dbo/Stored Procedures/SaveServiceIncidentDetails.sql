/* =================================================
   SP:        SaveServiceIncidentDetails
   Propósito: Guarda los detalles pendientes del incidente del servicio
   Autor:     Erick Hernandez
   Historia:  FDAPI-5700
   Fecha:     2026-03-23

=== CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[SaveServiceIncidentDetails]
    @ServiceIncidentId INT,
    @ReclassifiedIncidentId INT = NULL,
    @Notes NVARCHAR(500) = NULL,
    @IsConfirmed BIT = NULL,
    @IsStillRequired BIT = NULL,
    @IsPhotoVerified BIT = NULL,
    @IsLocationVerified BIT = NULL,
    @NewDate DATE = NULL,
    @QualityControlAgentId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentIncidentID INT;

    SELECT @CurrentIncidentID = IncidentId
    FROM DeliveryBackOffice.dbo.ServiceIncident WITH(NOLOCK)
    WHERE ServiceIncidentId = @ServiceIncidentId;

    DECLARE @ResolvedStatusID INT = 3;
    DECLARE @StatusCode INT;

    EXEC @StatusCode = dbo.UpdateServiceIncidentStatus @ServiceIncidentId, @ResolvedStatusID, @QualityControlAgentId;
    IF @StatusCode <> 1
    BEGIN
        SELECT @StatusCode AS RowsAffected;
        RETURN;
    END

    UPDATE DeliveryBackOffice.dbo.ServiceIncident
    SET
        ReclassificationNotes = CASE
            WHEN @ReclassifiedIncidentId IS NOT NULL 
                AND @ReclassifiedIncidentId <> @CurrentIncidentID
            THEN ISNULL(@Notes, ReclassificationNotes)
            ELSE ReclassificationNotes
        END,
        ReclassifiedIncidentId = CASE
            WHEN @ReclassifiedIncidentId IS NOT NULL 
                AND @ReclassifiedIncidentId <> @CurrentIncidentID
            THEN @ReclassifiedIncidentId
            ELSE ReclassifiedIncidentId
        END,
        IncidentConfirmed = ISNULL(@IsConfirmed, IncidentConfirmed),
        ServiceStillRequired = ISNULL(@IsStillRequired, ServiceStillRequired),
        IsPhotoVerified = ISNULL(@IsPhotoVerified, IsPhotoVerified),
        IsLocationVerified = ISNULL(@IsLocationVerified, IsLocationVerified),
        RescheduleCollectDate = CASE 
            WHEN @IsStillRequired = 1 THEN ISNULL(@NewDate, RescheduleCollectDate)
            WHEN @IsStillRequired = 0 THEN NULL
            ELSE RescheduleCollectDate
        END
    WHERE ServiceIncidentId = @ServiceIncidentId
    AND RowStatus = 1;

    SELECT @@ROWCOUNT AS RowsAffected;
END