-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-26>
-- Description:	<Inserción de peso volumen, peso masa y categoria en la tabla DeliveryOrderPiece>
-- =============================================
CREATE PROCEDURE [dbo].[spg_set_GuidePieceWeightDimension]
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
			SET PieceHeightCheck = @height, PieceWidthCheck = @Width, PieceLengthCheck = @Length, MassWeight = @WeightMass, volumetricWeight = @WeightVolume
			WHERE GuideSerie = @guideSerie AND GuideNumber = @guideNumber
		END
		ELSE
		BEGIN
			UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] 
			SET PieceHeightCheck = @height, PieceWidthCheck = @Width, PieceLengthCheck = @Length, MassWeight = @WeightMass, volumetricWeight = @WeightVolume
			WHERE GuideSerie = @guideSerie AND GuideNumber = @guideNumber AND NoPiece = @noPiece
		END
	END
	ELSE 
	BEGIN
		IF @cantPiece = 1
		BEGIN
			UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] 
			SET PieceHeightCheck = @height, PieceWidthCheck = @Width, PieceLengthCheck = @Length, MassWeight = @WeightMass, volumetricWeight = @WeightVolume, CategoryCheck=@category
			WHERE GuideSerie = @guideSerie AND GuideNumber = @guideNumber
		END
		ELSE
		BEGIN
			UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] 
			SET PieceHeightCheck = @height, PieceWidthCheck = @Width, PieceLengthCheck = @Length, MassWeight = @WeightMass, volumetricWeight = @WeightVolume, CategoryCheck=@category
			WHERE GuideSerie = @guideSerie AND GuideNumber = @guideNumber AND NoPiece = @noPiece
		END
	END

	DECLARE @sum decimal(12,2)= 0.00
	SELECT  @sum = 
		CASE 
			WHEN [MassWeight] IS NOT NULL AND [volumetricWeight] IS NULL THEN @sum+[MassWeight]
			WHEN [MassWeight] IS NULL AND [volumetricWeight] IS NOT NULL THEN @sum+[volumetricWeight]
			WHEN [MassWeight] IS NULL AND [volumetricWeight] IS NULL THEN @sum+0 
			WHEN [MassWeight] > [volumetricWeight] THEN @sum+[MassWeight]
			WHEN [MassWeight] < [volumetricWeight] THEN @sum+[volumetricWeight]
			WHEN [MassWeight] = [volumetricWeight] THEN @sum+[volumetricWeight]
		END
	FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] WHERE GuideNumber = @guideNumber AND GuideSerie = @guideSerie

	UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder] SET BilledWeight = @sum WHERE Guide_Number = @guideNumber AND Guide_Serie = @guideSerie
END

