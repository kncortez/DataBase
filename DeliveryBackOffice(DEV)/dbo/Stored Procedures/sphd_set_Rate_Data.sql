
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
    @STDLoc DECIMAL(12, 2) = 0,
    @STDMet DECIMAL(12, 2) = 0,
    @STDFor DECIMAL(12, 2) = 0,
	@STDEsp DECIMAL(12, 2) = 0,
    @CODLoc DECIMAL(12, 2) = 0,
    @CODMet DECIMAL(12, 2) = 0,
    @CODFor DECIMAL(12, 2) = 0,
    @CODEsp DECIMAL(12, 2) = 0,
	@CODLocCOD DECIMAL(12, 2) = 0,
    @CODMetCOD DECIMAL(12, 2) = 0,
    @CODForCOD DECIMAL(12, 2) = 0,
    @CODEspCOD DECIMAL(12, 2) = 0,
    @CODExcentLoc DECIMAL(12, 2) = 0,
    @CODExcentMet DECIMAL(12, 2) = 0,
    @CODExcentFor DECIMAL(12, 2) = 0,
	@CODExcentEsp DECIMAL(12, 2) = 0,
    @TblArticleRate AS TblArticleRate READONLY,
	@TblWeightRate AS TblWeightRate READONLY
AS
BEGIN
	DECLARE @STD INT =
            (
                SELECT TOP (1)
                       cs.CtsId
                FROM dbo.CatTypeService cs
                WHERE cs.CtsShortName = 'STD'
                ORDER BY cs.CtsId
            );

	DECLARE @COD INT =
            (
                SELECT TOP (1)
                       cs.CtsId
                FROM dbo.CatTypeService cs
                WHERE cs.CtsShortName = 'COD'
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

	DECLARE @ESP INT =
            (
                SELECT TOP (1)
                       cs.CrsId
                FROM dbo.CatRateSegment cs
                WHERE cs.CrsShortName = 'ESP'
                ORDER BY cs.CrsId
            );

    PRINT 'inicia la transaccion ';
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Insertar/actualizar encabezador-----/
        IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.RateHeader WHERE RheId = @IdRate) -- se debe insertar un nuevo registro
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

            -- insertar tarifas todo destino y por articulo STD
            IF @STDLoc > 0
            BEGIN
                IF EXISTS
                (
                    SELECT TOP 1 1
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @STD
                          AND TypeSegmentId = @LOC
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @STDLoc,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @STD
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
                    (@IdRate, @STD, @LOC, @STDLoc, 1, @Token, GETDATE());
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
                      AND TypeServiceId = @STD
                      AND TypeSegmentId = @LOC;
            END;
            IF @STDMet > 0
            BEGIN
                IF EXISTS
                (
                    SELECT TOP 1 1
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @STD
                          AND TypeSegmentId = @MET
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @STDMet,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @STD
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
                    (@IdRate, @STD, @MET, @STDMet, 1, @Token, GETDATE());
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
                      AND TypeServiceId = @STD
                      AND TypeSegmentId = @MET;
            END;
            IF @STDFor > 0
            BEGIN
                IF EXISTS
                (
                    SELECT TOP 1 1
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @STD
                          AND TypeSegmentId = @FOR
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @STDFor,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @STD
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
                    (@IdRate, @STD, @FOR, @STDFor, 1, @Token, GETDATE());
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
                      AND TypeServiceId = @STD
                      AND TypeSegmentId = @FOR;
            END;
			IF @STDEsp > 0
            BEGIN
                IF EXISTS
                (
                    SELECT TOP 1 1
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @STD
                          AND TypeSegmentId = @ESP
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @STDEsp,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @STD
                          AND TypeSegmentId = @ESP;
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
                    (@IdRate, @STD, @ESP, @STDEsp, 1, @Token, GETDATE());
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
                      AND TypeServiceId = @STD
                      AND TypeSegmentId = @ESP;
            END;

			-- insertar tarifas todo destino y por articulo COD
            IF @CODLoc > 0
            BEGIN
                IF EXISTS
                (
                    SELECT TOP 1 1
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @COD
                          AND TypeSegmentId = @LOC
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @CODLoc,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @COD
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
                    (@IdRate, @COD, @LOC, @CODLoc, 1, @Token, GETDATE());
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
                      AND TypeServiceId = @COD
                      AND TypeSegmentId = @LOC;
            END;
            IF @CODMet > 0
            BEGIN
                IF EXISTS
                (
                    SELECT TOP 1 1
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @COD
                          AND TypeSegmentId = @MET
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @CODMet,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @COD
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
                    (@IdRate, @COD, @MET, @CODMet, 1, @Token, GETDATE());
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
                      AND TypeServiceId = @COD
                      AND TypeSegmentId = @MET;
            END;
            IF @CODFor > 0
            BEGIN
                IF EXISTS
                (
                    SELECT TOP 1 1
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @COD
                          AND TypeSegmentId = @FOR
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @CODFor,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @COD
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
                    (@IdRate, @COD, @FOR, @CODFor, 1, @Token, GETDATE());
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
                      AND TypeServiceId = @COD
                      AND TypeSegmentId = @FOR;
            END;
			IF @CODEsp > 0
            BEGIN
                IF EXISTS
                (
                    SELECT TOP 1 1
                    FROM dbo.RateData rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @COD
                          AND TypeSegmentId = @ESP
                )
                BEGIN
                    UPDATE dbo.RateData
                    SET RateValue = @CODEsp,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @COD
                          AND TypeSegmentId = @ESP;
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
                    (@IdRate, @COD, @ESP, @CODEsp, 1, @Token, GETDATE());
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
                      AND TypeServiceId = @COD
                      AND TypeSegmentId = @ESP;
            END;

            IF @CODLocCOD > 0
            BEGIN
                IF EXISTS
                (
                    SELECT TOP 1 1
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @COD
                          AND TypeSegmentId = @LOC
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @CODLocCOD,
						CODExempt = @CODExcentLoc,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @COD
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
                        @COD,             -- TypeServiceId - int
                        @LOC,             -- TypeSegmentId - int
                        @CODLocCOD,       -- CODRate - decimal(12, 2)
                        @CODExcentLoc, -- CODExempt - decimal(12, 2)
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
                      AND TypeServiceId = @COD
                      AND TypeSegmentId = @LOC;
            END;
            IF @CODMetCOD > 0
            BEGIN
                IF EXISTS
                (
                    SELECT TOP 1 1
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @COD
                          AND TypeSegmentId = @MET
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @CODMetCOD,
						CODExempt = @CODExcentMet,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @COD
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
                        @COD,             -- TypeServiceId - int
                        @MET,             -- TypeSegmentId - int
                        @CODMetCOD,       -- CODRate - decimal(12, 2)
                        @CODExcentMet, -- CODExempt - decimal(12, 2)
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
                      AND TypeServiceId = @COD
                      AND TypeSegmentId = @MET;
            END;
            IF @CODForCOD > 0
            BEGIN
                IF EXISTS
                (
                    SELECT TOP 1 1
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @COD
                          AND TypeSegmentId = @FOR
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @CODForCOD,
						CODExempt = @CODExcentFor,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @COD
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
                        @COD,             -- TypeServiceId - int
                        @FOR,             -- TypeSegmentId - int
                        @CODForCOD,       -- CODRate - decimal(12, 2)
                        @CODExcentFor, -- CODExempt - decimal(12, 2)
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
                      AND TypeServiceId = @COD
                      AND TypeSegmentId = @FOR;
            END;
			IF @CODEspCOD > 0
            BEGIN
                IF EXISTS
                (
                    SELECT TOP 1 1
                    FROM dbo.RateCOD rd
                    WHERE rd.RateId = @IdRate
                          AND TypeServiceId = @COD
                          AND TypeSegmentId = @ESP
                )
                BEGIN
                    UPDATE dbo.RateCOD
                    SET CODRate = @CODEspCOD,
						CODExempt = @CODExcentEsp,
                        RowStatus = 1,
                        TokenUpdated = @Token,
                        DateUpdated = GETDATE()
                    WHERE RateId = @IdRate
                          AND TypeServiceId = @COD
                          AND TypeSegmentId = @ESP;
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
                        @COD,             -- TypeServiceId - int
                        @ESP,             -- TypeSegmentId - int
                        @CODEspCOD,       -- CODRate - decimal(12, 2)
                        @CODExcentEsp, -- CODExempt - decimal(12, 2)
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
                      AND TypeServiceId = @COD
                      AND TypeSegmentId = @ESP;
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

			--rango de pesos
			PRINT 'RANGO DE PESOS'

			--Eliminar rango de pesos STD
			UPDATE rd
			SET rd.RowStatus = 'FALSE'
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE rd.RateId = @IdRate
			AND twr.CatTypeService = 1
			AND rd.TypeServiceId = @STD
			AND twr.State = 3

			--Eliminar rango de pesos COD
			UPDATE rd
			SET rd.RowStatus = 'FALSE'
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE rd.RateId = @IdRate
			AND twr.CatTypeService = 2
			AND rd.TypeServiceId = @COD
			AND twr.State = 3

			--Actualizar rango de pesos STD LOCAL
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Local
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 1  --STD en desktop
			AND rd.TypeServiceId = @STD
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @LOC
			AND twr.State = 2

			--Actualizar rango de pesos STD MET
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Metro
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 1  --STD en desktop
			AND rd.TypeServiceId = @STD
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @MET
			AND twr.State = 2

			--Actualizar rango de pesos STD FOR
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Foraneo
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 1  --STD en desktop
			AND rd.TypeServiceId = @STD
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @FOR
			AND twr.State = 2

			--Actualizar rango de pesos STD ESP
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Foraneo
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 1  --STD en desktop
			AND rd.TypeServiceId = @STD
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @ESP
			AND twr.State = 2

			--Actualizar rango de pesos COD LOCAL
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Local
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 2  --COD en desktop
			AND rd.TypeServiceId = @COD
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @LOC
			AND twr.State = 2

			--Actualizar rango de pesos COD MET
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Metro
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 2  --COD en desktop
			AND rd.TypeServiceId = @COD
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @MET
			AND twr.State = 2

			--Actualizar rango de pesos COD FOR
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Foraneo
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 2  --COD en desktop
			AND rd.TypeServiceId = @COD
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @FOR
			AND twr.State = 2

			--Actualizar rango de pesos COD ESP
			UPDATE rd
			SET rd.WeightTo = twr.WeightTo
			   ,rd.RateValue = twr.Foraneo
			   ,rd.TokenUpdated = @Token
			   ,rd.DateUpdated = GETDATE()
			FROM RateData rd
			JOIN @TblWeightRate twr
				ON twr.WeightFrom = rd.WeightFrom
			WHERE twr.CatTypeService = 2  --COD en desktop
			AND rd.TypeServiceId = @COD
			AND rd.WeightFrom = twr.WeightFrom
			AND rd.TypeSegmentId = @ESP
			AND twr.State = 2
			
			--Insertar rango de pesos STD LOC
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@STD
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

			--Insertar rango de pesos STD MET
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@STD
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

			--Insertar rango de pesos STD FOR
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@STD
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

			--Insertar rango de pesos STD ESP
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@STD
				   ,@ESP
				   ,Foraneo --AGREGAR ESP
				   ,'TRUE'
				   ,@Token
				   ,GETDATE()
				   ,WeightFrom
				   ,WeightTo
				FROM @TblWeightRate
				WHERE CatTypeService = 1
				AND State = 1

			--Insertar rango de pesos COD LOC
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@COD
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

			--Insertar rango de pesos COD MET
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@COD
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

			--Insertar rango de pesos COD FOR
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@COD
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

			--Insertar rango de pesos COD Esp
			INSERT INTO RateData (RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated, WeightFrom, WeightTo)
				SELECT
					@IdRate
				   ,@COD
				   ,@FOR
				   ,Foraneo --AGREGAR ESP
				   ,'TRUE'
				   ,@Token
				   ,GETDATE()
				   ,WeightFrom
				   ,WeightTo
				FROM @TblWeightRate
				WHERE CatTypeService = 2
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
