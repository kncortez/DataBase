/* =================================================
   SP:        UpdateServiceIncidentStatus
   Propósito: Se verifica y actualiza el estado del incidente del servicio
   Autor:     Erick Hernandez
   Historia:  FDAPI-5922
   Fecha:     2026-03-18

=== CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[UpdateServiceIncidentStatus]
    @ServiceIncidentId INT,
    @IncidentStatusId INT,
    @QualityControlAgentId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @PendingStatusId INT = 1,
        @InProgressStatusID INT = 2,
        @ResolvedStatusID INT = 3;

    DECLARE @StatusCode INT = 0;

    IF @IncidentStatusId = @PendingStatusId
    BEGIN
        UPDATE DeliveryBackOffice.dbo.ServiceIncident
        SET 
            IncidentStatusId = @PendingStatusId,
            CurrentAgentId = NULL,
            AssignedAt = NULL
        WHERE ServiceIncidentId = @ServiceIncidentId
        AND IncidentStatusId = @InProgressStatusID
        AND RowStatus = 1;

        SET @StatusCode = @@ROWCOUNT;
    END
    ELSE IF @IncidentStatusId = @InProgressStatusID
    BEGIN
        -- Check the current state of the incident BEFORE updating
		DECLARE @CurrentStatusId   INT;
		DECLARE @CurrentAgentId    INT;
		DECLARE @CurrentRowStatus  TINYINT;

		SELECT 
			@CurrentStatusId  = IncidentStatusId,
			@CurrentAgentId   = CurrentAgentId,
			@CurrentRowStatus = RowStatus
		FROM DeliveryBackOffice.dbo.ServiceIncident
		WHERE ServiceIncidentId = @ServiceIncidentId;
        
        UPDATE DeliveryBackOffice.dbo.ServiceIncident
        SET 
            IncidentStatusId = @InProgressStatusID,
            CurrentAgentId = @QualityControlAgentId,
            AssignedAt = 
                CASE 
                    WHEN IncidentStatusId = @InProgressStatusID 
                         AND CurrentAgentId = @QualityControlAgentId 
                    THEN AssignedAt   -- keep original time
                    ELSE GETDATE()
                END
        WHERE ServiceIncidentId = @ServiceIncidentId
        AND RowStatus = 1
        AND (
                IncidentStatusId = @PendingStatusId
                OR (
                    IncidentStatusId = @InProgressStatusID 
                    AND CurrentAgentId = @QualityControlAgentId
                )
				OR (    --10 min window to work on that incident for any agent 
                    IncidentStatusId = @InProgressStatusID 
                    AND DATEADD(MINUTE, 10, AssignedAt) < GETDATE()
                )
            );

        -- Diagnose why nothing was updated
		IF @@ROWCOUNT = 0
		BEGIN
            IF @CurrentStatusId  = @InProgressStatusID 
				 AND @CurrentAgentId <> @QualityControlAgentId
				SET @StatusCode = -1;
			ELSE IF @CurrentRowStatus <> 1
                SET @StatusCode = -2;
			ELSE 
                SET @StatusCode = -3;
		END
		ELSE
        BEGIN
            SET @StatusCode = 1;
        END
    END
    ELSE IF @IncidentStatusId = @ResolvedStatusID
    BEGIN
        UPDATE DeliveryBackOffice.dbo.ServiceIncident
        SET 
            IncidentStatusId = @ResolvedStatusID,
			CurrentAgentId = @QualityControlAgentId,
            CompletedAt = GETDATE()
        WHERE ServiceIncidentId = @ServiceIncidentId
        AND RowStatus = 1
        AND IncidentStatusId = @InProgressStatusID;

        SET @StatusCode = @@ROWCOUNT;
    END
    ELSE
    BEGIN
        UPDATE DeliveryBackOffice.dbo.ServiceIncident
        SET 
            IncidentStatusId = @IncidentStatusId,
            CompletedAt = GETDATE()
        WHERE ServiceIncidentId = @ServiceIncidentId
        AND RowStatus = 1
		AND IncidentStatusId = @InProgressStatusID;

        SET @StatusCode = @@ROWCOUNT;
    END

    RETURN @StatusCode;
END