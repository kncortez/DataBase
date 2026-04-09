/* =================================================
   SP:        [dbo].[SPHW_RegisterInventoryAutomaticExc]
   Propósito: Actualiza estado y registra inventario si la guia fue generada en express center
   Autor:     Brandon Pedroza
   Historia:  FDAPI-5692
   Fecha:     2026-03-11
   === CHANGELOG ============================

=========================================== */

CREATE PROCEDURE [dbo].[SPHW_RegisterInventoryAutomaticExc]
    @TblGuides TblGuides READONLY,
    @Token NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EXCBusinessId INT = 0;
    DECLARE @IsClientEXC BIT = 0;
    DECLARE @CodeOfReference INT;
    DECLARE @RackPosition NVARCHAR(60);
    DECLARE @StatusOrderId INT = 10; -- En inventario -> StatusOrder
    DECLARE @IdCountry NVARCHAR(2);
    DECLARE @IdStation INT;

    SELECT TOP 1
        @IdCountry = SenderCountryId
    FROM [DeliveryBackOffice].[dbo].DeliveryOrder DO WITH (NOLOCK)
        INNER JOIN @TblGuides Tbg
            ON do.Guide_Serie = tbg.Guide_Serie
               AND do.Guide_Number = tbg.Guide_Number


    -- Buscar Giro Negocio Express Centers
    SET @EXCBusinessId =
    (
        SELECT TOP 1
            [KoVPB].[IdKindOfVPBusiness]
        FROM [DeliveryBackOffice].[dbo].[KindOfVPBusiness] KoVPB WITH (NOLOCK)
        WHERE [KoVPB].[KindOfVPNameBussiness] = 'Express Center'
              AND KoVPB.IdCountry = @IdCountry
    )

    SELECT TOP 1
        @CodeOfReference = ISNULL(VPCSend.CodeOfReference, VPCOri.CodeOfReference)
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
        INNER JOIN @TblGuides Tbg
            ON do.Guide_Serie = tbg.Guide_Serie
               AND do.Guide_Number = tbg.Guide_Number
        LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] VPCSend WITH (NOLOCK)
            ON DO.Sender_ID = [VPCSend].CodeOfReference
               AND [VPCSend].StatusClient = 1
               AND [VPCSend].[IdKindOfVPBusiness] = @EXCBusinessId
               AND [VPCSend].[IdVisitPointClient] IS NOT NULL
        LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] VPCOri WITH (NOLOCK)
            ON DO.[OriginSenderId] = [VPCOri].[CodeOfReference]
               AND [VPCOri].[StatusClient] = 1
               AND [VPCOri].[IdKindOfVPBusiness] = @EXCBusinessId
               AND [VPCOri].[IdVisitPointClient] IS NOT NULL

    BEGIN TRY
        -- Si la guía se origino en Express Center
        IF (@CodeOfReference IS NOT NULL)
        BEGIN
            BEGIN TRAN

            SELECT TOP 1
                @RackPosition = CS.RackPositionDefault,
                @IdStation = CS.IdStation
            FROM [DeliveryBackOffice].[dbo].[CatStation] CS WITH (NOLOCK)
            WHERE CS.CodeOfReference = @CodeOfReference

            --ACTUALIZAR ESTADO DE GUIA
            UPDATE DO
            SET DO.StatusOrderId = @StatusOrderId
            FROM [DeliveryBackOffice].[dbo].DeliveryOrder DO WITH (NOLOCK)
                INNER JOIN @TblGuides tbg
                    ON DO.Guide_Serie = tbg.Guide_Serie
                       AND DO.Guide_Number = tbg.Guide_Number;

            --INSERTAR CHECKPOINT DE INVENTARIO
            INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
            (
                Guide_Serie,
                Guide_Number,
                StatusOrderId,
                UserCreated,
                DateCreated,
                DateCreatedInSystem,
                Observations,
                Temperature_Celsius,
                PieceId,
                RowStatus,
                DeliveryAttemptId,
                SystemOrigin,
                StationId
            )
            SELECT tbg.Guide_Serie,
                   tbg.Guide_Number,
                   @StatusOrderId,
                   @Token,
                   GETDATE(),
                   GETDATE(),
                   NULL,
                   NULL,
                   NULL,
                   1,
                   NULL,
                   NULL,
                   @IdStation
            FROM @TblGuides tbg;

            --INSERTAR PIEZAS EN INVENTARIO
            INSERT INTO DeliveryBackOffice.dbo.Warehouse
            (
                Rack_Position,
                Guide_Serie,
                Guide_Number,
                Dry,
                Cold,
                Active,
                UserCreated,
                DateCreated,
                Guide_Piece,
                UserUpdated,
                DateUpdated,
                IsReturn,
                HubExc,
                IdHubExc,
                StatusOrderId,
				StationId
            )
            SELECT @RackPosition,
                   tbg.Guide_Serie,
                   tbg.Guide_Number,
                   1,
                   0,
                   1,
                   @Token,
                   GETDATE(),
                   DOP.NoPiece,
                   NULL,
                   NULL,
                   0,
                   'EXC',
                   @CodeOfReference,
                   @StatusOrderId,
				   @IdStation
            FROM @TblGuides tbg
                INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH(NOLOCK)
                    ON tbg.Guide_Serie = DOP.GuideSerie
                       AND tbg.Guide_Number = DOP.GuideNumber;

            COMMIT TRAN
            SELECT '200' AS [StatusCode],
                   'Datos registrados correctamente' AS [Message]
        END
        ELSE
        BEGIN
            SELECT '201' AS [StatusCode],
                   'Origen de guia no es EXC' AS [Message]
        END
    END TRY
    BEGIN CATCH

        SELECT '500' AS [StatusCode],
               'Ocurrio un error'+ ERROR_MESSAGE() AS [Message]
        ROLLBACK TRAN

    END CATCH
END
