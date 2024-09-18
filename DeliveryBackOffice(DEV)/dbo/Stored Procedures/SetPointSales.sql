-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-09-17>
-- Description:	<Administración de lotes - Agregar/Eliminar un punto de venta a un lote>
-- =============================================

CREATE PROCEDURE [dbo].[SetPointSales]
@IdLote				INT =  -1,
@CodeOfReference	INT = 0,
@Token				NVARCHAR(100) = 'SYS-DEFAULT',
@Action				INT = 0 --0 ELIMINAR, 1 AGREGAR
AS
BEGIN
BEGIN TRY
	BEGIN TRANSACTION;

	DECLARE @FlagRelationship INT = NULL;

	SELECT @FlagRelationship = RowStatus 
	FROM DeliveryBackOffice.dbo.InvoiceBatchRelationships WITH (NOLOCK)
	WHERE Id_Lote = @IdLote AND CodeOfReference = @CodeOfReference

	IF(@Action = 1) --FLUJO PARA AGREGAR RELACION ENTRE PUNTO DE VISITA Y LOTE
	BEGIN

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
				'' MessageResult

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
	END;
	ELSE IF(@Action = 0) --FLUJO PARA ELIMINAR RELACION ENTRE PUNTO DE VISITA Y LOTE
	BEGIN
		IF(@FlagRelationship IS NULL) --No existe la relacion que desea eliminar
		BEGIN
			SELECT 
				'402' IdResult,
				'La relación que desea eliminar es incorrecta.' MessageResult
		END;
		ELSE IF(@FlagRelationship = 1) --Eliminar registro
		BEGIN
			UPDATE [dbo].[InvoiceBatchRelationships]
			SET RowStatus = 0, TokenUpdated = @Token, DateUpdated = GETDATE()
			WHERE Id_Lote = @IdLote AND CodeOfReference = @CodeOfReference

			SELECT 
				'202' IdResult,
				'Se elimino correctamente el punto de venta del lote.' MessageResult
		END;
		ELSE--0
		BEGIN
			SELECT 
				'203' IdResult,
				'La relación ya se encontraba eliminada.' MessageResult
		END;
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
