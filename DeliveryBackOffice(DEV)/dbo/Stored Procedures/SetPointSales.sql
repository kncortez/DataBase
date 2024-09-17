-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-09-17>
-- Description:	<Administración de lotes - Agregar un punto de venta a un lote>
-- =============================================

CREATE PROCEDURE [dbo].[SetPointSales]
@IdLote				INT =  -1,
@CodeOfReference	INT = 0,
@Token				NVARCHAR(100) = 'SYS-DEFAULT'
AS
BEGIN
BEGIN TRY
	BEGIN TRANSACTION;

	DECLARE @FlagRelationship INT = NULL;

	SELECT @FlagRelationship = RowStatus 
	FROM DeliveryBackOffice.dbo.InvoiceBatchRelationships WITH (NOLOCK)
	WHERE Id_Lote = @IdLote AND CodeOfReference = @CodeOfReference

	IF (@FlagRelationship IS NULL) --Es nueva relación
	BEGIN

		INSERT INTO [dbo].[InvoiceBatchRelationships]
           ([Id_Lote]
           ,[CodeOfReference]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
		 VALUES
			   (@IdLote
			   ,@CodeOfReference
			   ,1
			   ,@Token
			   ,GETDATE()
			   ,NULL
			   ,NULL)

		SELECT 
			'200' IdResult,
			'Se relacionó el punto de venta con el lote exitosamente.' MessageResult

	END;
	ELSE IF(@FlagRelationship = 0) --Existia una relacion con el Lote inactivo.
	BEGIN

		UPDATE [dbo].[InvoiceBatchRelationships]
		SET RowStatus = 1, TokenUpdated = @Token, DateUpdated = GETDATE()
		WHERE Id_Lote = @IdLote AND CodeOfReference = @CodeOfReference 

		SELECT 
			'201' IdResult,
			'Se volvio a establecer la relación del punto de venta con el lote.' MessageResult

	END;
	ELSE IF(@FlagRelationship = 1) --Existe una relacion con el Lote activo.
	BEGIN

		SELECT 
			'401' IdResult,
			'La relación del punto de venta con el lote ya existe.' MessageResult

	END;

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	-- Manejo de errores con PRINT
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;
