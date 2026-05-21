/* =================================================
   SP:        UpdateWorkflowStatuses
   Propósito: Se inserta o actualiza un estatus asociado al flujo de trabajo
   Autor:     Erick Hernandez
   Historia:  FDAPI-5691
   Fecha:     2026-03-06

=== CHANGELOG ============================
2026-04-21 | Historia/épica: FDAPI-6126 | Autor: Erick Hernandez | Se agrega parámetro de código del país
=========================================== */
CREATE PROCEDURE [dbo].[UpdateWorkflowStatuses]
	@WorkflowID BIGINT,
	@StatusOrderIdList NVARCHAR(MAX),
	@Token NVARCHAR(50),
	@RowStatus BIT,
	@CountryId VARCHAR(2) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		DECLARE @StatusIDs TABLE (ID INT);
		DECLARE @RowsAffected INT = 0, @RowStatus_Active INT = 1;
		
		DECLARE @LogBuffer TABLE(
			WorkflowId BIGINT,
			StatusId INT,
			CountryId VARCHAR(2),
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
			@CountryId,
			@RowStatus,
			GETDATE(),
			@Token
		INTO @LogBuffer (WorkflowId, StatusId, CountryId, OperationType, DateCreated, TokenCreated)
		FROM DeliveryBackOffice.dbo.WorkflowStatusMap WSM WITH(NOLOCK)
		INNER JOIN @StatusIDs S
			ON S.ID = WSM.StatusOrderId
		WHERE WSM.WorkflowId = @WorkflowID
		AND WSM.CountryId = @CountryId
		AND WSM.RowStatus <> @RowStatus;

		SET @RowsAffected = @RowsAffected + @@ROWCOUNT;
		
		IF @RowStatus = 1 AND @CountryId IS NOT NULL
		BEGIN
			INSERT INTO DeliveryBackOffice.dbo.WorkflowStatusMap
			(
				WorkflowId,
				StatusOrderId,
				CountryId,
				DateCreated,
				TokenCreated,
				RowStatus
			)
			OUTPUT
				inserted.WorkflowId,
				inserted.StatusOrderId,
				@CountryId,
				@RowStatus_Active,
				GETDATE(),
				@Token
			INTO @LogBuffer (WorkflowId, StatusId, CountryId, OperationType, DateCreated, TokenCreated)
			SELECT
				@WorkflowID,
				S.ID,
				@CountryId,
				GETDATE(),
				@Token,
				1
			FROM @StatusIDs S
			WHERE NOT EXISTS
			(
				SELECT 1
				FROM DeliveryBackOffice.dbo.WorkflowStatusMap WSM
				WHERE WSM.WorkflowId = @WorkflowID
				AND WSM.StatusOrderId = S.ID
				AND WSM.CountryId = @CountryId
			);

			SET @RowsAffected = @RowsAffected + @@ROWCOUNT;
		END
		
		IF @RowsAffected > 0 
		BEGIN
			INSERT INTO dbo.WorkflowStatusMapLog
			(
				WorkflowId,
				StatusOrderId,
				OperationType,
				CountryId,
				DateCreated,
				TokenCreated
			)
			SELECT
				WorkflowId,
				StatusId,
				OperationType,
				CountryId,
				DateCreated,
				TokenCreated
			FROM @LogBuffer;
		END

		SELECT @RowsAffected AS RowsAffected;
	END TRY
	BEGIN CATCH
		SELECT -1 AS RowsAffected;
	END CATCH
END;