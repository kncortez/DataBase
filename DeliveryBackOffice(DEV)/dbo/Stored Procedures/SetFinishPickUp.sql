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
-- =============================================
-- Author:		<Cristian Suazo>
-- Updated date:<20-03-2025>
-- Description:	<Se pasa a entidades el Json>
-- =============================================
-- =============================================
-- Author:		<Edelman>
-- Updated date:<20-05-2025>
-- Description:	<Recolección por referencia y contenerización flujo POD>
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
    @PickupEmail NVARCHAR(50) = '',
    @ReferencesGuide TblReferencesList READONLY,  
	  @ContainerReferences TblContainerList READONLY,
	  @IdCountry NVARCHAR(2)= 'GT'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @jsonResult NVARCHAR(MAX);
    DECLARE @jsonResult1 NVARCHAR(MAX);
    DECLARE @jsonResult2 NVARCHAR(MAX);
    DECLARE @jsonError NVARCHAR(MAX);
    DECLARE @ValIdPickup INT = NULL;

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
      IdResult  INT,
      [Message] NVARCHAR(500),
      Id        NVARCHAR(20)
    );

    INSERT INTO @responsemessage
    (
      IdResult,
      [Message],
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

        CREATE TABLE #Temp
        (
         Guide     VARCHAR(255),
         [Message] VARCHAR(255),
        );

        CREATE NONCLUSTERED INDEX tempTemp ON #Temp (Guide);

        INSERT INTO #Temp
        (
          Guide,
          [Message]
        )
          EXEC [dbo].[spws_get_validate_guides_pickup]
             @InGuides = @InGuides,
             @IdPickup = @IdPickup,
             @Token = @Token,
			       @ReferencesGuide=@ReferencesGuide,  
	           @ContainerReferences=@ContainerReferences,  
	           @IdCountry=@IdCountry; 

        DECLARE @test INT =
                (
                 SELECT COUNT(*)
                   FROM #Temp
                );

        SET @ValIdPickup = 
        (
          SELECT TOP 1 SchedulePickupId
            FROM FinishPickUpHeader
           WHERE SchedulePickupId = @IdPickup
        )

        IF( EXISTS (SELECT 1 FROM @ReferencesGuide))
          BEGIN
          INSERT INTO [DeliveryBackOffice].[dbo].[FinishPickUpReferenceDetail]
                        (
                        SchedulePickupId
                        ,Reference
                        ,RowStatus
                        ,TokenCreated
                        ,DateCreated
                        ,TokenUpdated
                        ,DateUpdated
                        )
                        SELECT @IdPickup
                              ,ReferenceGuide
                              ,1
                              ,@Token
                              ,GETDATE()
                              ,NULL
                              ,NULL
                          FROM @ReferencesGuide;
          
          END

		IF( EXISTS (SELECT 1 FROM @ContainerReferences))
		BEGIN
		INSERT INTO [DeliveryBackOffice].[dbo].[FinishPickUpContainerDetail]
                  (
                   SchedulePickupId
                   ,Container
                   ,RowStatus
                   ,TokenCreated
                   ,DateCreated
                   ,TokenUpdate
                   ,DateUpdate
                  )
                  SELECT @IdPickup
                         ,ContainerReference
                         ,1
                         ,@Token
                         ,GETDATE()
                         ,NULL
                         ,NULL
                    FROM @ContainerReferences;
		
		END

        IF (@test = 0 AND 
            @ValIdPickup IS NULL )
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
                         ,SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) AS GuideNumber
                         ,REPLACE(SUBSTRING(Item, CHARINDEX('-', Item), LEN(Item)),'-','')  AS GuidePiece
                         ,1
                         ,@Token
                         ,GETDATE()
                         ,NULL
                         ,NULL
                    FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',');

            END TRY
            BEGIN CATCH

                ROLLBACK TRANSACTION;

                -- Retornar mensaje de error

                    SELECT IdResult AS IdResult,  
                            ERROR_MESSAGE() AS [Message] 
                        FROM @responsemessage
                    WHERE Id = 'Invalid'


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
                (
                 CAST(ERROR_MESSAGE() AS VARCHAR(300)),
                 ERROR_NUMBER(),
                 CAST(ERROR_PROCEDURE() AS VARCHAR(100)),
                 ERROR_LINE(),
                 0,
                 0,
                 'SetFinishPickup', GETDATE()
                );

            END CATCH;

            IF @@TRANCOUNT > 0
            BEGIN
                COMMIT TRANSACTION;

                DECLARE @StatusNew INT =
                        (
                            SELECT IdServiceStatus FROM CatServiceStatus WHERE IdServiceStatus = 3
                        );

                UPDATE ServiceManagement
                SET ServiceStatusId = @StatusNew,
                    PuSignaturePath = @PuSignaturePath,
                    CiPuDate = @StartDate,
                    CoPuDate = @EndDate,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                FROM ServiceManagement
                WHERE IdSchedulePickup = @IdPickup;

                
                SELECT 200 as IdResult,
					  'Cambios realizados exitosamente' AS [Message]


            END;



        END;
        ELSE IF (@test > 0)
        BEGIN

            SELECT 412 AS IdResult,
			       Guide AS Guides,
					[Message]
                FROM #Temp
            WHERE Guide IN
                    (
                        SELECT Guide FROM #Temp
                    )

        END
        ELSE IF (@ValIdPickup IS NOT NULL)
        BEGIN

            SELECT  413 AS IdResult,
					@IdPickup AS Error,
					'El id de servicio de recolección ya ha sido procesado anteriormente' AS [Message]
  
        END

    IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
       DROP TABLE #Temp;
END;