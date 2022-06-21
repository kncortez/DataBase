
-- =============================================
-- Author:		<César, Aquino>
-- Create date: <2021-06-14>
-- Description:	<Insertar un nuevo tarifario>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_set_Rate_Data]
    @IdRate INT = -1,
    @RateName NVARCHAR(50),
    @RateShortName NVARCHAR(10) = '',
    @RateDescription NVARCHAR(200) = '',
    @IdTypeRate INT,
    @Token NVARCHAR(50),
    @CountryId NVARCHAR(50) = 'GT',
    @CurrencyId INT = 1,
    @IsTemplate BIT = 1,
    @Status BIT = 1,
    @FragilRate DECIMAL(12, 2) = 0,
    @InsuranceRate DECIMAL(12, 2) = 1,
    @InsuranceExempt DECIMAL(12, 2) = 800,
    @AdditionalWeightRate DECIMAL(12, 2) = 1,
    @WeightLimit DECIMAL(12, 2) = 30,
    @CreditCardRate DECIMAL(12, 2) = 2,
    @Attempt INT = 2,
    @ReturnRate DECIMAL(12, 2) = 100,
    @CollectRate DECIMAL(12, 2) = 3,
    @PiecesIncluded INT = 1,
    @SDLOCRate DECIMAL(12, 2) = 0,
    @SDMETRate DECIMAL(12, 2) = 0,
    @SDFORRate DECIMAL(12, 2) = 0,
    @NDLOCRate DECIMAL(12, 2) = 0,
    @NDMETRate DECIMAL(12, 2) = 0,
    @NDFORRate DECIMAL(12, 2) = 0,
    @TDLOCRate DECIMAL(12, 2) = 0,
    @TDMETRate DECIMAL(12, 2) = 0,
    @TDFORRate DECIMAL(12, 2) = 0,
    @SddLocCod DECIMAL(12, 2) = 0,
    @SddMetCod DECIMAL(12, 2) = 0,
    @SddForCod DECIMAL(12, 2) = 0,
    @NddLocCod DECIMAL(12, 2) = 0,
    @NddMetCod DECIMAL(12, 2) = 0,
    @NddForCod DECIMAL(12, 2) = 0,
    @TdaLocCod DECIMAL(12, 2) = 0,
    @TdaMetCod DECIMAL(12, 2) = 0,
    @TdaForCod DECIMAL(12, 2) = 0,
    @SddLocCodExempt DECIMAL(12, 2) = 0,
    @SddMetCodExempt DECIMAL(12, 2) = 0,
    @SddForCodExempt DECIMAL(12, 2) = 0,
    @NddLocCodExempt DECIMAL(12, 2) = 0,
    @NddMetCodExempt DECIMAL(12, 2) = 0,
    @NddForCodExempt DECIMAL(12, 2) = 0,
    @TdaLocCodExempt DECIMAL(12, 2) = 0,
    @TdaMetCodExempt DECIMAL(12, 2) = 0,
    @TdaForCodExempt DECIMAL(12, 2) = 0,
    @TblArticleRate AS TblArticleRate READONLY,
	@TblWeightRate AS TblWeightRate READONLY
AS
BEGIN
    DECLARE @SDD INT =
            (
                SELECT TOP (1)
                       cs.CtsId
                FROM dbo.CatTypeService cs
                WHERE cs.CtsShortName = 'SDD'
                ORDER BY cs.CtsId
            );
    DECLARE @NDD INT =
            (
                SELECT TOP (1)
                       cs.CtsId
                FROM dbo.CatTypeService cs
                WHERE cs.CtsShortName = 'NDD'
                ORDER BY cs.CtsId
            );
    DECLARE @TDA INT =
            (
                SELECT TOP (1)
                       cs.CtsId
                FROM dbo.CatTypeService cs
                WHERE cs.CtsShortName = 'TDA'
                ORDER BY cs.CtsId
            );


    DECLARE @LOC INT =
            (
                SELECT TOP (1)
                       cs.CrsId
                FROM dbo.CatRateSegment cs
                WHERE cs.CrsShortName = 'LOC'
                ORDER BY cs.CrsId
            );
    DECLARE @MET INT =
            (
                SELECT TOP (1)
                       cs.CrsId
                FROM dbo.CatRateSegment cs
                WHERE cs.CrsShortName = 'MET'
                ORDER BY cs.CrsId
            );
    DECLARE @FOR INT =
            (
                SELECT TOP (1)
                       cs.CrsId
                FROM dbo.CatRateSegment cs
                WHERE cs.CrsShortName = 'FOR'
                ORDER BY cs.CrsId
            );

    PRINT 'inicia la transaccion ';
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Insertar/actualizar encabezador-----/
        IF NOT EXISTS (SELECT * FROM dbo.RateHeader WHERE RheId = @IdRate) -- se debe insertar un nuevo registro
        BEGIN
            PRINT 'INSERT RATEHEADER';
            INSERT INTO dbo.RateHeader
            (
                RheName,
                RheShortName,
                RheDescription,
                RheRowStatus,
                RheTokenCreated,
                RheDateCreated,
                RateTypeId,
                RheDefault,
                FragilRate,
                InsuranceRate,
                InsuranceExempt,
                AdditionalWeightRate,
                WeightLimit,
                CreditCardRate,
                Attempt,
                ReturnRate,
                CollectRate,
                PiecesIncluded,
                CountryId,
                CurrencyId,
                IsTemplate
            )
            VALUES
            (@RateName, @RateShortName, @RateDescription, 1, @Token, GETDATE(), @IdTypeRate, 0, @FragilRate,
             @InsuranceRate, @InsuranceExempt, @AdditionalWeightRate, @WeightLimit, @CreditCardRate, @Attempt,
             @ReturnRate, @CollectRate, @PiecesIncluded, @CountryId, @CurrencyId, @IsTemplate);

            SET @IdRate = SCOPE_IDENTITY();
            PRINT 'se inserto el tarifario';
        END;
        ELSE
        BEGIN
            PRINT 'UPDATE RATEHEADER';
            PRINT 'update';
            UPDATE dbo.RateHeader
            SET RheName = @RateName,
                RheShortName = @RateShortName,
                RheDescription = @RateDescription,
                RheRowStatus = @Status,
                RateTypeId = @IdTypeRate,
                FragilRate = @FragilRate,
                InsuranceRate = @InsuranceRate,
                InsuranceExempt = @InsuranceExempt,
                AdditionalWeightRate = @AdditionalWeightRate,
                WeightLimit = @WeightLimit,
                CreditCardRate = @CreditCardRate,
                Attempt = @Attempt,
                ReturnRate = @ReturnRate,
                CollectRate = @CollectRate,
                PiecesIncluded = @PiecesIncluded,
                CurrencyId = @CurrencyId
            WHERE RheId = @IdRate;
        END;

        IF @IdTypeRate = 1 -- Tarifas standar
        BEGIN
            -- TODO  TARIFARIOS STANDAR
            SELECT	'las tarifas standar aun no estan soportadas' AS message,
                    @IdRate AS IdRate,
                    @IdTypeRate AS IdTypeRate,
					'FALSE' [blnResult],
					CAST(@IdRate AS VARCHAR(50)) [IdResult],
					CAST(412 AS VARCHAR(50)) [StatusResult],
					'' AS [ErrorNumber],
					'' AS [ErrorSeverity],
					'' AS [ErrorState],
					'' AS [ErrorProcedure],
					'' AS [ErrorLine],
					'Las tarifas standar aun no estan soportadas' AS [ResultMessage]

        END;
        IF @IdTypeRate = 2
           OR @IdTypeRate = 3 -- tarifas todo destino y por articulo
        BEGIN
            -- insertar tarifas todo destino y por articulo SDD
            IF @SDLOCRate > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @LOC
                )
                BEGIN
                    PRINT 'UPDATE RATEDATA SDD LOC';
                    UPDATE dbo.RateData
                    SET RateValue = @SDLOCRate,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @LOC;
                END;
                ELSE
                BEGIN
                    PRINT 'INSERT RATEDATA SDD LOC';
                    PRINT @IdRate;
                    INSERT INTO dbo.RateData
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        RateValue,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (@IdRate, @SDD, @LOC, @SDLOCRate, 1, @Token, GETDATE());
                END;

            END;
            ELSE
            BEGIN
                PRINT 'UPDATE RATEDATA SDD LOC ANULADO';
                UPDATE dbo.RateData
                SET RateValue = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @SDD
                      AND TypeSegmentId = @LOC;
            END;
            IF @SDMETRate > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @MET
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @SDMETRate,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @MET;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateData
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        RateValue,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (@IdRate, @SDD, @MET, @SDMETRate, 1, @Token, GETDATE());
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateData
                SET RateValue = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @SDD
                      AND TypeSegmentId = @MET;
            END;
            IF @SDFORRate > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @FOR
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @SDFORRate,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @FOR;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateData
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        RateValue,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (@IdRate, @SDD, @FOR, @SDFORRate, 1, @Token, GETDATE());
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateData
                SET RateValue = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @SDD
                      AND TypeSegmentId = @FOR;
            END;

            IF @SddLocCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @LOC
                )
                BEGIN
                    PRINT ' UPDATE RATECOD SDD LOC COD';
                    UPDATE dbo.RateCOD
                    SET CODRate = @SddLocCod,
						CODExempt = @SddLocCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @LOC;
                END;
                ELSE
                BEGIN
                    PRINT ' INSERT RATECOD SDD LOC COD';
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @SDD,             -- TypeServiceId - int
                        @LOC,             -- TypeSegmentId - int
                        @SddLocCod,       -- CODRate - decimal(12, 2)
                        @SddLocCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                PRINT ' UPDATE RATECOD SDD LOC COD MONTO CERO';
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @SDD
                      AND TypeSegmentId = @LOC;
            END;
            IF @SddMetCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @MET
                )
                BEGIN
                    PRINT ' UPDATE RATECOD SDD MET COD';
                    UPDATE dbo.RateCOD
                    SET CODRate = @SddMetCod,
						CODExempt = @SddMetCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @MET;
                END;
                ELSE
                BEGIN
                    PRINT ' INSERT RATECOD SDD MET COD';
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @SDD,             -- TypeServiceId - int
                        @MET,             -- TypeSegmentId - int
                        @SddMetCod,       -- CODRate - decimal(12, 2)
                        @SddMetCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                PRINT ' UPDATE RATECOD SDD MET COD ANULADO';
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @SDD
                      AND TypeSegmentId = @MET;
            END;
            IF @SddForCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @FOR
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @SddForCod,
						CODExempt = @SddForCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @FOR;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @SDD,             -- TypeServiceId - int
                        @FOR,             -- TypeSegmentId - int
                        @SddForCod,       -- CODRate - decimal(12, 2)
                        @SddForCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @SDD
                      AND TypeSegmentId = @FOR;
            END;

            -- insertar tarifas todo destino y por articulo NDD
            IF @NDLOCRate > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @LOC
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @NDLOCRate,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @LOC;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateData
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        RateValue,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (@IdRate, @NDD, @LOC, @NDLOCRate, 1, @Token, GETDATE());
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateData
                SET RateValue = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @SDD
                      AND TypeSegmentId = @LOC;
            END;
            IF @NDMETRate > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @MET
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @NDMETRate,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @MET;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateData
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        RateValue,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (@IdRate, @NDD, @MET, @NDMETRate, 1, @Token, GETDATE());
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateData
                SET RateValue = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @SDD
                      AND TypeSegmentId = @MET;
            END;
            IF @NDFORRate > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @FOR
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @NDFORRate,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @FOR;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateData
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        RateValue,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (@IdRate, @NDD, @FOR, @NDFORRate, 1, @Token, GETDATE());
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateData
                SET RateValue = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @NDD
                      AND TypeSegmentId = @FOR;
            END;

            IF @NddLocCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @LOC
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @NddLocCod,
						CODExempt = @NddLocCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @LOC;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @NDD,             -- TypeServiceId - int
                        @LOC,             -- TypeSegmentId - int
                        @NddLocCod,       -- CODRate - decimal(12, 2)
                        @NddLocCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @NDD
                      AND TypeSegmentId = @LOC;
            END;
            IF @NddMetCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @MET
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @NddMetCod,
						CODExempt = @NddMetCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @MET;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @NDD,             -- TypeServiceId - int
                        @MET,             -- TypeSegmentId - int
                        @NddMetCod,       -- CODRate - decimal(12, 2)
                        @NddMetCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @NDD
                      AND TypeSegmentId = @MET;
            END;
            IF @NddForCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @FOR
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @NddForCod,
						CODExempt = @NddForCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @FOR;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @NDD,             -- TypeServiceId - int
                        @FOR,             -- TypeSegmentId - int
                        @NddForCod,       -- CODRate - decimal(12, 2)
                        @NddForCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @NDD
                      AND TypeSegmentId = @FOR;
            END;

            -- insertar tarifas todo destino y por articulo TDA
            IF @TDLOCRate > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @LOC
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @TDLOCRate,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @LOC;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateData
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        RateValue,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (@IdRate, @TDA, @LOC, @TDLOCRate, 1, @Token, GETDATE());
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateData
                SET RateValue = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @TDA
                      AND TypeSegmentId = @LOC;
            END;
            IF @TDMETRate > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @MET
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @TDMETRate,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @MET;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateData
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        RateValue,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (@IdRate, @TDA, @MET, @TDMETRate, 1, @Token, GETDATE());
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateData
                SET RateValue = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @TDA
                      AND TypeSegmentId = @MET;
            END;
            IF @TDFORRate > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @FOR
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @TDFORRate,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @FOR;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateData
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        RateValue,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (@IdRate, @TDA, @FOR, @TDFORRate, 1, @Token, GETDATE());
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateData
                SET RateValue = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @TDA
                      AND TypeSegmentId = @FOR;
            END;

            IF @TdaLocCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @LOC
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @TdaLocCod,
						CODExempt = @TdaLocCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @LOC;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @TDA,             -- TypeServiceId - int
                        @LOC,             -- TypeSegmentId - int
                        @TdaLocCod,       -- CODRate - decimal(12, 2)
                        @TdaLocCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @TDA
                      AND TypeSegmentId = @LOC;
            END;
            IF @TdaMetCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @MET
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @TdaMetCod,
						CODExempt = @TdaMetCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @MET;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @TDA,             -- TypeServiceId - int
                        @MET,             -- TypeSegmentId - int
                        @TdaMetCod,       -- CODRate - decimal(12, 2)
                        @TdaMetCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @TDA
                      AND TypeSegmentId = @MET;
            END;
            IF @TdaForCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @FOR
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @TdaForCod,
						CODExempt = @TdaForCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @FOR;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @TDA,             -- TypeServiceId - int
                        @FOR,             -- TypeSegmentId - int
                        @TdaForCod,       -- CODRate - decimal(12, 2)
                        @TdaForCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @TDA
                      AND TypeSegmentId = @FOR;
            END;

        END;
        IF @IdTypeRate = 3 -- insertar articulos al tarifario
        BEGIN

            -- Desactivar todos los articulos con status 0 o que la tarifa sea 0
            UPDATE dbo.RateData
            SET RowStatus = 0,
                TokenUpdated = @Token,
                DateUpdated = GETDATE()
            WHERE RateId = @IdRate
                  AND ArticleId IN
                      (
                          SELECT ar.IdArticle
                          FROM @TblArticleRate ar
                          WHERE ar.Rate <= 0
                                OR ar.Status = 0
                      );

            -- actualizar los articulos ya existentes

            UPDATE dbo.RateData
            SET RateValue = ar.Rate,
				RowStatus ='true',
                TokenUpdated = @Token,
                DateUpdated = GETDATE()
            FROM @TblArticleRate ar
                LEFT JOIN dbo.CatRateSegment sg
                    ON sg.CrsShortName = ar.Segment
                LEFT JOIN dbo.RateData rd
                    ON rd.RateId = @IdRate
                       AND rd.ArticleId = ar.IdArticle
                       AND rd.TypeSegmentId = sg.CrsId
            WHERE ar.Rate > 0
                  AND ar.Status = 1
                  AND rd.RateId IS NOT NULL;

            -- insertar registro que no existen

            INSERT INTO dbo.RateData
            (
                RateId,
                TypeSegmentId,
                ArticleId,
                RateValue,
                RowStatus,
                TokenCreated,
                DateCreated
            )
            SELECT @IdRate,
                   sg.CrsId,
                   ar.IdArticle,
                   ar.Rate,
                   1, -- crear como activo
                   @Token,
                   GETDATE()
            FROM @TblArticleRate ar
                LEFT JOIN dbo.CatRateSegment sg
                    ON sg.CrsShortName = ar.Segment
                LEFT JOIN dbo.RateData rd
                    ON rd.RateId = @IdRate
                       AND rd.ArticleId = ar.IdArticle
                       AND rd.TypeSegmentId = sg.CrsId
            WHERE ar.Rate > 0
                  AND ar.Status = 1
                  AND rd.RateId IS NULL;

        END;

		IF @IdTypeRate = (SELECT IdTypeRate FROM CatTypeRate WHERE Name = 'Por Peso') -- insertar por rango de pesos
        BEGIN			
			--COD SDD
			IF @SddLocCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @LOC
                )
                BEGIN
                    --PRINT ' UPDATE RATECOD SDD LOC COD';
                    UPDATE dbo.RateCOD
                    SET CODRate = @SddLocCod,
						CODExempt = @SddLocCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @LOC;
                END;
                ELSE
                BEGIN
                    --PRINT ' INSERT RATECOD SDD LOC COD';
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @SDD,             -- TypeServiceId - int
                        @LOC,             -- TypeSegmentId - int
                        @SddLocCod,       -- CODRate - decimal(12, 2)
                        @SddLocCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                --PRINT ' UPDATE RATECOD SDD LOC COD MONTO CERO';
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @SDD
                      AND TypeSegmentId = @LOC;
            END;
            IF @SddMetCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @MET
                )
                BEGIN
                    --PRINT ' UPDATE RATECOD SDD MET COD';
                    UPDATE dbo.RateCOD
                    SET CODRate = @SddMetCod,
						CODExempt = @SddMetCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @MET;
                END;
                ELSE
                BEGIN
                    --PRINT ' INSERT RATECOD SDD MET COD';
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @SDD,             -- TypeServiceId - int
                        @MET,             -- TypeSegmentId - int
                        @SddMetCod,       -- CODRate - decimal(12, 2)
                        @SddMetCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

				--COD NDD
            IF @NddLocCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @LOC
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @NddLocCod,
						CODExempt = @NddLocCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @LOC;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @NDD,             -- TypeServiceId - int
                        @LOC,             -- TypeSegmentId - int
                        @NddLocCod,       -- CODRate - decimal(12, 2)
                        @NddLocCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @NDD
                      AND TypeSegmentId = @LOC;
            END;
            IF @NddMetCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @MET
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @NddMetCod,
						CODExempt = @NddMetCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @MET;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @NDD,             -- TypeServiceId - int
                        @MET,             -- TypeSegmentId - int
                        @NddMetCod,       -- CODRate - decimal(12, 2)
                        @NddMetCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @NDD
                      AND TypeSegmentId = @MET;
            END;
            IF @NddForCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @FOR
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @NddForCod,
						CODExempt = @NddForCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @NDD
                          AND TypeSegmentId = @FOR;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @NDD,             -- TypeServiceId - int
                        @FOR,             -- TypeSegmentId - int
                        @NddForCod,       -- CODRate - decimal(12, 2)
                        @NddForCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @NDD
                      AND TypeSegmentId = @FOR;
            END;

            END;
            ELSE
            BEGIN
                --PRINT ' UPDATE RATECOD SDD MET COD ANULADO';
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @SDD
                      AND TypeSegmentId = @MET;
            END;
            IF @SddForCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @FOR
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @SddForCod,
						CODExempt = @SddForCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @SDD
                          AND TypeSegmentId = @FOR;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @SDD,             -- TypeServiceId - int
                        @FOR,             -- TypeSegmentId - int
                        @SddForCod,       -- CODRate - decimal(12, 2)
                        @SddForCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @SDD
                      AND TypeSegmentId = @FOR;
            END;

			--COD TDA
			IF @TdaLocCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @LOC
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @TdaLocCod,
						CODExempt = @TdaLocCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @LOC;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @TDA,             -- TypeServiceId - int
                        @LOC,             -- TypeSegmentId - int
                        @TdaLocCod,       -- CODRate - decimal(12, 2)
                        @TdaLocCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @TDA
                      AND TypeSegmentId = @LOC;
            END;
            IF @TdaMetCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @MET
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @TdaMetCod,
						CODExempt = @TdaMetCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @MET;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @TDA,             -- TypeServiceId - int
                        @MET,             -- TypeSegmentId - int
                        @TdaMetCod,       -- CODRate - decimal(12, 2)
                        @TdaMetCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @TDA
                      AND TypeSegmentId = @MET;
            END;
            IF @TdaForCod > 0
            BEGIN
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @FOR
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @TdaForCod,
						CODExempt = @TdaForCodExempt,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @TDA
                          AND TypeSegmentId = @FOR;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.RateCOD
                    (
                        RateId,
                        TypeServiceId,
                        TypeSegmentId,
                        CODRate,
                        CODExempt,
                        CreditCardSurcharge,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    VALUES
                    (   @IdRate,          -- RateId - int
                        @TDA,             -- TypeServiceId - int
                        @FOR,             -- TypeSegmentId - int
                        @TdaForCod,       -- CODRate - decimal(12, 2)
                        @TdaForCodExempt, -- CODExempt - decimal(12, 2)
                        NULL,             -- CreditCardSurcharge - decimal(12, 2)
                        1,                -- RowStatus - int
                        @Token,           -- TokenCreated - varchar(50)
                        GETDATE()         -- DateCreated - datetime
                        );
                END;

            END;
            ELSE
            BEGIN
                UPDATE dbo.RateCOD
                SET CODRate = 0,
                    RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE RateId = @IdRate
                      AND TypeServiceId = @TDA
                      AND TypeSegmentId = @FOR;
            END;

			--rango de pesos
			--PRINT 'RANGO DE PESOS'

			--Eliminar rango de pesos SDD
			UPDATE rd
			SET rd.RowStatus = 'FALSE'
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE rd.RateId = @IdRate
			AND twr.CatTypeService = 1
			AND rd.TypeServiceId = @SDD
			AND twr.State = 3

			--Eliminar rango de pesos NDD
			UPDATE rd
			SET rd.RowStatus = 'FALSE'
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE rd.RateId = @IdRate
			AND twr.CatTypeService = 2
			AND rd.TypeServiceId = @NDD
			AND twr.State = 3

			--Eliminar rango de pesos TDA
			UPDATE rd
			SET rd.RowStatus = 'FALSE'
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE rd.RateId = @IdRate
			AND twr.CatTypeService = 3
			AND rd.TypeServiceId = @TDA
			AND twr.State = 3

			--Actualizar rango de pesos SDD LOCAL
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Local
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 1  --SDD en desktop
			AND rd.TypeServiceId = @SDD
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @LOC
			AND twr.State = 2

			--Actualizar rango de pesos SDD MET
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Metro
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 1  --SDD en desktop
			AND rd.TypeServiceId = @SDD
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @MET
			AND twr.State = 2

			--Actualizar rango de pesos SDD FOR
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Foraneo
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 1  --SDD en desktop
			AND rd.TypeServiceId = @SDD
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @FOR
			AND twr.State = 2

			--Actualizar rango de pesos NDD LOCAL
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Local
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 2  --NDD en desktop
			AND rd.TypeServiceId = @NDD
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @LOC
			AND twr.State = 2

			--Actualizar rango de pesos NDD MET
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Metro
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 2  --NDD en desktop
			AND rd.TypeServiceId = @NDD
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @MET
			AND twr.State = 2

			--Actualizar rango de pesos NDD FOR
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Foraneo
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 2  --NDD en desktop
			AND rd.TypeServiceId = @NDD
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @FOR
			AND twr.State = 2

			--Actualizar rango de pesos TDA LOCAL
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Local
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 3  --TDA en desktop
			AND rd.TypeServiceId = @TDA
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @LOC
			AND twr.State = 2

			--Actualizar rango de pesos TDA MET
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Metro
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 3  --TDA en desktop
			AND rd.TypeServiceId = @TDA
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @MET
			AND twr.State = 2

			--Actualizar rango de pesos TDA FOR
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Foraneo
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 3  --TDA en desktop
			AND rd.TypeServiceId = @TDA
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @FOR
			AND twr.State = 2
			
			--Insertar rango de pesos SDD LOC
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@SDD
				   ,@LOC
				   ,Local
				   ,'TRUE'
				   ,@Token
				   ,GETDATE()
				   ,WeightFrom
				   ,WeightTo
				FROM @TblWeightRate
				WHERE CatTypeService = 1
				AND State = 1

			--Insertar rango de pesos SDD MET
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@SDD
				   ,@MET
				   ,Metro
				   ,'TRUE'
				   ,@Token
				   ,GETDATE()
				   ,WeightFrom
				   ,WeightTo
				FROM @TblWeightRate
				WHERE CatTypeService = 1
				AND State = 1

			--Insertar rango de pesos SDD FOR
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@SDD
				   ,@FOR
				   ,Foraneo
				   ,'TRUE'
				   ,@Token
				   ,GETDATE()
				   ,WeightFrom
				   ,WeightTo
				FROM @TblWeightRate
				WHERE CatTypeService = 1
				AND State = 1

			--Insertar rango de pesos NDD LOC
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@NDD
				   ,@LOC
				   ,Local
				   ,'TRUE'
				   ,@Token
				   ,GETDATE()
				   ,WeightFrom
				   ,WeightTo
				FROM @TblWeightRate
				WHERE CatTypeService = 2
				AND State = 1

			--Insertar rango de pesos NDD MET
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@NDD
				   ,@MET
				   ,Metro
				   ,'TRUE'
				   ,@Token
				   ,GETDATE()
				   ,WeightFrom
				   ,WeightTo
				FROM @TblWeightRate
				WHERE CatTypeService = 2
				AND State = 1

			--Insertar rango de pesos NDD FOR
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@NDD
				   ,@FOR
				   ,Foraneo
				   ,'TRUE'
				   ,@Token
				   ,GETDATE()
				   ,WeightFrom
				   ,WeightTo
				FROM @TblWeightRate
				WHERE CatTypeService = 2
				AND State = 1

			--Insertar rango de pesos TDA LOC
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@TDA
				   ,@LOC
				   ,Local
				   ,'TRUE'
				   ,@Token
				   ,GETDATE()
				   ,WeightFrom
				   ,WeightTo
				FROM @TblWeightRate
				WHERE CatTypeService = 3
				AND State = 1

			--Insertar rango de pesos TDA MET
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@TDA
				   ,@MET
				   ,Metro
				   ,'TRUE'
				   ,@Token
				   ,GETDATE()
				   ,WeightFrom
				   ,WeightTo
				FROM @TblWeightRate
				WHERE CatTypeService = 3
				AND State = 1

			--Insertar rango de pesos TDA FOR
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@TDA
				   ,@FOR
				   ,Foraneo
				   ,'TRUE'
				   ,@Token
				   ,GETDATE()
				   ,WeightFrom
				   ,WeightTo
				FROM @TblWeightRate
				WHERE CatTypeService = 3
				AND State = 1

		END

    END TRY
    BEGIN CATCH
		SELECT 'RollBackTransaction' AS message,
			    -1 AS IdRate,
				-1 AS IdTypeRate,
				'FALSE'	[blnResult]
				,CAST(-1 AS VARCHAR(5)) [IdResult]
				,CAST(500 AS VARCHAR(5)) [StatusResult]
				,CAST(ERROR_NUMBER() AS VARCHAR) AS [ErrorNumber]
				,CAST(ERROR_SEVERITY() AS VARCHAR) AS [ErrorSeverity]
				,CAST(ERROR_STATE() AS VARCHAR) AS [ErrorState]
				,CAST(ERROR_PROCEDURE() AS VARCHAR) AS [ErrorProcedure]
				,CAST(ERROR_LINE() AS VARCHAR) AS [ErrorLine]  
				,CAST(ERROR_MESSAGE() AS VARCHAR) AS [ResultMessage]

        ROLLBACK TRANSACTION;

    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN

        SELECT		'Succesfull' AS message,
			         @IdRate AS IdRate,
					 @IdTypeRate AS IdTypeRate,
					'TRUE' [blnResult],
					CAST(@IdRate AS VARCHAR(50)) [IdResult],
					CAST(200 AS VARCHAR(50)) [StatusResult],
					'' AS [ErrorNumber],
					'' AS [ErrorSeverity],
					'' AS [ErrorState],
					'' AS [ErrorProcedure],
					'' AS [ErrorLine],
					'Success' AS [ResultMessage]

        COMMIT TRANSACTION;
    END;



END;
