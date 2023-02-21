-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-02-10>
-- Description:	<Guarda información de los precios por segmento DESKTOP>
-- =============================================
CREATE PROCEDURE [dbo].[SetPackagesRangeData]
	-- Add the parameters for the stored procedure here
	@CatBusinessSegmentId INT,
	@CatTypeRate INT,
	@Token NVARCHAR(50),
	@TblPackagesRange TblPackagesRange READONLY
AS
BEGIN

	DECLARE @STD INT =
				( SELECT TOP (1)
				cs.CtsId
			FROM dbo.CatTypeService cs
			WHERE cs.CtsShortName = 'STD'
			ORDER BY cs.CtsId);

		DECLARE @COD INT =
				( SELECT TOP (1)
				cs.CtsId
			FROM dbo.CatTypeService cs
			WHERE cs.CtsShortName = 'COD'
			ORDER BY cs.CtsId);

		DECLARE @LOC INT =
				( SELECT TOP (1)
				cs.CrsId
			FROM dbo.CatRateSegment cs
			WHERE cs.CrsShortName = 'LOC'
			ORDER BY cs.CrsId);
		DECLARE @MET INT =
				( SELECT TOP (1)
				cs.CrsId
			FROM dbo.CatRateSegment cs
			WHERE cs.CrsShortName = 'MET'
			ORDER BY cs.CrsId);
		DECLARE @FOR INT =
				( SELECT TOP (1)
				cs.CrsId
			FROM dbo.CatRateSegment cs
			WHERE cs.CrsShortName = 'FOR'
			ORDER BY cs.CrsId);

		DECLARE @ESP INT =
				( SELECT TOP (1)
				cs.CrsId
			FROM dbo.CatRateSegment cs
			WHERE cs.CrsShortName = 'ESP'
			ORDER BY cs.CrsId);

	BEGIN TRANSACTION
	BEGIN TRY

		--Eliminar rangos
		UPDATE pr
		SET pr.RowStatus = 'FALSE'
		   ,pr.TokenUpdated = @Token
		   ,pr.DateUpdated = GETDATE()
		FROM PackagesRange pr
		INNER JOIN @TblPackagesRange tpr
			ON pr.IdPackagesRange = tpr.IdPackatesRange
		WHERE tpr.[Status] = 3

		--Eliminar detalle de rangos
		UPDATE prd
		SET prd.RowStatus = 'FALSE'
		   ,prd.TokenUpdated = @Token
		   ,prd.DateUpdated = GETDATE()
		FROM PackagesRangeDetail prd
		INNER JOIN @TblPackagesRange tpr
			ON prd.PackagesRangeId = tpr.IdPackatesRange
		WHERE tpr.[Status] = 3

		--Eliminar COD de rangos
		UPDATE prCOD
		SET prCOD.RowStatus = 'FALSE'
		   ,prCOD.TokenUpdated = @Token
		   ,prCOD.DateUpdated = GETDATE()
		FROM PackagesRangeCOD prCOD
		INNER JOIN @TblPackagesRange tpr
			ON prCOD.PackagesRangeId = tpr.IdPackatesRange
		WHERE tpr.[Status] = 3

		--Actualizar rangos
		UPDATE pr
		SET pr.[Range] = tpr.[Range]
		   ,pr.DiscountPercentage = tpr.Discount
		   ,pr.[Order] = tpr.[Order]
		   ,pr.IsPercent = tpr.IsPercent
		   ,pr.WeightLimit = tpr.WeightLimit
		   ,pr.AdditionalWeightRate = tpr.AdditionalWeightRate
		   ,pr.InsuranceRate = tpr.InsuranceRate
		   ,pr.InsuranceExempt = tpr.InsuranceExempt
		   ,pr.CreditCardRate = tpr.CreditCardRate
		   ,pr.ReturnRate = tpr.ReturnRate
		   ,pr.FragilRate = tpr.FragilRate
		   ,pr.CollectRate = tpr.CollectRate
		   ,pr.Attempt = tpr.Attempt
		   ,pr.PiecesIncluded = tpr.PiecesIncluded
		   ,pr.TokenUpdated = @Token
		   ,pr.DateUpdated = GETDATE()
		FROM PackagesRange pr
		INNER JOIN @TblPackagesRange tpr
			ON pr.IdPackagesRange = tpr.IdPackatesRange
		WHERE tpr.[Status] = 2

		--Actualizar orden 
		UPDATE pr 
		SET pr.[Order] = tpr.[Order]
		FROM PackagesRange pr
		INNER JOIN @TblPackagesRange tpr
			ON pr.IdPackagesRange = tpr.IdPackatesRange
		WHERE tpr.[Status] = 0

		--Actualizar STD LOC
		UPDATE prd
		SET prd.[Value] = tpr.[Local]
		   ,prd.TokenUpdated = @Token
		   ,prd.DateUpdated = GETDATE()
		FROM PackagesRangeDetail prd
		INNER JOIN @TblPackagesRange tpr
			ON prd.PackagesRangeId = tpr.IdPackatesRange
		WHERE tpr.[Status] = 2
		AND prd.CatTypeServiceId = @STD
		AND prd.CatRateSegmentId = @LOC

		--Actualizar STD METRO
		UPDATE prd
		SET prd.[Value] = tpr.Metro
		   ,prd.TokenUpdated = @Token
		   ,prd.DateUpdated = GETDATE()
		FROM PackagesRangeDetail prd
		INNER JOIN @TblPackagesRange tpr
			ON prd.PackagesRangeId = tpr.IdPackatesRange
		WHERE tpr.[Status] = 2
		AND prd.CatTypeServiceId = @STD
		AND prd.CatRateSegmentId = @MET

		--Actualizar STD FOR
		UPDATE prd
		SET prd.[Value] = tpr.Foraneo
		   ,prd.TokenUpdated = @Token
		   ,prd.DateUpdated = GETDATE()
		FROM PackagesRangeDetail prd
		INNER JOIN @TblPackagesRange tpr
			ON prd.PackagesRangeId = tpr.IdPackatesRange
		WHERE tpr.[Status] = 2
		AND prd.CatTypeServiceId = @STD
		AND prd.CatRateSegmentId = @FOR

		--Actualizar STD ESP
		UPDATE prd
		SET prd.[Value] = tpr.Especial
		   ,prd.TokenUpdated = @Token
		   ,prd.DateUpdated = GETDATE()
		FROM PackagesRangeDetail prd
		INNER JOIN @TblPackagesRange tpr
			ON prd.PackagesRangeId = tpr.IdPackatesRange
		WHERE tpr.[Status] = 2
		AND prd.CatTypeServiceId = @STD
		AND prd.CatRateSegmentId = @ESP

		--Actualizar COD LOC
		UPDATE prd
		SET prd.[Value] = tpr.LocalCOD
		   ,prd.TokenUpdated = @Token
		   ,prd.DateUpdated = GETDATE()
		FROM PackagesRangeDetail prd
		INNER JOIN @TblPackagesRange tpr
			ON prd.PackagesRangeId = tpr.IdPackatesRange
		WHERE tpr.[Status] = 2
		AND prd.CatTypeServiceId = @COD
		AND prd.CatRateSegmentId = @LOC

		--Actualizar COD METRO
		UPDATE prd
		SET prd.[Value] = tpr.MetroCOD
		   ,prd.TokenUpdated = @Token
		   ,prd.DateUpdated = GETDATE()
		FROM PackagesRangeDetail prd
		INNER JOIN PackagesRange pr
			ON prd.PackagesRangeId = pr.IdPackagesRange
		INNER JOIN @TblPackagesRange tpr
			ON prd.PackagesRangeId = tpr.IdPackatesRange
		WHERE tpr.[Status] = 2
		AND prd.CatTypeServiceId = @COD
		AND prd.CatRateSegmentId = @MET

		--Actualizar COD FOR
		UPDATE prd
		SET prd.[Value] = tpr.ForaneoCOD
		   ,prd.TokenUpdated = @Token
		   ,prd.DateUpdated = GETDATE()
		FROM PackagesRangeDetail prd
		INNER JOIN @TblPackagesRange tpr
			ON prd.PackagesRangeId = tpr.IdPackatesRange
		WHERE tpr.[Status] = 2
		AND prD.CatTypeServiceId = @COD
		AND prd.CatRateSegmentId = @FOR

		--Actualizar COD ESP
		UPDATE prd
		SET prd.[Value] = tpr.EspecialCOD
		   ,prd.TokenUpdated = @Token
		   ,prd.DateUpdated = GETDATE()
		FROM PackagesRangeDetail prd
		INNER JOIN @TblPackagesRange tpr
			ON prd.PackagesRangeId = tpr.IdPackatesRange
		WHERE tpr.[Status] = 2
		AND prD.CatTypeServiceId = @COD
		AND prd.CatRateSegmentId = @ESP

		--Actualizar COD data LOC
		UPDATE prCOD
		SET prCOD.CODRate = tpr.numCODLoc
		   ,prCOD.CODExempt = tpr.numCODExcentLoc
		   ,prCOD.TokenUpdated = @Token
		   ,prCOD.DateUpdated = GETDATE()
		FROM PackagesRangeCOD prCOD
		INNER JOIN @TblPackagesRange tpr
			ON prCOD.PackagesRangeId = tpr.IdPackatesRange
		WHERE tpr.[Status] = 2
		AND prCOD.CatRateSegmentId = @LOC

		--Actualizar COD data MET
		UPDATE prCOD
		SET prCOD.CODRate = tpr.numCODMet
		   ,prCOD.CODExempt = tpr.numCODExcentMet
		   ,prCOD.TokenUpdated = @Token
		   ,prCOD.DateUpdated = GETDATE()
		FROM PackagesRangeCOD prCOD
		INNER JOIN @TblPackagesRange tpr
			ON prCOD.PackagesRangeId = tpr.IdPackatesRange
		WHERE tpr.[Status] = 2
		AND prCOD.CatRateSegmentId = @MET

		--Actualizar COD data FOR
		UPDATE prCOD
		SET prCOD.CODRate = tpr.numCODFor
		   ,prCOD.CODExempt = tpr.numCODExcentFor
		   ,prCOD.TokenUpdated = @Token
		   ,prCOD.DateUpdated = GETDATE()
		FROM PackagesRangeCOD prCOD
		INNER JOIN @TblPackagesRange tpr
			ON prCOD.PackagesRangeId = tpr.IdPackatesRange
		WHERE tpr.[Status] = 2
		AND prCOD.CatRateSegmentId = @FOR

		--Actualizar COD data ESP
		UPDATE prCOD
		SET prCOD.CODRate = tpr.numCODEsp
		   ,prCOD.CODExempt = tpr.numCODExcentEsp
		   ,prCOD.TokenUpdated = @Token
		   ,prCOD.DateUpdated = GETDATE()
		FROM PackagesRangeCOD prCOD
		INNER JOIN @TblPackagesRange tpr
			ON prCOD.PackagesRangeId = tpr.IdPackatesRange
		WHERE tpr.[Status] = 2
		AND prCOD.CatRateSegmentId = @ESP

		--Insertar rango

		DECLARE @temp TblPackagesRange

		INSERT INTO @temp
			SELECT
				ROW_NUMBER() OVER(ORDER BY [Status])
			   ,tpr.[Range]
			   ,tpr.Discount
			   ,tpr.[Order]
			   ,tpr.[Local]
			   ,tpr.Metro
			   ,tpr.Foraneo
			   ,tpr.Especial
			   ,tpr.LocalCOD
			   ,tpr.MetroCOD
			   ,tpr.ForaneoCOD
			   ,tpr.EspecialCOD
			   ,tpr.IsPercent
			   ,tpr.[Status]
			   ,tpr.WeightLimit
			   ,tpr.AdditionalWeightRate
			   ,tpr.InsuranceRate
			   ,tpr.InsuranceExempt
			   ,tpr.CreditCardRate
			   ,tpr.ReturnRate
			   ,tpr.FragilRate
			   ,tpr.CollectRate
			   ,tpr.Attempt
			   ,tpr.PiecesIncluded
			   ,tpr.numCODLoc
			   ,tpr.numCODMet
			   ,tpr.numCODFor
			   ,tpr.numCODEsp
			   ,tpr.numCODExcentLoc
			   ,tpr.numCODExcentMet
			   ,tpr.numCODExcentFor
			   ,tpr.numCODExcentEsp
			FROM @TblPackagesRange tpr
			WHERE tpr.[Status] = 1

			DECLARE @iter INT
			DECLARE @IdPackagesRange INT

			WHILE EXISTS (SELECT TOP 1 1 FROM @temp)
			BEGIN
				SET @iter = (SELECT TOP 1 IdPackatesRange FROM @temp)

				--Insertar rango
				INSERT INTO [dbo].[PackagesRange] ([Range]
				, [DiscountPercentage]
				, [Order]
				, [CatBusinessSegmentId]
				, [CatTypeRateId]
				, [IsPercent]
				, [WeightLimit]
				, [AdditionalWeightRate]
				, [InsuranceRate]
				, [InsuranceExempt]
				, [CreditCardRate]
				, [ReturnRate]
				, [FragilRate]
				, [CollectRate]
				, [Attempt]
				, [PiecesIncluded]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated])
					SELECT
						tmp.[Range]
					   ,tmp.Discount
					   ,tmp.[Order]
					   ,@CatBusinessSegmentId
					   ,@CatTypeRate
					   ,tmp.IsPercent
					   ,tmp.WeightLimit
					   ,tmp.AdditionalWeightRate
					   ,tmp.InsuranceRate
					   ,tmp.InsuranceExempt
					   ,tmp.CreditCardRate
					   ,tmp.ReturnRate
					   ,tmp.FragilRate
					   ,tmp.CollectRate
					   ,tmp.Attempt
					   ,tmp.PiecesIncluded
					   ,'TRUE'
					   ,@Token
					   ,GETDATE()
					FROM @temp tmp
					WHERE tmp.IdPackatesRange = @iter

				SET @IdPackagesRange = SCOPE_IDENTITY()

				--Insertar rango LOC
				INSERT INTO [dbo].[PackagesRangeDetail] ([PackagesRangeId]
				, [CatTypeServiceId]
				, [CatRateSegmentId]
				, [Value]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated])
					SELECT
						@IdPackagesRange
					   ,@STD
					   ,@LOC
					   ,tmp.[Local]
					   ,'TRUE'
					   ,@Token
					   ,GETDATE()
					FROM @temp tmp
					WHERE tmp.IdPackatesRange = @iter

				--Insertar rango MET
				INSERT INTO [dbo].[PackagesRangeDetail] ([PackagesRangeId]
				, [CatTypeServiceId]
				, [CatRateSegmentId]
				, [Value]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated])
					SELECT
						@IdPackagesRange
					   ,@STD
					   ,@MET
					   ,tmp.Metro
					   ,'TRUE'
					   ,@Token
					   ,GETDATE()
					FROM @temp tmp
					WHERE tmp.IdPackatesRange = @iter

				--Insertar rango FOR
				INSERT INTO [dbo].[PackagesRangeDetail] ([PackagesRangeId]
				, [CatTypeServiceId]
				, [CatRateSegmentId]
				, [Value]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated])
					SELECT
						@IdPackagesRange
					   ,@STD
					   ,@FOR
					   ,tmp.Foraneo
					   ,'TRUE'
					   ,@Token
					   ,GETDATE()
					FROM @temp tmp
					WHERE tmp.IdPackatesRange = @iter

				--Insertar rango ESP
				INSERT INTO [dbo].[PackagesRangeDetail] ([PackagesRangeId]
				, [CatTypeServiceId]
				, [CatRateSegmentId]
				, [Value]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated])
					SELECT
						@IdPackagesRange
					   ,@STD
					   ,@ESP
					   ,tmp.Especial
					   ,'TRUE'
					   ,@Token
					   ,GETDATE()
					FROM @temp tmp
					WHERE tmp.IdPackatesRange = @iter

				--Insertar rango LOC
				INSERT INTO [dbo].[PackagesRangeDetail] ([PackagesRangeId]
				, [CatTypeServiceId]
				, [CatRateSegmentId]
				, [Value]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated])
					SELECT
						@IdPackagesRange
					   ,@COD
					   ,@LOC
					   ,tmp.LocalCOD
					   ,'TRUE'
					   ,@Token
					   ,GETDATE()
					FROM @temp tmp
					WHERE tmp.IdPackatesRange = @iter

				--Insertar rango MET
				INSERT INTO [dbo].[PackagesRangeDetail] ([PackagesRangeId]
				, [CatTypeServiceId]
				, [CatRateSegmentId]
				, [Value]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated])
					SELECT
						@IdPackagesRange
					   ,@COD
					   ,@MET
					   ,tmp.MetroCOD
					   ,'TRUE'
					   ,@Token
					   ,GETDATE()
					FROM @temp tmp
					WHERE tmp.IdPackatesRange = @iter

				--Insertar rango FOR
				INSERT INTO [dbo].[PackagesRangeDetail] ([PackagesRangeId]
				, [CatTypeServiceId]
				, [CatRateSegmentId]
				, [Value]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated])
					SELECT
						@IdPackagesRange
					   ,@COD
					   ,@FOR
					   ,tmp.ForaneoCOD
					   ,'TRUE'
					   ,@Token
					   ,GETDATE()
					FROM @temp tmp
					WHERE tmp.IdPackatesRange = @iter

				--Insertar rango ESP
				INSERT INTO [dbo].[PackagesRangeDetail] ([PackagesRangeId]
				, [CatTypeServiceId]
				, [CatRateSegmentId]
				, [Value]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated])
					SELECT
						@IdPackagesRange
					   ,@COD
					   ,@ESP
					   ,tmp.EspecialCOD
					   ,'TRUE'
					   ,@Token
					   ,GETDATE()
					FROM @temp tmp
					WHERE tmp.IdPackatesRange = @iter

				--insertar COD data LOC
				INSERT INTO [dbo].[PackagesRangeCOD] ([PackagesRangeId]
				, [CatRateSegmentId]
				, [CODRate]
				, [CODExempt]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated])
					SELECT
						@IdPackagesRange
					   ,@LOC
					   ,tmp.numCODLoc
					   ,tmp.numCODExcentLoc
					   ,'TRUE'
					   ,@Token
					   ,GETDATE()
					FROM @temp tmp
					WHERE tmp.IdPackatesRange = @iter
           

				--insertar COD data MET
				INSERT INTO [dbo].[PackagesRangeCOD] ([PackagesRangeId]
				, [CatRateSegmentId]
				, [CODRate]
				, [CODExempt]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated])
					SELECT
						@IdPackagesRange
					   ,@MET
					   ,tmp.numCODMet
					   ,tmp.numCODExcentMet
					   ,'TRUE'
					   ,@Token
					   ,GETDATE()
					FROM @temp tmp
					WHERE tmp.IdPackatesRange = @iter

				--insertar COD data FOR
				INSERT INTO [dbo].[PackagesRangeCOD] ([PackagesRangeId]
				, [CatRateSegmentId]
				, [CODRate]
				, [CODExempt]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated])
					SELECT
						@IdPackagesRange
					   ,@FOR
					   ,tmp.numCODFor
					   ,tmp.numCODExcentFor
					   ,'TRUE'
					   ,@Token
					   ,GETDATE()
					FROM @temp tmp
					WHERE tmp.IdPackatesRange = @iter

				--insertar COD data ESP
				INSERT INTO [dbo].[PackagesRangeCOD] ([PackagesRangeId]
				, [CatRateSegmentId]
				, [CODRate]
				, [CODExempt]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated])
					SELECT
						@IdPackagesRange
					   ,@ESP
					   ,tmp.numCODEsp
					   ,tmp.numCODExcentEsp
					   ,'TRUE'
					   ,@Token
					   ,GETDATE()
					FROM @temp tmp
					WHERE tmp.IdPackatesRange = @iter

				DELETE FROM @temp WHERE IdPackatesRange = @iter
			END

		COMMIT TRANSACTION

		SELECT
			1 'ResponseCode'
			,'Registros guardados correctamente' 'Description'

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

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