-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-09-13>
-- Description:	<Asigna una guía a una preparación entrega (Movil)>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_SetRoutePreparationDetail]
    -- Add the parameters for the stored procedure here
    @RouteId INT,
    @Date DATE,
    @GuideSerie NVARCHAR(2)='FD',
    @GuideNumber INT=0,
    @GuidePiece SMALLINT,
    @Token NVARCHAR(50),
    @CountryId NVARCHAR(2)='GT',
	@Reference NVARCHAR(150)='',
    @IdCustomer INT=0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    SET ARITHABORT ON;

    --- Conteo para verificar cantidad correcta de validaciones
    DECLARE @RModified INT = 0;

    --- Variables para manejo de preparación de ruta
    DECLARE @IdManifest INT;
    DECLARE @IdRoutePreparation INT;
    DECLARE @IdRoutePreparationDetail INT;
    DECLARE @IdRoutePreparationDetailPiece INT;
    DECLARE @Country NVARCHAR(2)='GT';

    --- Tabla para validar estado
    DECLARE @StatusGuide TABLE
    (
        StatusCode INT NULL,
        Description NVARCHAR(200)
    );
    DECLARE @StatusOrderId TINYINT;

    --- Variables para manejo de piezas
    DECLARE @GuidePieceExists BIT;
    DECLARE @GuidePieceIsDry BIT;
    DECLARE @CountPiece INT;

    --- Control de procesos abiertos
    DECLARE @IsOpenProcess BIT = 0;
    DECLARE @IsValidOpenProcess BIT = 1;
    DECLARE @UserProcess NVARCHAR(50);

    --- Control para ServiceManagement
    DECLARE @IdServiceManagementDetail BIGINT;
    DECLARE @IdServiceManagement INT;
    DECLARE @CreateServiceManagement BIT = 0;

    --- Control RouteAssignment
    DECLARE @IdRouteAssignment INT;

    --- Control reasignación
    DECLARE @IsReassignment BIT = 0;

    --- Contro procesos abiertos en otras rutas
    DECLARE @CodeOfRoute VARCHAR(100);

 --- Validar referencia unica
	DECLARE @GuideCount INT = 0;
		
		
		IF(@GuideNumber=0)
		BEGIN
			SET @GuideCount 	= ( SELECT
											  COUNT(1)                   
												   FROM [dbo].[DeliveryOrder] do WITH (NOLOCK)
														WHERE do.Ticket_Number = @Reference AND do.Ticket_Number<>'' AND do.Ticket_Number!='0');
          END;

    -- Buscar la guía de la referencia
	      IF (@GuideNumber=0 AND @GuideCount=1 )
         BEGIN
			  SELECT TOP 1  @GuideNumber = Guide_Number 
								FROM [dbo].[DeliveryOrder] WITH (NOLOCK)
									 WHERE Ticket_Number = @Reference
										 ORDER BY DateCreated DESC
	    END
		   
		   IF(@GuideNumber=0 AND @GuideCount>1 AND @IdCustomer>0)
		      BEGIN
				   SELECT
							TOP 1  @GuideNumber =	 do.Guide_Number
						
							   FROM [dbo].[DeliveryOrder] do WITH (NOLOCK)
								  INNER JOIN [dbo].[VisitPointClient] vpc WITH (NOLOCK)
								  ON  do.Sender_ID = vpc.CodeOfReference
									WHERE do.Ticket_Number = @Reference  AND vpc.CustomerID = @IdCustomer
							END;
	 

    BEGIN TRANSACTION;

    BEGIN TRY

       -- Obtener el país al que pertenece la guía
		SELECT  @Country = ISNULL(do.ReceiverCountryId,'GT')
		     FROM [DeliveryOrder] do WITH(NOLOCK)
		WHERE     do.Guide_Serie  = @GuideSerie
              AND do.Guide_Number = @GuideNumber

        --- Verificar si la pieza existe
        SELECT @GuidePieceExists = 1,
               @GuidePieceIsDry = ISNULL(dop.IsDry, 1)
        FROM [DeliveryOrderPiece] dop WITH (NOLOCK)
		INNER JOIN [DeliveryOrder] do WITH(NOLOCK)
		ON dop.GuideSerie =do.Guide_Serie and dop.GuideNumber = do.Guide_Number
        WHERE dop.GuideSerie = @GuideSerie
              AND dop.GuideNumber = @GuideNumber
              AND dop.NoPiece = @GuidePiece
			  AND ISNULL(do.ReceiverCountryId,'GT') = @CountryId

     IF   (@GuideCount > 1 AND @Reference<>'' AND @IdCustomer=0 ) 
     BEGIN


	    SELECT 11 'StatusCode',
                   'Referencia duplicada en más de una guía' 'Description';
	     SELECT
                         do.Guide_Serie 'GuideSerie',
                         do.Guide_Number 'GuideNumber',
						 vpc.CustomerID 'IdCustomer',
						 vpc.DescriptionOfClient 'CustomerName'
                       FROM [dbo].[DeliveryOrder] do WITH (NOLOCK)
					      INNER JOIN [dbo].[VisitPointClient] vpc WITH (NOLOCK)
						  ON  do.Sender_ID = vpc.CodeOfReference
                            WHERE do.Ticket_Number = @Reference;

							COMMIT TRANSACTION;

	 END 
       ELSE IF @GuidePieceExists = 1
        BEGIN
            --- Verificar si esta en un estado válido 
            SET @StatusOrderId =
            (
                SELECT StatusOrderId
                FROM StatusOrder
                WHERE OrderDescription = 'Programado para entrega'
            );

            INSERT INTO @StatusGuide
            EXECUTE [dbo].[GetStatusOrderValid] @GuideSerie,
                                                @GuideNumber,
                                                @StatusOrderId;


            IF
            (
                SELECT TOP 1 StatusCode FROM @StatusGuide
            ) = 1
            BEGIN

                --- Verificar si existe la preparación de ruta y si ya fue despachada
                SELECT @IdRoutePreparation = rp.IdRoutePreparation,
                       @IdManifest = rp.DeliveryOrderBySettlementId
                FROM RoutePreparation rp
                WHERE rp.CatRouteId = @RouteId
                      AND rp.DateRoutePreparation = @Date
                      AND rp.RowStatus = 1;

                IF @IdRoutePreparation IS NULL
                BEGIN

                    --- No existe la preparación de ruta y debe ser generado
                    INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparation]
                    (
                        [CatRouteId],
                        [DateRoutePreparation],
                        [GuidesQuantity],
                        [PiecesDry],
                        [PiecesCold],
                        [RowStatus],
                        [TokenCreated],
                        [DateCreated],
                        [TokenUpdated],
                        [DateUpdated]
                    )
                    VALUES
                    (@RouteId, @Date, 0, 0, 0, 1, @Token, GETDATE(), NULL, NULL);

                    SET @IdRoutePreparation = SCOPE_IDENTITY();
                END;

                IF @IdRoutePreparation IS NOT NULL
                BEGIN

                    -- Validar que la ruta no haya sido despachada
                    IF @IdManifest IS NULL
                    BEGIN

                        --- Verificar que no esté en otra preparación con un proceso abierto

                        SELECT TOP 1
                               @CodeOfRoute = cr.CodeRoute
                        FROM RoutePreparationDetail rpd
                            INNER JOIN RoutePreparation rp
                                ON rpd.RoutePreparationId = rp.IdRoutePreparation
                            INNER JOIN CatRoute cr WITH (NOLOCK)
                                ON rp.CatRouteId = cr.IdRoute
                        WHERE rpd.IsOpenProcess = 1
                              AND rpd.Guide_Serie = @GuideSerie
                              AND rpd.Guide_Number = @GuideNumber
                              AND rp.IdRoutePreparation <> @IdRoutePreparation
                              AND rp.DateRoutePreparation = @Date
                              AND rp.RowStatus = 1
                        ORDER BY rpd.DateCreated DESC;

                        IF @CodeOfRoute IS NULL
                        BEGIN

                            -- Verificar si existe RouteAssignment, sino lo crea
                            SET @IdRouteAssignment =
                            (
                                SELECT ra.IdRouteAssigment
                                FROM RouteAssigment ra
                                WHERE ra.IdRoute = @RouteId
                                      AND ra.DateOfRoute = @Date
                                      AND ra.RowStatus = 1
                            );

                            IF @IdRouteAssignment IS NULL
                            BEGIN
                                INSERT INTO RouteAssigment
                                (
                                    IdRoute,
                                    DateOfRoute,
                                    RowStatus,
                                    TokenCreated,
                                    DateCreated
                                )
                                VALUES
                                (@RouteId, @Date, 1, @Token, GETDATE());

                                SET @IdRouteAssignment = SCOPE_IDENTITY();
                            END;

                            -- Verificar si existe la guía en el detalle de la preparación de ruta
                            SELECT @IdRoutePreparationDetail = rpd.IdRoutePreparationDetail
                            FROM RoutePreparationDetail rpd
                            WHERE rpd.RoutePreparationId = @IdRoutePreparation
                                  AND rpd.Guide_Serie = @GuideSerie
                                  AND rpd.Guide_Number = @GuideNumber
                                  AND
                                  (
                                      rpd.RowStatus = 1
                                      OR rpd.IsOpenProcess = 1
                                  );

                            IF @IdRoutePreparationDetail IS NULL
                            BEGIN

                                -- Si no existe lo agrega
                                INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationDetail]
                                (
                                    [RoutePreparationId],
                                    [Guide_Serie],
                                    [Guide_Number],
                                    [RowStatus],
                                    [TokenCreated],
                                    [DateCreated],
                                    [TokenUpdated],
                                    [DateUpdated]
                                )
                                VALUES
                                (@IdRoutePreparation, @GuideSerie, @GuideNumber, 1, @Token, GETDATE(), NULL, NULL);

                                SET @IdRoutePreparationDetail = SCOPE_IDENTITY();

                                --- Actualizar el estado de la guía
                                UPDATE DeliveryOrder
                                SET StatusOrderId = @StatusOrderId
                                WHERE Guide_Serie = @GuideSerie
                                      AND Guide_Number = @GuideNumber;

                                --- Insertar el nuevo estado a bitácora (Si no se ha insertado el mismo día)
                                IF NOT EXISTS
                                (
                                    SELECT 1
                                    FROM DeliveryOrderDetail WITH (NOLOCK)
                                    WHERE StatusOrderId = @StatusOrderId
                                          AND Guide_Serie = @GuideSerie
                                          AND Guide_Number = @GuideNumber
                                          AND CAST(DateCreated AS DATE) = CAST(GETDATE() AS DATE)
                                          AND RowStatus = 1
                                )
                                BEGIN
                                    INSERT INTO DeliveryOrderDetail
                                    (
                                        [Guide_Serie],
                                        [Guide_Number],
                                        [StatusOrderId],
                                        [UserCreated],
                                        [DateCreated],
                                        [DateCreatedInSystem]
                                    )
                                    VALUES
                                    (@GuideSerie, @GuideNumber, @StatusOrderId, @Token, GETDATE(), GETDATE());
                                END;

                                --- Actualizar contadores de guías
                                UPDATE RoutePreparation
                                SET GuidesQuantity += 1
                                WHERE IdRoutePreparation = @IdRoutePreparation;

                                SET @CreateServiceManagement = 1;
                            END;

                            IF @IdRoutePreparationDetail IS NOT NULL
                            BEGIN

                                --- Verificar si existe la pieza de la guía dentro del detalle de la preparación de la ruta
                                SELECT @IdRoutePreparationDetailPiece = rpdp.IdRoutePreparationDetailPiece
                                FROM RoutePreparationDetailPiece rpdp
                                    INNER JOIN RoutePreparationDetail rpd
                                        ON rpd.IdRoutePreparationDetail = rpdp.RoutePreparationDetailId
                                WHERE rpdp.RoutePreparationDetailId = @IdRoutePreparationDetail
                                      AND rpdp.PieceNumber = @GuidePiece
                                      AND
                                      (
                                          rpdp.RowStatus = 1
                                          OR
                                          (
                                              rpd.IsOpenProcess = 1
                                              AND rpd.UserProcess IS NOT NULL
                                          )
                                      );

                                IF @IdRoutePreparationDetailPiece IS NULL
                                BEGIN
                                    INSERT INTO RoutePreparationDetailPiece
                                    (
                                        [RoutePreparationDetailId],
                                        [PieceNumber],
                                        [PieceType],
                                        [RowStatus],
                                        [TokenCreated],
                                        [DateCreated]
                                    )
                                    VALUES
                                    (@IdRoutePreparationDetail, @GuidePiece, @GuidePieceIsDry, 1, @Token, GETDATE());

                                    SET @IdRoutePreparationDetailPiece = SCOPE_IDENTITY();

                                    IF @IdRoutePreparationDetailPiece IS NOT NULL
                                        SET @RModified += 1;

                                    --- Actualizar el estado de la pieza
                                    UPDATE DeliveryOrderPiece
                                    SET StatusOrderId = @StatusOrderId
                                    WHERE GuideSerie = @GuideSerie
                                          AND GuideNumber = @GuideNumber
                                          AND NoPiece = @GuidePiece;

                                    --- Actualizar contadores de piezas
                                    UPDATE RoutePreparation
                                    SET PiecesDry += @GuidePieceIsDry,
                                        PiecesCold += IIF(@GuidePieceIsDry = 0, 1, 0)
                                    WHERE IdRoutePreparation = @IdRoutePreparation;
                                END;
                                ELSE
                                    SET @RModified += 1;

                                -- Verificar si es un proceso abierto, de ser así debe continuar el usuario que lo abrió
                                SET @CountPiece =
                                (
                                    SELECT SUM(1)
                                    FROM DeliveryOrderPiece WITH (NOLOCK)
                                    WHERE GuideSerie = @GuideSerie
                                          AND GuideNumber = @GuideNumber
                                );

                                --- Si tiene más de una pieza es un proceso abierto
                                IF (@CountPiece > 1)
                                BEGIN
                                    SET @IsOpenProcess = 1;

                                    IF EXISTS
                                    (
                                        SELECT 1
                                        FROM RoutePreparationDetail rpd
                                        WHERE rpd.IdRoutePreparationDetail = @IdRoutePreparationDetail
                                              AND
                                              (
                                                  rpd.UserProcess = @Token
                                                  OR rpd.UserProcess IS NULL
                                              )
                                    )
                                    BEGIN
                                        UPDATE RoutePreparationDetail
                                        SET IsOpenProcess = 1,
                                            UserProcess = @Token,
                                            RowStatus = 0
                                        WHERE IdRoutePreparationDetail = @IdRoutePreparationDetail;

                                        UPDATE RoutePreparationDetailPiece
                                        SET RowStatus = 0
                                        WHERE IdRoutePreparationDetailPiece = @IdRoutePreparationDetailPiece;
                                    END;
                                    ELSE
                                    BEGIN
                                        SET @IsValidOpenProcess = 0;

                                        SELECT @UserProcess = rpd.UserProcess
                                        FROM RoutePreparationDetail rpd
                                        WHERE rpd.IdRoutePreparationDetail = @IdRoutePreparationDetail;
                                    END;

                                END;
                                ELSE IF @CreateServiceManagement = 1
                                BEGIN
                                    --- Si no es un proceso abierto, asignarle un ServiceManagement

                                    --- Busca un servicio para agruparlo, de lo contrario se crea
                                    SELECT @IdServiceManagementDetail = smd.IdServiceManagementDetail
                                    FROM DeliveryOrder do WITH (NOLOCK)
                                        INNER JOIN ServiceManagementDetail smd
                                            ON smd.IdServiceManagementDetail IN
                                               (
                                                   SELECT DISTINCT
                                                          smd.IdServiceManagementDetail
                                                   FROM RoutePreparation rp
                                                       INNER JOIN RoutePreparationDetail rpd
                                                           ON rpd.RoutePreparationId = rp.IdRoutePreparation
                                                       INNER JOIN ServiceManagementDetail smd
                                                           ON smd.IdServiceManagementDetail = rpd.ServiceManagementDetailId
                                                   WHERE rp.IdRoutePreparation = @IdRoutePreparation
                                                         AND rpd.RowStatus = 1
                                               )
                                               AND
                                               (
                                                   (
                                                       do.IsLastMileReturn = 1
                                                       AND
                                                       (
                                                           (
                                                               smd.ServiceVisitPointId = do.Sender_ID
                                                               AND do.Sender_ID <> 0
                                                           )
                                                           OR smd.ServiceAddress = do.Sender_Address
                                                       )
                                                   )
                                                   OR
                                                   (
                                                       (
                                                           do.IsLastMileReturn IS NULL
                                                           OR do.IsLastMileReturn = 0
                                                       )
                                                       AND
                                                       (
                                                           (
                                                               smd.ServiceVisitPointId = do.Receiver_ID
                                                               AND do.Receiver_ID <> 0
                                                           )
                                                           OR smd.ServiceAddress = do.Receiver_Address
                                                       )
                                                   )
                                               )
                                    WHERE do.Guide_Serie = @GuideSerie
                                          AND do.Guide_Number = @GuideNumber
                                          AND smd.RowStatus = 1;

                                    --- Si no existe, crea uno
                                    IF @IdServiceManagementDetail IS NULL
                                    BEGIN

                                        INSERT INTO [dbo].[ServiceManagement]
                                        (
                                            [RowStatus],
                                            [TokenCreated],
                                            [DateCreated],
                                            [ServiceStatusId],
                                            [SubTypeServiceManagmentId],
                                            [Amount],
                                            [CatPaymentTimeId],
                                            [IdPuRouteAssigment]
                                        )
                                        SELECT 1,
                                               @Token,
                                               GETDATE(),
                                               1,
                                               IIF(do.IsLastMileReturn = 1,
                                               (
                                                   SELECT IdSubTypeServiceManagment
                                                   FROM SubTypeServiceManagment
                                                   WHERE Name = 'Devolución'
                                               ),
                                               (
                                                   SELECT IdSubTypeServiceManagment
                                                   FROM SubTypeServiceManagment
                                                   WHERE Name = 'Entrega'
                                               )),
                                               do.PriceShippment,
                                               dopd.TimePlaId,
                                               @IdRouteAssignment
                                        FROM DeliveryOrder do WITH (NOLOCK)
                                            LEFT JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
                                                ON dopd.GuideSerie = do.Guide_Serie
                                                   AND dopd.GuideNumber = do.Guide_Number
                                        WHERE do.Guide_Serie = @GuideSerie
                                              AND do.Guide_Number = @GuideNumber;

                                        SET @IdServiceManagement = SCOPE_IDENTITY();

                                        INSERT INTO [dbo].[EventService]
                                        (
                                            [ServiceManagementId],
                                            [ServiceStatusId],
                                            [RowStauts],
                                            [TokenCreated],
                                            [DateCreated]
                                        )
                                        VALUES
                                        (@IdServiceManagement, 1, 1, @token, GETDATE());


                                        INSERT INTO [dbo].[ServiceManagementDetail]
                                        (
                                            [ServiceManagement],
                                            [ServiceStartDate],
                                            [ServiceEndDate],
                                            [ServiceVisitPointId],
                                            [ServiceVisitPointPortfolioId],
                                            [ServiceCustomerName],
                                            [ProvinceId],
                                            [TownshipId],
                                            [SettlementId],
                                            [ServiceAddress],
                                            [ServiceSpecialInstructions],
                                            [ServicePhone],
                                            [HubLogisticsId],
                                            [ServiceAmount],
                                            [ServiceExtraAmount],
                                            [TypeVehicleId],
                                            [SubTypeServiceManagmentId],
                                            [RowStatus],
                                            [TokenCreated],
                                            [DateCreated],
                                            [TokenUpdated],
                                            [DateUpdated]
                                        )
                                        SELECT @IdServiceManagement,
                                               GETDATE(),
                                               GETDATE(),
                                               IIF(do.IsLastMileReturn = 1, do.Sender_ID, do.Receiver_ID),
                                               do.VisitpointClientPortfolioId,
                                               CAST(CONCAT(do.Sender_FirstName, ' ', do.Sender_LastName) AS NVARCHAR(100)),
                                               tw.IdProvince,
                                               tw.IdTownship,
                                               IIF(do.IsLastMileReturn = 1, NULL, do.ReceiverIdSettlement),
                                               IIF(do.IsLastMileReturn = 1, do.Sender_Address, do.Receiver_Address),
                                               do.Contact_Instructions,
                                               IIF(do.IsLastMileReturn = 1, do.Sender_Phone, do.Receiver_Phone),
                                               IIF(do.IsLastMileReturn = 1, do.HubOriginId, do.HubDestinationId),
                                               do.PriceShippment,
                                               do.Collect_OnDelivery,
                                               NULL,
                                               IIF(do.IsLastMileReturn = 1,
                                               (
                                                   SELECT IdSubTypeServiceManagment
                                                   FROM SubTypeServiceManagment
                                                   WHERE Name = 'Devolución'
                                               ),
                                               (
                                                   SELECT IdSubTypeServiceManagment
                                                   FROM SubTypeServiceManagment
                                                   WHERE Name = 'Entrega'
                                               )),
                                               1,
                                               @Token,
                                               GETDATE(),
                                               NULL,
                                               NULL
                                        FROM DeliveryOrder do WITH (NOLOCK)
                                            INNER JOIN Township tw WITH (NOLOCK)
                                                ON tw.IdTownship = IIF(do.IsLastMileReturn = 1,
                                                                       do.SenderIdTownship,
                                                                       do.ReceiverIdTownship)
                                                   OR tw.TownshipName = IIF(do.IsLastMileReturn = 1,
                                                                            do.Sender_Town,
                                                                            do.Receiver_Town)  COLLATE Latin1_General_CI_AI 
                                        WHERE do.Guide_Serie = @GuideSerie
                                              AND do.Guide_Number = @GuideNumber;

                                        SET @IdServiceManagementDetail = SCOPE_IDENTITY();
                                    END;
                                    ELSE
                                    BEGIN

                                        --- Actualiza montos
                                        UPDATE smd
                                        SET ServiceAmount += do.PriceShippment,
                                            ServiceExtraAmount += do.Collect_OnDelivery,
                                            TokenUpdated = @Token,
                                            DateUpdated = GETDATE()
                                        FROM ServiceManagementDetail smd
                                            INNER JOIN DeliveryOrder do WITH (NOLOCK)
                                                ON do.Guide_Serie = @GuideSerie
                                                   AND do.Guide_Number = @GuideNumber
                                        WHERE smd.IdServiceManagementDetail = @IdServiceManagementDetail;
                                    END;

                                    --- Se asigna el servicio
                                    UPDATE RoutePreparationDetail
                                    SET ServiceManagementDetailId = @IdServiceManagementDetail
                                    WHERE IdRoutePreparationDetail = @IdRoutePreparationDetail;
                                END;

                                --- Si tiene acta, revocarla
                                UPDATE adp
                                SET adp.UserRevoke = @Token,
                                    adp.DateRevoke = GETDATE(),
                                    adp.TokenUpdated = @Token,
                                    adp.DateUpdated = GETDATE(),
                                    adp.RowStatus = 0
                                FROM ActDetailPiece adp
                                    INNER JOIN ActDetail ad
                                        ON ad.IdActDetail = adp.ActDetailId
                                WHERE ad.GuideSerie = @GuideSerie
                                      AND ad.GuideNumber = @GuideNumber
                                      AND adp.PieceNumber = @GuidePiece
                                      AND adp.RowStatus = 1
                                      AND ad.RowStatus = 1;

                                --- Si es válido el proceso, extraer las piezas de otras preparaciones
                                IF @IsValidOpenProcess = 1
                                BEGIN
                                    UPDATE rpdp
                                    SET rpdp.RowStatus = 0,
                                        rpdp.TokenUpdated = @Token,
                                        rpdp.DateUpdated = GETDATE()
                                    FROM RoutePreparationDetailPiece rpdp
                                        INNER JOIN RoutePreparationDetail rpd
                                            ON rpdp.RoutePreparationDetailId = rpd.IdRoutePreparationDetail
                                        INNER JOIN RoutePreparation rp
                                            ON rpd.RoutePreparationId = rp.IdRoutePreparation
                                    WHERE rpdp.RowStatus = 1
                                          AND rpd.Guide_Serie = @GuideSerie
                                          AND rpd.Guide_Number = @GuideNumber
                                          AND rp.IdRoutePreparation <> @IdRoutePreparation
                                          AND rp.DateRoutePreparation = @Date
                                          AND rpd.RowStatus = 1
                                          AND rp.RowStatus = 1;

                                    --- Extraer de los demas detalles la guía ingresada
                                    UPDATE rpd
                                    SET rpd.RowStatus = 0,
                                        rpd.TokenUpdated = @Token,
                                        rpd.DateUpdated = GETDATE(),
                                        rpd.IsOpenProcess = 0,
                                        rpd.UserProcess = NULL
                                    FROM RoutePreparationDetail rpd
                                        INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparation] rp
                                            ON rpd.RoutePreparationId = rp.IdRoutePreparation
                                    WHERE rpd.RowStatus = 1
                                          AND rpd.Guide_Serie = @GuideSerie
                                          AND rpd.Guide_Number = @GuideNumber
                                          AND rp.IdRoutePreparation <> @IdRoutePreparation
                                          AND rp.DateRoutePreparation = @Date
                                          AND rp.RowStatus = 1;

                                    IF @@rowcount > 0
                                        SET @IsReassignment = 1;
                                END;

                                DECLARE @UpdatedWarehouseByPiece INT = 0;

                                --- Actualizar la posición del inventario
                                UPDATE Warehouse
                                SET Active = 0,
                                    UserUpdated = @Token,
                                    DateUpdated = GETDATE()
                                WHERE Guide_Serie = @GuideSerie
                                      AND Guide_Number = @GuideNumber
                                      AND Guide_Piece = @GuidePiece;

                                SET @UpdatedWarehouseByPiece = @@ROWCOUNT;

                                -- verificar si se actualizo a nivel de pieza
                                IF (@UpdatedWarehouseByPiece = 0)
                                BEGIN
                                    -- No se actualizo a nivel de pieza, no existe registro en warehouse a nivel de pieza

                                    --- Actualizar la posición del inventario a nivel de guía
                                    UPDATE Warehouse
                                    SET Active = 0,
                                        UserUpdated = @Token,
                                        DateUpdated = GETDATE()
                                    WHERE Guide_Serie = @GuideSerie
                                          AND Guide_Number = @GuideNumber
                                          AND Active = 1;
                                END;

                                IF @RModified = 1
                                   AND @IsValidOpenProcess = 1
                                BEGIN
                                    COMMIT TRANSACTION;

                                    IF @IsReassignment = 0
                                        SELECT 1 'StatusCode',
                                               'Pieza asignada correctamente.' 'Description';
                                    ELSE
                                        SELECT 9 'StatusCode',
                                               'Pieza reasignada correctamente.' 'Description';

                                    -- Retornar información de la guía
                                    SELECT rpd.IdRoutePreparationDetail 'IdRoutePreparationDetail',
                                           rpd.Guide_Serie 'GuideSerie',
                                           rpd.Guide_Number 'GuideNumber',
                                           COUNT(1) 'Pieces',
                                           COALESCE(do.Pieces_Dry, 0) + COALESCE(do.Pieces_Cold, 0) 'PiecesTotal',
                                           do.Receiver_Department 'Department',
                                           do.Receiver_Town 'Town',
                                           do.Receiver_Address 'Address',
                                           rpd.GuideOrder 'GuideOrder'
                                    FROM RoutePreparationDetail rpd
                                        INNER JOIN DeliveryOrder do WITH (NOLOCK)
                                            ON rpd.Guide_Serie = do.Guide_Serie
                                               AND rpd.Guide_Number = do.Guide_Number
                                    WHERE rpd.IdRoutePreparationDetail = @IdRoutePreparationDetail
                                    GROUP BY IdRoutePreparationDetail,
                                             rpd.Guide_Serie,
                                             rpd.Guide_Number,
                                             do.Pieces_Dry,
                                             do.Pieces_Cold,
                                             do.Receiver_Department,
                                             do.Receiver_Town,
                                             do.Receiver_Address,
                                             rpd.GuideOrder;

                         IF (@Reference <> '')
								  BEGIN
									  SELECT 
                                           do.Guide_Serie 'GuideSerie',
                                           do.Guide_Number 'GuideNumber',
                                           COUNT(1) 'Pieces',
                                           COALESCE(do.Pieces_Dry, 0) + COALESCE(do.Pieces_Cold, 0) 'guidePiecesTotal'
                                    FROM 
                                         DeliveryOrder do WITH (NOLOCK)
                                    WHERE do.Ticket_Number = @Reference
                                    GROUP BY 
                                             do.Guide_Serie,
                                             do.Guide_Number,
                                             do.Pieces_Dry,
                                             do.Pieces_Cold
									END

                                    -- Si es proceso abierto, retornar información de las piezas
                                    IF @IsOpenProcess = 1
                                        SELECT dop.NoPiece,
                                               IIF(act.IdActDetailPiece IS NULL, 0, 1) PieceAct
                                        FROM DeliveryOrderPiece dop WITH (NOLOCK)
                                            LEFT JOIN
                                            (
                                                SELECT ad.GuideSerie,
                                                       ad.GuideNumber,
                                                       adp.PieceNumber,
                                                       adp.IdActDetailPiece
                                                FROM ActDetail ad WITH (NOLOCK)
                                                    INNER JOIN ActDetailPiece adp WITH (NOLOCK)
                                                        ON adp.ActDetailId = ad.IdActDetail
                                                WHERE ad.RowStatus = 1
                                                AND adp.RowStatus = 1
                                            ) act
                                                ON act.GuideSerie = dop.GuideSerie
                                                   AND act.GuideNumber = dop.GuideNumber
                                                   AND act.PieceNumber = dop.NoPiece
                                        WHERE dop.GuideSerie = @GuideSerie
                                              AND dop.GuideNumber = @GuideNumber;


                                END;
                                ELSE
                                BEGIN
                                    ROLLBACK TRANSACTION;

                                    IF @IsValidOpenProcess = 1
                                        SELECT 8 'StatusCode',
                                               'Ocurrió un error asignar pieza en la preparación.' 'Description';
                                    ELSE
                                        SELECT 7 'StatusCode',
                                               'Ya existe un proceso abierto para la guía con otro usuario.' 'Description',
                                               ISNULL(
                                               (
                                                   SELECT CONCAT(p.PerFirstName, ' ', p.PerLastName)
                                                   FROM TokenLog tl WITH (NOLOCK)
                                                       INNER JOIN RegisterUser ru WITH (NOLOCK)
                                                           ON ru.UsrIdUser = tl.TknIdUser
                                                       INNER JOIN Person p WITH (NOLOCK)
                                                           ON p.PerIdPerson = ru.UsrIdPerson
                                                   WHERE tl.TknIdToken = @UserProcess
                                               ),
                                               @UserProcess
                                                     ) 'UserProcess';
                                END;
                            END;
                            ELSE
                            BEGIN
                                ROLLBACK TRANSACTION;

                                SELECT 6 'StatusCode',
                                       'Ocurrió un error al crear el detalle de la preparación.' 'Description';
                            END;
                        END;
                        ELSE
                        BEGIN
                            ROLLBACK TRANSACTION;

                            SELECT 10 'StatusCode',
                                   CONCAT(
                                             'La guía ',
                                             @GuideSerie,
                                             @GuideNumber,
                                             ' se encuentra en un proceso abierto en la ruta ',
                                             @CodeOfRoute,
                                             '.'
                                         ) 'Description';

                        END;
                    END;
                    ELSE
                    BEGIN
                        ROLLBACK TRANSACTION;

                        SELECT 5 'StatusCode',
                               'La ruta ya ha sido despachada.' 'Description';
                    END;
                END;
                ELSE
                BEGIN
                    ROLLBACK TRANSACTION;

                    SELECT 4 'StatusCode',
                           'Ocurrió un error al crear la preparación de ruta.' 'Description';
                END;
            END;
            ELSE
            BEGIN
                ROLLBACK TRANSACTION;

                SELECT 3 'StatusCode',
                       ISNULL(
                       (
                           SELECT TOP 1 Description FROM @StatusGuide
                       ),
                       'Error al validar estado de la guía.'
                             ) 'Description';

            END;
        END;
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
              
			IF(@CountryId  <>  @Country)
			BEGIN
				SELECT 
					2 AS StatusCode,
					'   ¡Lo sentimos! El país de tu cuenta no coincide con el país de destino de la guía seleccionada. Por favor, revisa y selecciona una guía que corresponda a tu país.'   AS Description; 
			END
			   ELSE
					BEGIN
						SELECT 2 'StatusCode',
							   CONCAT('La pieza ', @GuideSerie, @GuideNumber, '-', @GuidePiece, ' no existe.') 'Description';
					 END
           
        END;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        --Insert en tabla de log
        INSERT INTO [dbo].[RoutePreparationLogError]
        (
            [ErrorDescription],
            [ErrorNumber],
            [ErrorProcedure],
            [ErrorLine],
            [GuideSerie],
            [GuideNumber],
            [TokenCreated],
            [DateCreated]
        )
        VALUES
        (CAST(ERROR_MESSAGE() AS VARCHAR(300)), ERROR_NUMBER(), CAST(ERROR_PROCEDURE() AS VARCHAR(100)), ERROR_LINE(),
         @GuideSerie, @GuideNumber, @Token, GETDATE());

        SELECT 0 'StatusCode',
               ERROR_MESSAGE() 'Description';
    END CATCH;
END;