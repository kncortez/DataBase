USE [DeliveryBackOffice]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-26>
-- Description:	<Inserción de peso volumen, peso masa y categoria en la tabla DeliveryOrderPiece>
-- =============================================
ALTER PROCEDURE [dbo].[spg_set_GuidePieceWeightDimension]
	@height as decimal(12,2),
	@Width as decimal(12,2),
	@Length as decimal(12,2),
	@WeightVolume as decimal(12,2),
	@WeightMass as decimal(12,2),
	@category as int,
	@guideNumber as int,
	@guideSerie as nvarchar(2),
	@noPiece as int,
	@cantPiece as int
AS
BEGIN
	IF @category = 0
	BEGIN
		IF @cantPiece = 1
		BEGIN
			UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] 
			SET PieceHeightCheck = @height, PieceWidthCheck = @Width, PieceLengthCheck = @Length, PieceWeightCheck = @WeightMass, PiecePhysicalWeightCheck = @WeightVolume
			WHERE GuideSerie = @guideSerie AND GuideNumber = @guideNumber
		END
		ELSE
		BEGIN
			UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] 
			SET PieceHeightCheck = @height, PieceWidthCheck = @Width, PieceLengthCheck = @Length, PieceWeightCheck = @WeightMass, PiecePhysicalWeightCheck = @WeightVolume
			WHERE GuideSerie = @guideSerie AND GuideNumber = @guideNumber AND NoPiece = @noPiece
		END
	END
	ELSE 
	BEGIN
		IF @cantPiece = 1
		BEGIN
			UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] 
			SET PieceHeightCheck = @height, PieceWidthCheck = @Width, PieceLengthCheck = @Length, PieceWeightCheck = @WeightMass, PiecePhysicalWeightCheck = @WeightVolume, CategoryCheck=@category
			WHERE GuideSerie = @guideSerie AND GuideNumber = @guideNumber
		END
		ELSE
		BEGIN
			UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] 
			SET PieceHeightCheck = @height, PieceWidthCheck = @Width, PieceLengthCheck = @Length, PieceWeightCheck = @WeightMass, PiecePhysicalWeightCheck = @WeightVolume, CategoryCheck=@category
			WHERE GuideSerie = @guideSerie AND GuideNumber = @guideNumber AND NoPiece = @noPiece
		END
	END
END