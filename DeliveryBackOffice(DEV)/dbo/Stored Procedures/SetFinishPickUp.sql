-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-02-06>
-- Description:	<Finaliza el proceso de recoleccion insertando informacion en las tablas de costos>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-01-27>
-- Description:	< Actualización de logica para registro de pagos en efectivo desde CourierApp >
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-02-10>
-- Description:	< Manejo correcto de voucher y registro de pago >
-- =============================================
-- =============================================
-- Author:		<Michael,Espinoza>
-- Create date: <2022-02-10>
-- Description:	< Integracion de logica que permitira generar un manifiesto de piezas escaneada >
-- =============================================
-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2022-06-20>
-- Description:	<Agregar filtro para validar que no tiene pagos de TC o Datafono, en dbo.CostDetail>
-- =============================================
-- Author:		<Tito Garcia>
-- Updated date:<18-11-2024>
-- Description:	<Se agrega nueva validación IsCompleted>
-- =============================================
CREATE PROCEDURE [dbo].[SetFinishPickUp]
    -- Add the parameters for the stored procedure here
    @InGuides NVARCHAR(MAX) = 'FD22221,FD22361,FD22223,FD22359,FD22226',
    @IdPickup INT = 2,
    @TypeofInOutMoneyId INT = 1,
    --	@IdStatusPickup int = 3,
    @Token VARCHAR(200) = NULL,
    @Observations VARCHAR(200) = NULL,
    @Amount DECIMAL(12, 2) = 0,
    @Voucher NVARCHAR(200) = ' ',
    @PuSignaturePath NVARCHAR(250) = ' ',
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @PickupLatitude NVARCHAR(20) = NULL,
    @PickupLongitude NVARCHAR(20) = NULL,
    @PickupEmail NVARCHAR(50) = ''
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @jsonResult NVARCHAR(MAX);
    DECLARE @jsonResult1 NVARCHAR(MAX);
    DECLARE @jsonResult2 NVARCHAR(MAX);
    DECLARE @jsonError NVARCHAR(MAX);
    DECLARE @jsonToken NVARCHAR(MAX);
    DECLARE @ManifestSerie VARCHAR(10) = 'FM';
    DECLARE @ManifestNumber BIGINT;

    DECLARE @CodeOfReference INT;
    DECLARE @CourierID INT;


    PRINT 'validar token';
    -- insertar en tabla temporal posbibles mensajes de respuesta
    --IF OBJECT_ID('tempdb.dbo.#UpdateNow', 'U') IS NOT NULL DROP TABLE #UpdateNow;
    IF OBJECT_ID('tempdb.dbo.#NowInsert', 'U') IS NOT NULL
        DROP TABLE #NowInsert;
    IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL
        DROP TABLE #responsemessage;
    IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
        DROP TABLE #Temp;

    DECLARE @responsemessage AS TABLE
    (
        IdResult INT,
        Message NVARCHAR(500),
        Id NVARCHAR(20)
    );

    INSERT INTO @responsemessage
    (
        IdResult,
        Message,
        Id
    )
    SELECT *
      FROM (
            SELECT 200 AS IdResult,
                   'Estado  cambiado correctamente' AS Message,
                   'OK' AS Id
             UNION
            SELECT 500 AS IdResult,
                   'Error faltal intente de nuevo mas tarde' AS Message,
                   'Transac' AS Id
           ) AS errror;

    DECLARE @TokenAct INT =
            (
                SELECT TOP 1
                       RowStatus
                FROM LogTokenPOD
                WHERE LogTokenPOD LIKE '%' + @Token + '%'
                ORDER BY DateCreated DESC
            );
    DECLARE @hourtoken INT =
            (
                SELECT TOP 1
                       DATEDIFF(HOUR, DateCreated, GETDATE()) AS horas
                FROM LogTokenPOD
                WHERE LogTokenPOD LIKE '%' + @Token + '%'
            );


    -- Variables para verificar ubicación en geocerca
    DECLARE @FixedLatitude NVARCHAR(20) = @PickupLatitude;
    DECLARE @FixedLongitude NVARCHAR(20) = @PickupLongitude;

    IF ((@TokenAct = 1 AND @hourtoken <= 8) OR 1 = 1)
    BEGIN
        CREATE TABLE #Temp
        (
            Guide VARCHAR(255),
            Message VARCHAR(255),
        );

        CREATE NONCLUSTERED INDEX tempTemp ON #Temp (Guide);

        INSERT INTO #Temp
        (
            Guide,
            Message
        )
        EXEC [dbo].[spws_get_validate_guides_pickup]
             @InGuides = @InGuides,
             @IdPickup = @IdPickup,
             @Token = @Token;

        DECLARE @test INT =
                (
                 SELECT COUNT(*)FROM #Temp
                );

        IF (@test = 0)
        BEGIN
            BEGIN TRANSACTION;
            BEGIN TRY

                  DECLARE @Status INT =
                          (
                           SELECT IdServiceStatus
                             FROM CatServiceStatus
                            WHERE IdServiceStatus = 2
                          );

                          ---SE REALIZA EL INSERT
                  INSERT INTO DeliveryBackOffice.dbo.FinishPickUpHeader
                  (
                   SchedulePickupId
                  ,TypeofInOutMoneyId
                  ,Amount
                  ,[Signature]
                  ,StartDate
                  ,EndDate
                  ,PickupEmail
                  ,PickupLatitude
                  ,PickupLongitude
                  ,ServiceStatusId
                  ,Observation
                  ,Voucher
                  ,RowStatus
                  ,TokenCreated
                  ,DateCreated
                  ,TokenUpdated
                  ,DateUpdated
                  )
                  VALUES
                  (
                    @IdPickup
                    ,@TypeofInOutMoneyId
                    ,@Amount
                    ,@PuSignaturePath
                    ,@StartDate
                    ,@EndDate
                    ,@PickupEmail
                    ,@PickupLatitude
                    ,@PickupLongitude
                    ,@Status
                    ,@Observations
                    ,@Voucher
                    ,1
                    ,@Token
                    ,GETDATE()
                    ,NULL
                    ,NULL
                  )

                  INSERT INTO FinishPickUpDetail
                  (
                   SchedulePickupId
                   ,GuideSerie
                   ,GuideNumber
                   ,GuidePiece
                   ,RowStatus
                   ,TokenCreated
                   ,DateCreated
                   ,TokenUpdated
                   ,DateUpdated
                  )
                  SELECT @IdPickup
                         ,SUBSTRING(Item, 1, 2) AS GuideSerie
                         ,SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) AS GuideNumber -- Extrae el número de la guía
                         ,REPLACE(SUBSTRING(Item, CHARINDEX('-', Item), LEN(Item)),'-','')  AS GuidePiece -- Extrae la pieza
                         ,1
                         ,@Token
                         ,GETDATE()
                         ,NULL
                         ,NULL
                    FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',');

            END TRY
            BEGIN CATCH

                ROLLBACK TRANSACTION;

                SELECT ERROR_MESSAGE();

                -- Retornar mensaje de error
                SET @jsonResult =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"Message":"'
                                               + CONVERT(NVARCHAR(MAX), ERROR_MESSAGE()) + '"}'
                                        FROM @responsemessage
                                        WHERE Id = 'Invalid'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                )
                );

                INSERT INTO dbo.RoutePreparationLogError
                (
                    ErrorDescription,
                    ErrorNumber,
                    ErrorProcedure,
                    ErrorLine,
                    GuideSerie,
                    GuideNumber,
                    TokenCreated,
                    DateCreated
                )
                VALUES
                (CAST(ERROR_MESSAGE() AS VARCHAR(300)), ERROR_NUMBER(), CAST(ERROR_PROCEDURE() AS VARCHAR(100)),
                 ERROR_LINE(), 0, 0, 'SetFinishPickup', GETDATE());

            END CATCH;

            IF @@TRANCOUNT > 0
            BEGIN
                COMMIT TRANSACTION;

                SET @jsonResult =
                (
                  SELECT STUFF(
                               (
                                   SELECT ',{"Message":"Cambios realizados exitosamente"}'
                                   FOR XML PATH(''), TYPE
                               ).value('.', 'varchar(max)'),
                               1,
                               1,
                               ''
                              )
                );

            END;

            -- Devuelve la respuesta
            SELECT ('[' + @jsonResult + ']') jsonResult;

        END;

        ELSE IF (@test > 0)
        BEGIN
            SET @jsonResult1 =
            (
                SELECT STUFF(
                              (
                               SELECT ',{"Error":"' + ISNULL(CONVERT(VARCHAR, Guide), 'N/A') + +'"}'
                               FROM #Temp
                               WHERE Guide IN
                                     (
                                         SELECT Guide FROM #Temp
                                     )
                               FOR XML PATH(''), TYPE
                              ).value('.', 'varchar(max)'),
                              1,
                              1,
                              ''
                            )
            );

            PRINT @jsonResult1;

            SET @jsonResult2 =
            (
                SELECT STUFF(
                              (
                                  SELECT ',{"Message":"' + ISNULL(CONVERT(NVARCHAR(MAX), Message), 'N/A') + +'"}'
                                  FROM #Temp
                                  WHERE Guide IN
                                        (
                                            SELECT Guide FROM #Temp
                                        )
                                  FOR XML PATH(''), TYPE
                              ).value('.', 'varchar(max)'),
                              1,
                              1,
                              ''
                            )
            );

            PRINT @jsonResult2;
            SET @jsonError =
            (
                SELECT STUFF(
                             (
                                 SELECT '{"IdResult":412' + ',' + '"Guides":[' + @jsonResult1 + '],' + '"Messege":['
                                        + @jsonResult2 + ']' + ''
                                 FOR XML PATH(''), TYPE
                             ).value('.', 'varchar(max)'),
                             1,
                             1,
                             ''
                            )
            );
            PRINT @jsonError;

            SELECT ('{' + @jsonError + '}') jsonError;

        END;



    END;
    ELSE IF (@TokenAct = 0 OR @TokenAct IS NULL OR @hourtoken > 8)
    BEGIN
        PRINT 'token inválido';
        SET @jsonToken =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"IdResult":' + '403' + ',' + '"DescriptionError":"' + 'Token inválido' + '"'
                                       + '}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
        SELECT '[' + @jsonToken + ']' jsonToken;

        RETURN;
    END;

    IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
       DROP TABLE #Temp;
END;