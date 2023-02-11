-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-02-10>
-- Description:	<Obtiene información de los precios por segmento DESKTOP>
-- =============================================
CREATE PROCEDURE [dbo].[GetPackagesRangeData]
	-- Add the parameters for the stored procedure here
	@CatBusinessSegmentId INT,
	@CatTypeRate INT
AS
BEGIN

	BEGIN TRY

		SELECT
			1 'ResponseCode'
			,'Registros guardados correctamente' 'Description'

		SELECT
			pr.IdPackagesRange
		   ,pr.[Range] [Range]
		   ,pr.IsPercent IsPercent
		   ,pr.DiscountPercentage Discount
		   ,pr.WeightLimit WeightLimit
		   ,pr.AdditionalWeightRate AdditionalWeightRate
		   ,pr.InsuranceRate InsuranceRate
		   ,pr.InsuranceExempt InsuranceExempt
		   ,pr.CreditCardRate CreditCardRate
		   ,pr.ReturnRate ReturnRate
		   ,pr.FragilRate FragilRate
		   ,pr.CollectRate CollectRate
		   ,pr.Attempt Attempt
		   ,pr.PiecesIncluded PiecesIncluded
		FROM PackagesRange pr
		WHERE pr.CatBusinessSegmentId = @CatBusinessSegmentId
		AND pr.CatTypeRateId = @CatTypeRate
		AND pr.RowStatus = 1
		ORDER BY pr.[Order] 

		SELECT 
			pr.IdPackagesRange IdPackagesRange
			,cts.CtsShortName CatTypeService
			,crs.CrsShortName CatRateSegment
			,prd.[Value] [Value]
		FROM PackagesRangeDetail prd
		INNER JOIN PackagesRange pr
			ON prd.PackagesRangeId = pr.IdPackagesRange
		INNER JOIN CatTypeService cts
			ON prd.CatTypeServiceId = cts.CtsId
		INNER JOIN CatRateSegment crs
			ON prd.CatRateSegmentId = crs.CrsId
		WHERE pr.CatBusinessSegmentId = @CatBusinessSegmentId
		AND pr.CatTypeRateId = @CatTypeRate
		AND pr.RowStatus = 1
		AND prd.RowStatus = 1

		SELECT 
			pr.IdPackagesRange IdPackagesRange
			,crs.CrsShortName CatRateSegment
			,prCOD.CODRate CODRate
			,prCOD.CODExempt CODExempt
		FROM PackagesRangeCOD prCOD
		INNER JOIN PackagesRange pr
			ON prCOD.PackagesRangeId = pr.IdPackagesRange
		INNER JOIN CatRateSegment crs
			ON prCOD.CatRateSegmentId = crs.CrsId
		WHERE pr.CatBusinessSegmentId = @CatBusinessSegmentId
		AND pr.CatTypeRateId = @CatTypeRate
		AND pr.RowStatus = 1
		AND prCOD.RowStatus = 1
	END TRY
	BEGIN CATCH

		SELECT
			0 'ResponseCode'
		   ,ERROR_MESSAGE() 'Description'
		   ,ERROR_NUMBER() 'ErrorNumber'
		   ,ERROR_SEVERITY() 'ErrorSeverity'
		   ,ERROR_STATE() 'ErrorState'
		   ,ERROR_PROCEDURE() 'ErrorProcedure'
		   ,ERROR_LINE() 'ErrorLine';

	END CATCH
END