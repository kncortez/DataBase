
-- =============================================
-- Author:		<Andrés,Ruíz>
-- Create date: <2021-12-15>
-- Description:	< Asigna en el detalle de pieza el tipo de paquete que es y las dimensiones del mismo (Pendiente) >
-- =============================================

CREATE PROCEDURE [dbo].[SetTypePackageToPiece]
	
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@GuidePiece INT,
	@TypePackage NVARCHAR(50)

AS
BEGIN

	DECLARE @UpdatedPiece INT = 0;

	/*
	DECLARE @PieceHeight DECIMAL(12,2) = 0;
	DECLARE @PieceWidth DECIMAL(12,2) = 0;
	DECLARE @PieceLength DECIMAL(12,2) = 0;
	*/

	DECLARE @GeneralTypeId TINYINT = (SELECT TOP 1 CP.PckId FROM [DeliveryBackOffice].[dbo].[CatPackage] CP WHERE CP.PckName = @TypePackage);
	DECLARE @TotalPieces INT = (SELECT COUNT(*) FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WHERE DOP.GuideSerie = @GuideSerie AND DOP.GuideNumber = @GuideNumber)
	DECLARE @CountType INT = (SELECT COUNT(*) FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WHERE DOP.GuideSerie = @GuideSerie AND DOP.GuideNumber = @GuideNumber AND DOP.Detail = @TypePackage)
	
	BEGIN TRANSACTION
		BEGIN TRY

			UPDATE 
				[DeliveryBackOffice].[dbo].[DeliveryOrderPiece]
			SET 
				Detail = @TypePackage
			WHERE
				GuideSerie = @GuideSerie
				AND
				GuideNumber = @GuideNumber
				AND
				NoPiece = @GuidePiece

			SET @UpdatedPiece = @@ROWCOUNT;

			IF(@TotalPieces = @CountType)
			BEGIN
				UPDATE	
					[DeliveryBackOffice].[dbo].[DeliveryOrder]
				SET
					Package_Type = @GeneralTypeId
				WHERE
					Guide_Serie = @GuideSerie
					AND
					Guide_Number = @GuideNumber
			END

		END TRY
		BEGIN CATCH
			SELECT
				0 AS 'StatusId',
				ERROR_MESSAGE() 'Description'
			ROLLBACK TRANSACTION;
		END CATCH
	--END TRANSACTION

	IF(@@TRANCOUNT > 0)
	BEGIN
		IF( @UpdatedPiece > 0 )
		BEGIN
			COMMIT TRANSACTION;
			SELECT
				@UpdatedPiece AS 'StatusId',
				'Exito en actualización' 'Description'
		END
		ELSE
		BEGIN
			SELECT
				0 AS 'StatusId',
				'No se actualizó ninguna pieza.' 'Description'
			ROLLBACK TRANSACTION;
		END
	END
	ELSE
	BEGIN
		SELECT
			0 AS 'StatusId',
			'No se completo la transacción' 'Description'
		ROLLBACK TRANSACTION;
	END

END

