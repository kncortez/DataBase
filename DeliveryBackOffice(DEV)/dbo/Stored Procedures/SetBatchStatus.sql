-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-09-10>
-- Description:	<Administración de lotes - Cambio de estado de lote>
-- =============================================

CREATE PROCEDURE [dbo].[SetBatchStatus]
@IdLote INT,
@Status BIT = NULL,
@Enable BIT = NULL
AS
BEGIN
    BEGIN TRY
	BEGIN TRANSACTION;

	DECLARE @IdResult NVARCHAR(3);
	DECLARE @Message NVARCHAR(100);
	DECLARE @Emision_Point INT;
	DECLARE @Establishment INT;
	DECLARE @TypeDocument INT;
	DECLARE @LastState INT;
	DECLARE @LastEnable INT;
	DECLARE @NameLastState NVARCHAR(20);
	DECLARE @NameStatus NVARCHAR(20);

	--Obtener info del lote
	SELECT @Emision_Point = Emision_Point, 
		   @Establishment = Establishment, 
		   @TypeDocument = TypeDocument,
		   @LastState = Status,
		   @LastEnable = Enable
	FROM DeliveryBackOffice.dbo.InvoiceBatchHeader WITH(NOLOCK)
	WHERE Id_Lote = @IdLote

	--Nombre del último estado
	SET @NameLastState = CASE 
                    WHEN @LastEnable = 0 THEN 'detenido'
                    WHEN @LastState = 1 THEN 'activo'
                    ELSE 'inactivo'
                 END;


	IF (@Status = 1) --ACTIVO
	BEGIN
		--Existe otro activo
		IF NOT EXISTS (SELECT 1 FROM DeliveryBackOffice.dbo.InvoiceBatchHeader WITH(NOLOCK)
		WHERE Emision_Point = @Emision_Point AND Establishment = @Establishment
				AND TypeDocument = @TypeDocument AND Id_Lote != @IdLote AND [Status] = 1 AND [Enable] = 1)
		BEGIN
			UPDATE DeliveryBackOffice.dbo.InvoiceBatchHeader
			SET [Status] = @Status, [Enable] = 1
			WHERE Id_Lote = @IdLote

			SET @IdResult = '200';
			SET @Message = 'El lote ha cambiado de estado de ' + @NameLastState
			+ ' a  activo exitosamente.';
		END;
		ELSE
		BEGIN
			SET @IdResult = '409';
			SET @Message = 'Ya existe un lote activo.';
		END;
	END;
	ELSE IF (@Status = 0) --INACTIVO
	BEGIN
		--No hay restricción
		UPDATE DeliveryBackOffice.dbo.InvoiceBatchHeader
		SET [Status] = @Status, [Enable] = 1
		WHERE Id_Lote = @IdLote

		SET @IdResult = '200';
		SET @Message = 'El lote ha cambiado de estado de ' + @NameLastState
			+ ' a inactivo exitosamente.';
	END;
	ELSE IF (@Enable = 0) --DETENIDO
	BEGIN
		--No hay restricción
		UPDATE DeliveryBackOffice.dbo.InvoiceBatchHeader
		SET [Status] = 0, [Enable] = 0
		WHERE Id_Lote = @IdLote

		SET @IdResult = '200';
		SET @Message = 'El lote ha cambiado de estado de ' + @NameLastState
			+ ' a detenido exitosamente.';
	END;

	SELECT 
		@IdResult AS 'IdResult',
		@Message AS 'MessageResult'

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
