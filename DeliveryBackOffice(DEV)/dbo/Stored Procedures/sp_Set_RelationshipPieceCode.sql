
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-03-07>
-- Description:	<Relacionar guías y piezas de Forza con guías y piezas externas>
-- =============================================

CREATE PROCEDURE [dbo].[sp_Set_RelationshipPieceCode]
    @AccountId BIGINT,
    @Token NVARCHAR(100),
    @GuideSerie NVARCHAR(4),
    @GuideNumber INT,
    @NoPiece INT,
    @GuideExternal NVARCHAR(300),
    @PieceExternal NVARCHAR(100)
AS
BEGIN
	DECLARE @pCountPieces INT;
	DECLARE @pError INT;

	BEGIN TRY

		-- Obtener la cantidad de piezas de esa guia
		SELECT @pCountPieces = COALESCE(Pieces_Dry,0) + COALESCE(Pieces_Cold,0)  FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] WITH(NOLOCK) 
		WHERE ([StatusOrderId] = 1 OR [StatusOrderId] = 15) AND [Guide_Number] = @GuideNumber AND [Guide_Serie] = @GuideSerie

		-- consultar si la guia externa no esta asignada en otro lado (se podria utilizar indice, se agrega status order?)
		IF NOT EXISTS (SELECT 1 FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] WITH(NOLOCK) WHERE [Ticket_Number] = @GuideExternal 
						AND [Guide_Number] != @GuideNumber)
			BEGIN
				-- Consultar si la pieza externa no esta asignada en otro lado (se podria utilizar indice, se agrega status order?)
				IF NOT EXISTS (SELECT 1 FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] WITH(NOLOCK) WHERE [ExternalPieceId] = @PieceExternal)
				BEGIN
					-- Consultar si la guia esta en estado 1 o 15
					IF (@pCountPieces IS NOT NULL)
					BEGIN
						BEGIN TRANSACTION;

						-- Realizar el insert para la guia Externa con Forza
							UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder]
							SET [Ticket_Number] = @GuideExternal
							WHERE [Guide_Number] = @GuideNumber
							AND [Guide_Serie] = @GuideSerie

						-- Realizar el insert para la pieza Externa con Forza
							UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece]
							SET [ExternalPieceId] = @PieceExternal
							, [TokenRegistrationExternalCode] = @Token
							, [DateRegistrationExternalCode] = GETDATE()
							, [AccountIdRegistrationExternalCode] = @AccountId
							WHERE [GuideNumber] = @GuideNumber
							AND [GuideSerie] = @GuideSerie AND [NoPiece] = @NoPiece

						-- Verificar si la actualización fue exitosa
						IF @@ROWCOUNT > 0
						BEGIN
							COMMIT;
						END;
						ELSE
						BEGIN
							ROLLBACK;
							SET @pError = 1--'Error: La transacción fue revertida debido a un fallo en la actualización.'
						END;
					END;
					ELSE
					BEGIN
						SET @pError = 2--'Error: La guia no se encuentra en un estado de aceptación.'
					END;
				END;
				ELSE
				BEGIN
					SET @pError = 3--'Error: La pieza ya se encuentra asociada a otra.'
				END;
			END;
		ELSE
		BEGIN
			SET @pError = 4 --'Error: La guia ya se encuentra asociada a otra.'
		END;

		IF(@pError IS NULL)		
		BEGIN
			SELECT
				CONCAT(@GuideSerie, @GuideNumber) AS 'GuideForza',
				@GuideExternal AS 'GuideDHL',
				CAST(@pCountPieces AS NVARCHAR(10)) AS 'CountPieces'
		END
		ELSE
		BEGIN
			SELECT
					@pError AS 'GuideForza',
					0 AS 'GuideDHL',
					0 AS 'CountPieces'
		END
	END TRY
	BEGIN CATCH
		SELECT
				5 AS 'GuideForza',
				ERROR_MESSAGE() AS 'GuideDHL',
				0 AS 'CountPieces'
	END CATCH;
END
