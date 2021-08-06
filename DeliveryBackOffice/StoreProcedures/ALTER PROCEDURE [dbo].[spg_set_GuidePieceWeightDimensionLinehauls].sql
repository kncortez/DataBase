USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_set_GuidePieceWeightDimensionLinehauls]    Script Date: 5/08/2021 12:02:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Marco, Jiménez>
-- Create date: <2021-06-24>
-- Description:	<Inserción de peso volumen, peso masa y categoria en la tabla DeliveryOrderPiece>
-- =============================================

--exec spg_set_GuidePieceWeightDimensionLinehauls @height='380', @Width='370', @Length='370', @WeightVolume='18', @WeightMass='10', @category='6', @guideNumber='FD200303-1'

ALTER PROCEDURE [dbo].[spg_set_GuidePieceWeightDimensionLinehauls]
	@height as decimal(12,2),
	@Width as decimal(12,2),
	@Length as decimal(12,2),
	@WeightVolume as decimal(12,2),
	@WeightMass as decimal(12,2),
	@category as varchar(10),
	@PieceUpdated as nvarchar(50),
	@guideNumber as nvarchar(max)
AS
BEGIN
	DECLARE @DateUpdated as datetime = getdate();

	UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] 
	SET PieceHeightCheck = @height, 
		PieceWidthCheck = @Width, 
		PieceLengthCheck = @Length, 
		MassWeight = @WeightMass, 
		volumetricWeight = @WeightVolume,
		CategoryCheck = iif(cast(@category as int) = 0, NULL, cast(@category as int)),
		ParcelCode = iif(cast(@category as int) = 0, NULL, (select Code
															from DeliveryBackOffice.dbo.ArticleByCustomer
															where AbcId = cast(@category as int))),
		PieceUpdated = @PieceUpdated,
		DateUpdated = @DateUpdated
	WHERE CONCAT(GuideSerie,  CAST(GuideNumber AS NVARCHAR(MAX)),'-', CAST(NoPiece AS NVARCHAR(MAX))) = @guideNumber;

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
	FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] 
	WHERE CONCAT(GuideSerie, CAST(GuideNumber AS VARCHAR)) = CONCAT(SUBSTRING(@guideNumber, 1, 2), SUBSTRING(@guideNumber, 3, IIF(CHARINDEX('-', @guideNumber) = 0, (LEN(@guideNumber)), (CHARINDEX('-', @guideNumber) - 3))))

	UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder] 
	SET BilledWeight = @sum 
	WHERE CONCAT(Guide_Serie, CAST(Guide_Number AS VARCHAR)) = CONCAT(SUBSTRING(@guideNumber, 1, 2), SUBSTRING(@guideNumber, 3, IIF(CHARINDEX('-', @guideNumber) = 0, (LEN(@guideNumber)), (CHARINDEX('-', @guideNumber) - 3))))

END


