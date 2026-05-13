/* =================================================
   SP:        UpdateWorkflowStatuses
   Propósito: Se inserta o actualiza un estatus asociado al flujo de trabajo
   Autor:     Erick Hernandez
   Historia:  FDAPI-5691
   Fecha:     2026-03-06

=== CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[UpdateWorkflowStatuses]
	@WorkflowID BIGINT,
	@StatusOrderIdList NVARCHAR(MAX),
	@Token NVARCHAR(50),
	@RowStatus BIT
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		DECLARE @StatusIDs TABLE (ID INT);
		DECLARE @RowsAffected INT = 0;
		
		DECLARE @LogBuffer TABLE(
			WorkflowId BIGINT,
			StatusId INT,
			OperationType BIT,
			DateCreated DATETIME,
			TokenCreated NVARCHAR(50)
		);

		INSERT INTO @StatusIDs (ID)
		SELECT DISTINCT CAST(Item AS INT)
		FROM DeliveryBackOffice.dbo.SplitUnlimited(@StatusOrderIdList, ',');

		UPDATE WSM
		SET 
			RowStatus = @RowStatus,
			DateUpdated = GETDATE(),
			TokenUpdated = @Token
		OUTPUT
			inserted.WorkflowId,
			inserted.StatusOrderId,
			@RowStatus,
			GETDATE(),
			@Token
		INTO @LogBuffer (WorkflowId, StatusId, OperationType, DateCreated, TokenCreated)
		FROM DeliveryBackOffice.dbo.WorkflowStatusMap WSM WITH (NOLOCK)
		INNER JOIN @StatusIDs S
			ON S.ID = WSM.StatusOrderId
		WHERE WSM.WorkflowId = @WorkflowID
		AND WSM.RowStatus <> @RowStatus;

		SET @RowsAffected = @RowsAffected + @@ROWCOUNT;
		
		IF @RowStatus = 1
		BEGIN
			INSERT INTO DeliveryBackOffice.dbo.WorkflowStatusMap
			(
				WorkflowId,
				StatusOrderId,
				DateCreated,
				TokenCreated,
				RowStatus
			)
			OUTPUT
				inserted.WorkflowId,
				inserted.StatusOrderId,
				1,
				GETDATE(),
				@Token
			INTO @LogBuffer (WorkflowId, StatusId, OperationType, DateCreated, TokenCreated)
			SELECT
				@WorkflowID,
				S.ID,
				GETDATE(),
				@Token,
				1
			FROM @StatusIDs S
			WHERE NOT EXISTS
			(
				SELECT 1
				FROM DeliveryBackOffice.dbo.WorkflowStatusMap WSM WITH (NOLOCK)
				WHERE WSM.WorkflowId = @WorkflowID
				AND WSM.StatusOrderId = S.ID
			);

			SET @RowsAffected = @RowsAffected + @@ROWCOUNT;
		END
		
		INSERT INTO dbo.WorkflowStatusMapLog
		(
			WorkflowId,
			StatusOrderId,
			OperationType,
			DateCreated,
			TokenCreated
		)
		SELECT
			WorkflowId,
			StatusId,
			OperationType,
			DateCreated,
			TokenCreated
		FROM @LogBuffer;
		
		SELECT @RowsAffected AS RowsAffected;
	END TRY
	BEGIN CATCH
		SELECT -1 AS RowsAffected;
	END CATCH
END;