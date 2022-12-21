-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <14-07-2022>
-- Description:	<Add guide to LinehaulRoutePreparationContainerDetail>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_addGuideToLinehaulRoutePreparationContainerDetail]
    @LinehaulRoutePreparationId AS INT,
    @LinehaulRoutePreparationContainerId AS INT,
    @GuideSerie AS NVARCHAR(25),
    @GuideNumber AS NVARCHAR(25),
    @PiecesDryTotal AS INT,
    @PiecesColdTotal AS INT,
    @IsOpenProcess AS INT,
    @PieceNumber AS INT,
    @IsDry AS INT,
    @TknUser AS NVARCHAR(50)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @EXISTING_LRP AS INT; -- LinehaulRoutePreparation
    DECLARE @EXISTING_LRPCD AS INT; -- LinehaulRoutePreparationContainerDetail
    DECLARE @EXISTING_LRPCDP AS INT; -- LinehaulRoutePreparationContainerDetailPiece
    DECLARE @CONTAINER_QUANTITY_CONTAINER AS INT; -- LinehaulRoutePreparationContainer
    DECLARE @GUIDE_QUANTITY_CONTAINER AS INT; -- LinehaulRoutePreparationContainer
    DECLARE @DRY_QUANTITY_CONTAINER AS INT; -- LinehaulRoutePreparationContainer
    DECLARE @COLD_QUANTITY_CONTAINER AS INT; -- LinehaulRoutePreparationContainer
    DECLARE @GUIDE_QUANTITY_DETAIL AS INT; -- LinehaulRoutePreparationContainerDetail
    DECLARE @DRY_PIECE_QUANTITY_DETAIL AS INT; -- LinehaulRoutePreparationContainerDetail
    DECLARE @COLD_PIECE_QUANTITY_DETAIL AS INT; -- LinehaulRoutePreparationContainerDetail
    DECLARE @DRY_PIECE_QUANTITY_PIECE AS INT; -- LinehaulRoutePreparationContainerDetailPiece
    DECLARE @COLD_PIECE_QUANTITY_PIECE AS INT; -- LinehaulRoutePreparationContainerDetailPiece

    SET @EXISTING_LRP =
    (
        SELECT COUNT([LRP].[IdLinehaulRoutePreparation])
        FROM [dbo].[LinehaulRoutePreparation] LRP
        WHERE [LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId
    );

    IF (@EXISTING_LRP = 0)
    BEGIN
        SELECT 0 [spResult],
               'Preparación de ruta de linehaul NO existe' [spMessage];
        RETURN;

    END;

    -- Check if there is a record in LinehaulRoutePreparationContainerDetail with same data
    SET @EXISTING_LRPCD =
    (
        SELECT COUNT([LRPD].[IdLinehaulRoutePreparationContainerDetail])
        FROM [dbo].[LinehaulRoutePreparationContainerDetail] LRPD
        WHERE [LRPD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
              AND [LRPD].[GuideSerie] = @GuideSerie
              AND [LRPD].[GuideNumber] = @GuideNumber
    );

    BEGIN TRANSACTION;
    BEGIN TRY
        IF (@EXISTING_LRPCD = 0)
        BEGIN
            -- Create document
            INSERT INTO [dbo].[LinehaulRoutePreparationContainerDetail]
            (
                [LinehaulRoutePreparationContainerId],
                [GuideSerie],
                [GuideNumber],
                [GuideDryPieceTotal],
                [GuideColdPieceTotal],
                [DryPieceQuantity],
                [ColdPieceQuantity],
                [IsOpenProcess],
                [RowStatus],
                [TokenCreated],
                [DateCreated]
            )
            VALUES
            (   @LinehaulRoutePreparationContainerId, @GuideSerie, @GuideNumber, @PiecesDryTotal, @PiecesColdTotal,
                0,                 -- DryPiecesQuantity
                0,                 -- ColdPiecesQuantity
                @IsOpenProcess, 1, -- RowStatus
                @TknUser, SYSDATETIME());
        END;

        SET @EXISTING_LRPCD =
        (
            SELECT [LRPD].[IdLinehaulRoutePreparationContainerDetail]
            FROM [dbo].[LinehaulRoutePreparationContainerDetail] LRPD
            WHERE [LRPD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
                  AND [LRPD].[GuideSerie] = @GuideSerie
                  AND [LRPD].[GuideNumber] = @GuideNumber
        );

        -- Document already exists, return data, only update token created AND open process value
        UPDATE [LinehaulRoutePreparationContainerDetail]
        SET [TokenCreated] = @TknUser,
            [IsOpenProcess] = @IsOpenProcess,
            [RowStatus] = 1
        WHERE [LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
              AND [GuideSerie] = @GuideSerie
              AND [GuideNumber] = @GuideNumber;

        -- Starts Piece process -------------------------------------------------------------------------------------------------

        SET @EXISTING_LRPCDP =
        (
            SELECT COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece]) AS CONT
            FROM [dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
            WHERE [LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
                  AND [LRPCDP].[PieceNumber] = @PieceNumber
        );

        IF (@EXISTING_LRPCDP = 0)
        BEGIN
            -- INSERT PIECE
            INSERT INTO [dbo].[LinehaulRoutePreparationContainerDetailPiece]
            (
                [LinehaulRoutePreparationContainerDetailId],
                [CatLinehaulStatusId],
                [PieceNumber],
                [IsDryPiece],
                [RowStatus],
                [TokenCreated],
                [DateCreated]
            )
            VALUES
            (   @EXISTING_LRPCD,
                (
                    SELECT [CLS].[IdCatLinehaulStatus]
                    FROM [dbo].[CatLinehaulStatus] CLS
                    WHERE [CLS].[StatusName] = 'PREPARATION FOR TRANSFER'
                ), @PieceNumber, @IsDry, 1, -- Row Status
                @TknUser, SYSDATETIME());
        END;

        SET @EXISTING_LRPCDP =
        (
            SELECT [LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece]
            FROM [dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
            WHERE [LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
                  AND [LRPCDP].[PieceNumber] = @PieceNumber
        );

        UPDATE [dbo].[LinehaulRoutePreparationContainerDetailPiece]
        SET [RowStatus] = 1,
            [TokenUpdated] = @TknUser,
            [DateUpdated] = SYSDATETIME()
        WHERE [LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
              AND [PieceNumber] = @PieceNumber;

        -- End Piece process -----------------------------------------------------------------------------------------------------

        -- Starts Update General Numbers -----------------------------------------------------------------------------------------
        -- UPDATE LinehaulRoutePreparationContainerDetail
        SELECT @DRY_PIECE_QUANTITY_PIECE = COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece])
        FROM [dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
        WHERE [LRPCDP].[IsDryPiece] = 1
              AND [LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
              AND [LRPCDP].[RowStatus] = 1
              AND [LRPCDP].[ActCode] IS NULL;

        SELECT @COLD_PIECE_QUANTITY_PIECE = COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece])
        FROM [dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
        WHERE [LRPCDP].[IsDryPiece] = 0
              AND [LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
              AND [LRPCDP].[RowStatus] = 1
              AND [LRPCDP].[ActCode] IS NULL;

        UPDATE [LinehaulRoutePreparationContainerDetail]
        SET [DryPieceQuantity] = @DRY_PIECE_QUANTITY_PIECE,
            [ColdPieceQuantity] = @COLD_PIECE_QUANTITY_PIECE
        WHERE [IdLinehaulRoutePreparationContainerDetail] = @EXISTING_LRPCD;

        -- UPDATE LinehaulRoutePreparationContainer

        SET @GUIDE_QUANTITY_DETAIL =
        (
            SELECT COUNT([LRPCD].[IdLinehaulRoutePreparationContainerDetail])
            FROM [dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
            WHERE [LRPCD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
                  AND [LRPCD].[RowStatus] = 1
        );

        SELECT @DRY_PIECE_QUANTITY_DETAIL = COALESCE(SUM([LRPCD].[DryPieceQuantity]), 0),
               @COLD_PIECE_QUANTITY_DETAIL = COALESCE(SUM([LRPCD].[ColdPieceQuantity]), 0)
        FROM [dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
        WHERE [LRPCD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
              AND [LRPCD].[RowStatus] = 1;

        UPDATE [LinehaulRoutePreparationContainer]
        SET [GuideQuantity] = @GUIDE_QUANTITY_DETAIL,
            [DryPieceQuantity] = @DRY_PIECE_QUANTITY_DETAIL,
            [ColdPieceQuantity] = @COLD_PIECE_QUANTITY_DETAIL
        WHERE [IdLinehaulRoutePreparationContainer] = @LinehaulRoutePreparationContainerId;

        -- UPDATE LinehaulRoutePreparation

        SET @CONTAINER_QUANTITY_CONTAINER =
        (
            SELECT COUNT([LRPC].[ContainerId])
            FROM [dbo].[LinehaulRoutePreparationContainer] LRPC
            WHERE [LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
                  AND [LRPC].[RowStatus] = 1
        );

        SELECT @GUIDE_QUANTITY_CONTAINER = COALESCE(SUM([LRPC].[GuideQuantity]), 0),
               @DRY_QUANTITY_CONTAINER = COALESCE(SUM([LRPC].[DryPieceQuantity]), 0),
               @COLD_QUANTITY_CONTAINER = COALESCE(SUM([LRPC].[ColdPieceQuantity]), 0)
        FROM [dbo].[LinehaulRoutePreparationContainer] LRPC
        WHERE [LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
              AND [LRPC].[RowStatus] = 1;

        UPDATE [LinehaulRoutePreparation]
        SET [ContainerQuantity] = @CONTAINER_QUANTITY_CONTAINER,
            [GuideQuantity] = @GUIDE_QUANTITY_CONTAINER,
            [DryPieceQuantity] = @DRY_QUANTITY_CONTAINER,
            [ColdPieceQuantity] = @COLD_QUANTITY_CONTAINER
        WHERE [IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId;
        -- End Update General Numbers --------------------------------------------------------------------------------------------

        SELECT [LRPD].[IdLinehaulRoutePreparationContainerDetail],
               [LRPD].[LinehaulRoutePreparationContainerId],
               [LRPD].[GuideSerie],
               [LRPD].[GuideNumber],
               [LRPD].[GuideDryPieceTotal],
               [LRPD].[GuideColdPieceTotal],
               [LRPD].[DryPieceQuantity],
               [LRPD].[ColdPieceQuantity],
               [LRPD].[IsOpenProcess]
        FROM [dbo].[LinehaulRoutePreparationContainerDetail] LRPD
        WHERE [LRPD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
              AND [LRPD].[GuideSerie] = @GuideSerie
              AND [LRPD].[GuideNumber] = @GuideNumber;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SELECT 0 [spResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [spMessage];

        ROLLBACK TRANSACTION;

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
        (CAST(ERROR_MESSAGE() AS VARCHAR(300)), ERROR_NUMBER(), CAST(ERROR_PROCEDURE() AS VARCHAR(100)), ERROR_LINE(),
         @GuideSerie  , @GuideNumber, 'spHM_addGuideToLinehaulRoutePreparationContainerDetail', GETDATE());

    END CATCH;
END;