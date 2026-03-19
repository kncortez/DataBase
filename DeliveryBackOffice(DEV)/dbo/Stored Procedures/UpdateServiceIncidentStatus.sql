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

    DECLARE @RowsAffected INT = 0;

    IF @IncidentStatusId = @PendingStatusId
    BEGIN
        UPDATE DeliveryBackOffice.dbo.ServiceIncident
        SET 
            IncidentStatusId = @PendingStatusId,
            CurrentAgentId = NULL,
            AssignedAt = NULL
        WHERE ServiceIncidentId = @ServiceIncidentId
        AND RowStatus = 1;

        SET @RowsAffected = @@ROWCOUNT;
    END
    ELSE IF @IncidentStatusId = @InProgressStatusID
    BEGIN
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
            );

        SET @RowsAffected = @@ROWCOUNT;
    END
    ELSE IF @IncidentStatusId = @ResolvedStatusID
    BEGIN
        UPDATE DeliveryBackOffice.dbo.ServiceIncident
        SET 
            IncidentStatusId = @ResolvedStatusID,
            CompletedAt = GETDATE()
        WHERE ServiceIncidentId = @ServiceIncidentId
        AND RowStatus = 1
        AND IncidentStatusId = @InProgressStatusID
        AND CurrentAgentId = @QualityControlAgentId;

        SET @RowsAffected = @@ROWCOUNT;
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

        SET @RowsAffected = @@ROWCOUNT;
    END

    SELECT @RowsAffected AS IsSuccess, '999' AS AgentID;
END
