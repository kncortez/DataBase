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

    DECLARE @CurrentIncidentID INT, @ServiceID INT;

	SELECT @CurrentIncidentID = IncidentId, @ServiceID = ServiceId
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

	SET @StatusCode = @@ROWCOUNT;

    DECLARE @TOKEN_QAAGENT VARCHAR (200) = NULL;

    SELECT TOP 1 @TOKEN_QAAGENT = TknTokenCreated
    FROM DeliveryBackOffice.dbo.TokenLog WITH (NOLOCK)
    WHERE TknIdUser = @QualityControlAgentId
    --AND TknRowStatus = 1
    ORDER BY TknDateCreated DESC;

	-- UPDATE OK
	-- AND 
	-- SERVICE IS STILL REQUIRED AND WE HAVE A NEW DATE TO COLLECT, LET'S PUT THE PACKAGE BACK IN THE WORKFLOW
    IF @StatusCode > 0 AND ISNULL(@IsStillRequired, 0) = 1 AND @NewDate IS NOT NULL
    BEGIN
        DECLARE @SchedulePickupID INT, @CREATED_ID_CATSERVICESTATUS INT = 1;

        SELECT @SchedulePickupID = IdSchedulePickup
        FROM DeliveryBackOffice.dbo.ServiceManagement WITH(NOLOCK)
        WHERE IdServiceManagement = @ServiceID;

        UPDATE DeliveryBackOffice.dbo.SchedulePickup
        SET StartDate = DATEADD(HOUR, 8, CAST(@NewDate AS DATETIME)), 
        EndDate = DATEADD(HOUR, 20, CAST(@NewDate AS DATETIME)), 
        AssigmentStatus = NULL
        WHERE SchedulePickupId = @SchedulePickupID;

        UPDATE DeliveryBackOffice.dbo.ServiceManagement
        SET IdPuCourrier = NULL,
        IdPuRouteAssigment = NULL,
        ServiceStatusId = @CREATED_ID_CATSERVICESTATUS
        WHERE IdServiceManagement = @ServiceID;

        INSERT INTO DeliveryBackOffice.dbo.EventService
        (ServiceManagementId, ServiceStatusId, RowStauts, TokenCreated, DateCreated)
        VALUES(@ServiceID, @CREATED_ID_CATSERVICESTATUS, 1, @TOKEN_QAAGENT, GETDATE());

        SET @StatusCode = @@ROWCOUNT;
    END
    ELSE IF @StatusCode > 0 AND ISNULL(@IsStillRequired, 0) = 0
    BEGIN
        DECLARE @CANCELED_ID_CATSERVICESTATUS INT = 9;

        UPDATE DeliveryBackOffice.dbo.ServiceManagement
        SET IdPuCourrier = NULL,
        IdPuRouteAssigment = NULL,
        ServiceStatusId = @CANCELED_ID_CATSERVICESTATUS
        WHERE IdServiceManagement = @ServiceID;

        INSERT INTO DeliveryBackOffice.dbo.EventService
        (ServiceManagementId, ServiceStatusId, RowStauts, TokenCreated, DateCreated)
        VALUES(@ServiceID, @CANCELED_ID_CATSERVICESTATUS, 1, @TOKEN_QAAGENT, GETDATE());

        SET @StatusCode = @@ROWCOUNT;
    END

    SELECT @StatusCode AS RowsAffected;

END