CREATE PROCEDURE [dbo].[sps_get_guide_piece_scan]
@Guide_Serie VARCHAR(5),
@Guide_Number INT ,
@Piece INT
AS
BEGIN

/*IF EXISTS ( SELECT PS.GuidePieceId, DOP.GuideSerie, DOP.GuideNumber, DOP.NoPiece 
	FROM PieceByService PS
	INNER JOIN DeliveryOrderPiece DOP 
	ON PS.GuidePieceId = DOP.GuidePiece 
	WHERE DOP.GuideSerie = @Guide_Serie AND DOP.GuideNumber = @Guide_Number  AND NoPiece = @Piece)*/

		BEGIN

			SELECT PS.GuidePieceId, DOP.GuideSerie, DOP.GuideNumber, DOP.NoPiece 
			FROM PieceByService PS
			INNER JOIN DeliveryOrderPiece DOP 
			ON PS.GuidePieceId = DOP.GuidePiece 
			WHERE DOP.GuideSerie = @Guide_Serie AND DOP.GuideNumber = @Guide_Number  AND NoPiece = @Piece
		END

/*ELSE
		BEGIN
		SELECT GuidePieceId = 'null';
		END*/
END
