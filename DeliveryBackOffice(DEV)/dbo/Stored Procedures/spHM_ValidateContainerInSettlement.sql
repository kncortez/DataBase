-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <19-08-2022>
-- Description:	<Validate containers in settlement process by settlement HUB>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_ValidateContainerInSettlement]
	@LinehaulRoutePreparationId AS INT,
	@ContainerSerie AS NVARCHAR(5),
	@ContainerNumber AS NVARCHAR(25),
	@HubDestinyId AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @STATUS_IN_TRANSIT AS INT;				-- CatLinehaulStatus
	DECLARE @CONTAINER_ID AS INT;					-- Container
	DECLARE @CONTAINER_SERIE_ID AS INT;				-- CatTypeContainer
	DECLARE @ALLOW_STOPOVER AS BIT;					-- CatTypeContainer
	DECLARE @EXISTING_CONTAINER_LRPC AS INT;		-- LinehaulRoutePreparationContainer
	DECLARE @EXISTING_CONTAINER_HUB_LRPC AS INT;	-- LinehaulRoutePreparationContainer
	DECLARE @LIQUIDATED_PIECES AS INT;				-- LinehaulRoutePreparationContainerDetailPiece

	SELECT	@CONTAINER_SERIE_ID = [CTC].[IdCatTypeContainer],
			@ALLOW_STOPOVER = [CTC].[AllowStopOver]
	FROM	[dbo].[CatTypeContainer] CTC
	WHERE	[CTC].[TypeContainerSerie] = @ContainerSerie;

	SET @CONTAINER_ID = (SELECT	[C].[IdContainer]
						FROM	[DBO].[Container] C
						WHERE	[C].[CatTypeContainerId] = @CONTAINER_SERIE_ID
							AND [C].[ContainerNumber] = @ContainerNumber);

	PRINT @CONTAINER_ID

	SET @STATUS_IN_TRANSIT = (SELECT	[CLS].[IdCatLinehaulStatus]
								FROM	[dbo].[CatLinehaulStatus] CLS
								WHERE	[CLS].[StatusName] = 'IN TRANSIT');

	PRINT @STATUS_IN_TRANSIT

	SET @EXISTING_CONTAINER_LRPC = (SELECT  COUNT([LRPC].[IdLinehaulRoutePreparationContainer]) AS CONT
									FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
									WHERE	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
										AND	[LRPC].[ContainerId] = @CONTAINER_ID
										AND [LRPC].[RowStatus] = 1
										AND [LRPC].[CatLinehaulStatusId] = @STATUS_IN_TRANSIT);

	PRINT @EXISTING_CONTAINER_LRPC

	SET @LIQUIDATED_PIECES = (SELECT		COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece]) AS CONT
								FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
								INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
									ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
								INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
									ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
									AND		[LRPC].[ContainerId] = @CONTAINER_ID
									AND		[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
								WHERE		[LRPCDP].[ActCode] IS NULL
									AND		[LRPCDP].[CatLinehaulStatusId] != @STATUS_IN_TRANSIT
									AND		[LRPCDP].[RowStatus] = 1);

PRINT '@LIQUIDATED_PIECES'
PRINT @LIQUIDATED_PIECES

	SET @EXISTING_CONTAINER_HUB_LRPC = (SELECT  COUNT([LRPC].[IdLinehaulRoutePreparationContainer]) AS CONT
										FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
										WHERE	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
											AND	[LRPC].[ContainerId] = @CONTAINER_ID
											AND [LRPC].[RowStatus] = 1
											AND [LRPC].[CatLinehaulStatusId] = @STATUS_IN_TRANSIT
											AND [LRPC].[HubDestinyId] = @HubDestinyId);

PRINT @EXISTING_CONTAINER_HUB_LRPC
PRINT'@EXISTING_CONTAINER_HUB_LRPC'

	-- Container doesn't exist in LinehaulRoutePreparation
	IF (@EXISTING_CONTAINER_LRPC = 0)
		BEGIN
			SELECT 0 [spResult], 'Contenedor NO existe en Despacho de ruta' [spMessage];
			RETURN;
		END

	-- Container HUB destiny doesn't match with actual HUB
	IF (@EXISTING_CONTAINER_HUB_LRPC = 0 AND @LIQUIDATED_PIECES = 0 AND @ALLOW_STOPOVER = 1)
		BEGIN
			SELECT 1 [spResult], 'Contenedor con diferente HUB destino al actual, puede ser liquidado por completo' [spMessage];
			RETURN;
		END 		

	SELECT 2 [spResult], 'Contenedor válido' [spMessage];
										
END