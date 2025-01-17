-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-10-15>
-- Description:	<Se validan las piezas que se van a procesar para la nueva APP de escaneo>
-- =============================================
-- Author:		<Brandon Pedroza>
-- Modified:	<2025-01-09>
-- Description:	<Contenerizar guias - Se agrega parametro que indica numero de referencia y numero de contenedor>
-- =============================================
CREATE PROCEDURE [dbo].[SetValidPickUpPiece]
    @InGuides NVARCHAR(MAX) = 'FD9559566-1,FD9559566-2',
    @IdPickup INT = NULL,
    @Token NVARCHAR(200) = NULL,
    @IdCountry NVARCHAR(2) = 'GT',
	@Container NVARCHAR(150) = NULL,
	@Reference NVARCHAR(150) = NULL
AS
BEGIN
    BEGIN TRY
        DECLARE @NoPiece INT,
                @NoPieceEntered INT,
                @TokenAct INT,
                @hourtoken INT,
                @IspickupGuide INT,
                @GuideNumber INT,
                @Valid INT,
                @ValidCountry INT,
                @GuideSerie NVARCHAR(2) = 'FD',
				@InContainerGuides NVARCHAR(MAX) = ''

        IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
            DROP TABLE #Temp;

        IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
            DROP TABLE #listGuides;

		IF OBJECT_ID('tempdb.dbo.#TempContainerGuides', 'U') IS NOT NULL
            DROP TABLE #TempContainerGuides;

        SELECT TOP 1
            @TokenAct = RowStatus,
            @hourtoken = DATEDIFF(HOUR, DateCreated, GETDATE())
        FROM LogTokenPOD WITH (NOLOCK)
        WHERE LogTokenPOD = @Token 
        ORDER BY DateCreated DESC

        IF ((@TokenAct = 1 AND @hourtoken <= 8) OR 1 = 1)
        BEGIN
            CREATE TABLE #Temp
            (
                Guide VARCHAR(255),
                Message VARCHAR(255),
            );
			CREATE TABLE #TempContainerGuides (
				GuideSerie NVARCHAR(2),
				GuideNumber INT,
				NoPiece INT
			);

			CREATE NONCLUSTERED INDEX tempTemp ON #Temp (Guide);
			CREATE NONCLUSTERED INDEX tempContainerGuide ON #TempContainerGuides (GuideSerie, GuideNumber);

			--BUSCAR GUIAS POR REFERENCIA  Y POR CONTENEDOR
			DECLARE @ListContainer TblContainerList; 
			DECLARE @ListReferences TblReferencesList;
			INSERT INTO @ListContainer VALUES (@Container); 
			INSERT INTO @ListReferences VALUES (@Reference);

			INSERT INTO #TempContainerGuides
			EXEC GetGuidesByContainerByReference @ListContainer, @ListReferences, @IdCountry;

			SET @InContainerGuides = (SELECT STRING_AGG(CONCAT(GuideSerie, GuideNumber, '-', NoPiece), ',')
					FROM #TempContainerGuides);
			IF (@Reference IS NOT NULL)
			BEGIN
				SET @InGuides = CONCAT(@InGuides,',',@InContainerGuides)			
				SET @InGuides = IIF(@InContainerGuides<>'',@InGuides,LEFT(@InGuides, LEN(@InGuides) - 1))
				SET @InGuides = IIF(LEFT(@InGuides,1)<>',',@InGuides, SUBSTRING(@InGuides, 2, LEN(@InGuides)) )
			END
			--
            INSERT INTO #Temp
            (
                Guide,
                Message
            )
            --Validacion de estado de la guia
            EXEC [dbo].[spws_get_validate_guides_pickup] @InGuides = @InGuides,
                                                         @IdPickup = @IdPickup,
                                                         @Token = @Token,
														 @ReferencesGuide =		@ListReferences,
														 @ContainerReferences = @ListContainer,
														 @IdCountry =			@IdCountry;


            SET @Valid =
            (
                SELECT COUNT(*) FROM #Temp
            )

            IF @Valid = 0
            BEGIN
                CREATE TABLE #listGuides
                (
                    ItemSerie NVARCHAR(2),
                    ItemNumber INT
                );

                CREATE NONCLUSTERED INDEX templistGuides_Piece495
                ON #listGuides
                (
                    ItemSerie,
                    ItemNumber
                );

                INSERT INTO #listGuides 
                (
                    ItemSerie,
                    ItemNumber
                )
                SELECT 
					SUBSTRING(Item, 1, 2) AS ItemSerie,
					CASE 
						WHEN CHARINDEX('-', Item) = 0 
						THEN CAST(SUBSTRING(Item, 3, LEN(Item)) AS INT)
						ELSE CAST(SUBSTRING(Item, 3, CHARINDEX('-', Item) - 3) AS INT)
					END AS ItemNumber
				FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',');

				--VALIDAR SI ES CONTENEDOR
				IF @Container IS NOT NULL
				BEGIN
					IF EXISTS (SELECT 1 FROM #TempContainerGuides)
					BEGIN						
						SELECT 
							200 AS [StatusCode],
							'Contenedor válido, listo para procesar' AS [Message],
							1 AS [NoPiece]
						RETURN
					END
					ELSE
					BEGIN
						SELECT 
							0 AS [StatusCode],
							'Contenedor no existe' AS [Message]
						RETURN
					END
				END

                --Validamos la cantidad de piezas que debe de escanear de 1 guia

                SELECT TOP 1
                    @GuideNumber = ItemNumber
                FROM #listGuides WITH (NOLOCK)

                SELECT @NoPiece = COUNT(NoPiece)
                FROM DeliveryOrderPiece WITH (NOLOCK)
                WHERE GuideNumber = @GuideNumber
                      AND GuideSerie = @GuideSerie

                SELECT @NoPieceEntered = COUNT(*)
                FROM #listGuides

                SELECT @ValidCountry = MAX(   CASE
                                                  WHEN DO.SenderCountryId = @IdCountry THEN
                                                      1
                                                  ELSE
                                                      0
                                              END
                                          )
                FROM DeliveryOrder DO WITH (NOLOCK)
                    INNER JOIN #listGuides LS
                        ON DO.Guide_Serie = LS.ItemSerie
                           AND DO.Guide_Number = LS.ItemNumber

                -- SE VALIDA EL PAIS
                IF @ValidCountry = 1
                BEGIN
                    --VALIDAMOS QUE LA GUIA CUENTE CON LA MISMA CANTIDAD DE PIEZAS INGRESADAS		
                    IF @NoPiece = @NoPieceEntered
                    BEGIN
                        SELECT @IspickupGuide = MAX(CAST(ISNULL(DP.IsPickup, 0) AS INT))
                        FROM DeliveryOrderPiece DP WITH (NOLOCK)
                            INNER JOIN #listGuides LS
                                ON DP.GuideSerie = LS.ItemSerie
                                   AND DP.GuideNumber = LS.ItemNumber
                        IF @IspickupGuide = 0
                        BEGIN
                            SELECT 200 AS StatusCode,
                                   'Piezas validas, listas para procesarlas' AS Message,
								   @NoPiece AS NoPiece

                        END
                        ELSE
                        BEGIN
                            SELECT 0 AS StatusCode,
                                   'Se encuentran piezas que ya fueron procesadas' AS Message
                        END
                    END
                    ELSE IF @NoPiece < @NoPieceEntered
                    BEGIN
                        SELECT 0 StatusCode,
                               CONCAT('La guia tiene más piezas de las establecidas No. Piezas: ', @NoPiece) AS Message
                    END
                    ELSE
                    BEGIN
                        SELECT 0 AS StatusCode,
                               CONCAT('Faltan:', @NoPiece - @NoPieceEntered, ' piezas por escanear') AS Message
                    END
                END
                ELSE
                BEGIN
                    SELECT 0 AS StatusCode,
                           'La guia pertenece a otro país' AS Message
                END
            END
            ELSE
            BEGIN
                SELECT 1 AS StatusCode,
					  'Guias no validas' AS Message

                SELECT Message,
                       Guide
                FROM #Temp
            END
        END
        ELSE
        BEGIN
            SELECT 0 AS StatusCode,
                   'El Token no es valido' AS Message
        END

    END TRY
    BEGIN CATCH
        SELECT 0 AS StatusCode,
               ERROR_MESSAGE() AS Message,
               ERROR_LINE() AS ErrorLine
    END CATCH
END