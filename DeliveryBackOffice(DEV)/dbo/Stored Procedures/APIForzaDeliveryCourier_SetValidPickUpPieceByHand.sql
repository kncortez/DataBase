/* =================================================
   SP:        [dbo].[APIForzaDeliveryCourier_SetValidPickUpPieceByHand]
   Propósito: Se validan las piezas que se van a procesar para Recolección manual de escaneo 
   Autor:     Caleb Loarca
   Historia:  <FDAPI-5679>
   Fecha:     2026-03-30

=== CHANGELOG ============================
2026-03-30 | Historia/épica: FDAPI-5679  | Autor: Caleb Loarca | Se usa de base SetValidPickUpPiece, para este nuevo SP.
2026-04-23 | Historia/épica: FDAPI-6121  | Autor: Mario Herrarte | Se retorna la cantidad de piezas de la guia.
=========================================== */

ALTER PROCEDURE [dbo].[APIForzaDeliveryCourier_SetValidPickUpPieceByHand]
    @InGuides NVARCHAR(MAX) = 'FD9559566-1,FD9559566-2',   
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
				@InContainerGuides NVARCHAR(MAX) = '',
                @PiecesDry INT;
			


        IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
            DROP TABLE #Temp;

        IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
            DROP TABLE #listGuides;

		IF OBJECT_ID('tempdb.dbo.#TempContainerGuides', 'U') IS NOT NULL
            DROP TABLE #TempContainerGuides;


        WITH t AS (
            SELECT TOP 1 RowStatus, DateCreated
              FROM DeliveryBackOffice.dbo.LogTokenPOD WITH (NOLOCK)
             WHERE LogTokenPOD = @Token					 
             ORDER BY DateCreated DESC
        )
        SELECT @TokenAct  = t.RowStatus,
               @hourtoken = DATEDIFF(HOUR, t.DateCreated, GETDATE())
          FROM t
        OPTION (RECOMPILE);

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
			
			--BUSCAR GUIAS POR REFERENCIA  Y POR CONTENEDOR
			DECLARE @ListContainer TblContainerList; 
			DECLARE @ListReferences TblReferencesList;
			INSERT INTO @ListContainer VALUES (@Container); 
			INSERT INTO @ListReferences VALUES (@Reference);

			INSERT INTO #TempContainerGuides			
			EXEC [dbo].[APIForzaDeliveryCourier_GetGuidesByContainerByReferenceByHand] @ListContainer, @ListReferences, @IdCountry;
						
			CREATE NONCLUSTERED INDEX tempContainerGuide ON #TempContainerGuides (GuideSerie, GuideNumber);


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
            EXEC [dbo].[spws_get_validate_guides_pickupByHand] @InGuides = @InGuides,                                                         
                                                         @Token = @Token,
														 @ReferencesGuide =		@ListReferences,
														 @ContainerReferences = @ListContainer,
														 @IdCountry =			@IdCountry;

			CREATE NONCLUSTERED INDEX tempTemp ON #Temp (Guide);

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
							
			
				--validar si guia es del cliente
				IF @Container IS NULL
				BEGIN
					IF NOT EXISTS (SELECT 1 FROM DeliveryOrder DO WITH (NOLOCK)
									INNER JOIN #listGuides LS
									ON DO.Guide_Serie = LS.ItemSerie
								AND DO.Guide_Number = LS.ItemNumber)
					BEGIN						
						SELECT 
							2 AS [StatusCode],
							'La Guia no existe' AS [Message],
							1 AS [NoPiece],
                            null AS TotalPiecesDry
						RETURN
					END
					ELSE
					BEGIN
						IF @Reference IS NOT NULL
						BEGIN
							IF NOT EXISTS (SELECT 1 FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
											INNER JOIN #listGuides LS
											ON DO.Guide_Serie = LS.ItemSerie
										AND DO.Guide_Number = LS.ItemNumber)										
							BEGIN						
								SELECT 
									3 AS [StatusCode],
									'La Guia no pertenece al cliente de la recoleccion' AS [Message],
									1 AS [NoPiece],
                                    null AS TotalPiecesDry
								RETURN
							END
						END
					END

				END


				--VALIDAR SI ES CONTENEDOR
				IF @Container IS NOT NULL
				BEGIN

					IF NOT EXISTS(SELECT 1 FROM DeliveryBackOffice.dbo.ShippingContainer WITH(NOLOCK) WHERE ReferenceContainer =@Container)
					BEGIN
						SELECT 
							2 AS [StatusCode],
							'El contenedor no existe' AS [Message],
                            null AS TotalPiecesDry
						RETURN
					END
					ELSE
					BEGIN
						IF EXISTS (SELECT 1 FROM #TempContainerGuides)
							BEGIN						
								IF(EXISTS(SELECT 1 FROM DeliveryBackOffice.dbo.FinishPickUpContainerDetail WITH(NOLOCK) WHERE Container = @Container))
						        BEGIN
						      
                                    SELECT 
                                            2 AS [StatusCode],
                                            'El contenedor ya esta recolectado' AS [Message],
                                            null AS TotalPiecesDry
                                    RETURN

                                END
                                        ELSE
                                        SELECT 
                                            200 AS [StatusCode],
                                            'Contenedor válido, listo para procesar' AS [Message],
                                            1 AS [NoPiece],
                                            1 AS TotalPiecesDry
                                        RETURN
                                    END
						ELSE
						BEGIN
							SELECT 
								3 AS [StatusCode],
								'Contenedor no pertenece al cliente de la recoleccion' AS [Message],
                                null AS TotalPiecesDry
							RETURN
						END
						
					END
				END

                --Validamos la cantidad de piezas que debe de escanear de 1 guia

                SELECT TOP 1
                    @GuideNumber = ItemNumber
                FROM #listGuides WITH (NOLOCK)

                SELECT @NoPiece = COUNT(NoPiece)
                FROM DeliveryBackOffice.dbo.DeliveryOrderPiece WITH (NOLOCK)
                WHERE GuideNumber = @GuideNumber
                      AND GuideSerie = @GuideSerie

                SELECT @NoPieceEntered = COUNT(*)
                FROM #listGuides

                SELECT @PiecesDry = Pieces_Dry FROM DeliveryOrder DO WITH (NOLOCK)
                                WHERE DO.Guide_Serie = @GuideSerie
                                    AND DO.Guide_Number = @GuideNumber

                SELECT @ValidCountry = MAX(   CASE
                                                  WHEN DO.SenderCountryId = @IdCountry THEN
                                                      1
                                                  ELSE
                                                      0
                                              END
                                          )
                FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
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
                        FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DP WITH (NOLOCK)
                            INNER JOIN #listGuides LS
                                ON DP.GuideSerie = LS.ItemSerie
                                   AND DP.GuideNumber = LS.ItemNumber
                        IF @IspickupGuide = 0
                        BEGIN
                            SELECT 200 AS StatusCode,
                                   'Piezas validas, listas para procesarlas' AS Message,
								   @NoPiece AS NoPiece,
                                   @PiecesDry AS TotalPiecesDry

                        END
                        ELSE
                        BEGIN
                            SELECT 0 AS StatusCode,
                                   'Se encuentran piezas que ya fueron procesadas' AS Message,
                                   @PiecesDry AS TotalPiecesDry
                        END
                    END
                    ELSE IF @NoPiece < @NoPieceEntered
                    BEGIN
                        SELECT 0 StatusCode,
                               CONCAT('La guia tiene más piezas de las establecidas No. Piezas: ', @NoPiece) AS Message,
                               @PiecesDry AS TotalPiecesDry
                    END
                    ELSE
                    BEGIN
                        SELECT 4 AS StatusCode,
                               CONCAT('Faltan:', @NoPiece - @NoPieceEntered, ' piezas por escanear') AS Message,
                               @PiecesDry AS TotalPiecesDry
                    END
                END
                ELSE
                BEGIN
                    SELECT 0 AS StatusCode,
                           'La guia pertenece a otro país' AS Message,
                           null AS TotalPiecesDry
                END
            END
            ELSE
            BEGIN
                SELECT 1 AS StatusCode,
					  'Guias no validas' AS Message,
                      null AS TotalPiecesDry

                SELECT Message,
                       Guide
                FROM #Temp
            END
        END
        ELSE
        BEGIN
            SELECT 0 AS StatusCode,
                   'El Token no es valido' AS Message,
                   null AS TotalPiecesDry
        END

    END TRY
    BEGIN CATCH
        SELECT 0 AS StatusCode,
               ERROR_MESSAGE() AS Message,
               ERROR_LINE() AS ErrorLine
    END CATCH
END
