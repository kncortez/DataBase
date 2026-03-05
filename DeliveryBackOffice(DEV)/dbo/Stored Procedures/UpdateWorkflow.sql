/* =================================================
   SP:        UpdateWorkflow
   Propósito: Se actualiza un flujo de trabajo
   Autor:     Erick Hernandez
   Historia:  ---
   Fecha:     2026-03-04

=== CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[UpdateWorkflow]
	@WorkflowID BIGINT,
	@Name NVARCHAR(50),
	@Token NVARCHAR(50),
	@RowStatus BIT = 1
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		UPDATE DeliveryBackOffice.dbo.Workflow
		SET
			Name = @Name,
			DateUpdated = GETDATE(),
			TokenUpdated = @Token,
			RowStatus = @RowStatus
		WHERE WorkflowId = @WorkflowID;
		
		SELECT @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		IF ERROR_NUMBER() IN (2601,2627)
            SELECT 0;   -- duplicate name
        ELSE
            SELECT -1;  -- unexpected error
	END CATCH
END;
