-- =============================================  
-- Author:		<Brandon, Pedroza>  
-- Create date: <2025-01-13>  
-- Description: <Contenerizacion guias - Valida guia para agregar a contenedor en liquidacion de ruta>  
-- =============================================  
CREATE PROCEDURE [dbo].[sphdValidateGuideByContainer]
	@GuideSerie NVARCHAR(50),
	@GuideNumber INT,
	@GuidePiece INT= NULL,
	@IdCustomer INT,
	@ReferenceContainer NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Customer INT, @Container NVARCHAR(MAX);
	DECLARE @Description NVARCHAR(2048)= 'Informacion obtenida';
	DECLARE @IdContainer INT,@StatusGuideByContainer INT = 1, @StatusPendingGuideByContainer INT,@StatusScannedGuideByContainer INT;;
	DECLARE @TicketNumber NVARCHAR(MAX);
	DECLARE @isNEwRegistGuide INT=0;
	DECLARE @IdStatusGenerated INT= (SELECT StatusOrderId FROM StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Solicitado');
	DECLARE @IdStatusRequest INT= (SELECT StatusOrderId FROM StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Generado');
	DECLARE @IdStatusPickUp INT= (SELECT StatusOrderId FROM StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Recolectado');
	DECLARE @IdStatusGuide INT=0;
    
	DECLARE @IsStatusTerminal INT = (
		SELECT COUNT(Guide_Number)
		FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
		INNER JOIN [dbo].[StatusOrder] SO WITH (NOLOCK)
			ON DO.StatusOrderId = SO.StatusOrderId
		WHERE [CatCheckpointTypeId] = 3 
			AND SO.RowStatus = 1
			AND DO.Guide_Serie = @GuideSerie 
			AND Guide_Number = @GuideNumber
	);

	DECLARE @StatusDescription NVARCHAR(2048) = (
		SELECT SO.OrderDescription
		FROM dbo.DeliveryOrder DO WITH (NOLOCK)
		INNER JOIN dbo.StatusOrder SO WITH (NOLOCK)
			ON DO.StatusOrderId = SO.StatusOrderId
		WHERE DO.Guide_Serie = @GuideSerie 
			AND Guide_Number = @GuideNumber
	);

	SELECT @StatusPendingGuideByContainer = IdStatus
		FROM CatStatusGuideByContainer WITH(NOLOCK)
		WHERE [Name] = 'Pendiente';

	SELECT @StatusScannedGuideByContainer = IdStatus
		FROM CatStatusGuideByContainer WITH(NOLOCK)
		WHERE [Name] = 'Escaneada';

	IF (@IsStatusTerminal = 1)
	BEGIN
		SET @Description = '*** Guía : ' + @GuideSerie + CONVERT(NVARCHAR(25), @GuideNumber) + ' en estado Terminal : ' + @StatusDescription + ' ***';
		SELECT 0 AS StatusCode, @Description AS Description, CONCAT(@GuideSerie, @GuideNumber) AS Guide, 0 AS SubStatusCode, 0 AS IsDry, 0 AS IsTerminal;
		RETURN;
	END;

	SELECT	@Customer = IdCustomer,
			@TicketNumber = Ticket_Number,
			@IdStatusGuide = StatusOrderId
	FROM DeliveryOrder DO WITH (NOLOCK)
	WHERE DO.Guide_Serie = @GuideSerie
		AND DO.Guide_Number = @GuideNumber;

	IF (@IdStatusGuide NOT IN( @IdStatusGenerated, @IdStatusRequest, @IdStatusPickUp))
	BEGIN
		SET @Description = '*** No puede agregarser guía : ' + @GuideSerie + CONVERT(NVARCHAR(25), @GuideNumber) + ' en estado : ' + @StatusDescription + ' ***';
		SELECT 5 AS StatusCode, @Description AS Description, CONCAT(@GuideSerie, @GuideNumber) AS Guide, 0 AS SubStatusCode, 0 AS IsDry, 0 AS IsTerminal;
		RETURN;
	END;

	IF (@Customer <> @IdCustomer)
	BEGIN
		SET @Description = '*** Guía : ' + @GuideSerie + CONVERT(NVARCHAR(25), @GuideNumber) + ' no pertenece al cliente ***';
		SELECT 1 AS StatusCode, @Description AS Description, CONCAT(@GuideSerie, @GuideNumber) AS Guide, 0 AS SubStatusCode, 0 AS IsDry, 0 AS IsTerminal;
		RETURN;
	END;

	--SI es pieza
	IF @GuidePiece <> 0
	BEGIN
			SELECT TOP 1 
				@Container =  SC.ReferenceContainer,
				@IdContainer = SC.IdContainer,
				@StatusGuideByContainer = ISNULL(DOP.IdStatusGuideByContainer,1)
			FROM ShippingContainerDetail SCD WITH (NOLOCK)
			INNER JOIN ShippingContainer SC WITH (NOLOCK)
				ON SC.IdContainer = SCD.IdContainer
			INNER JOIN DeliveryOrderPiece DOP WITH(NOLOCK)
				ON DOP.GuideSerie = SCD.GuideSerie
					AND DOP.GuideNumber = SCD.GuideNumber
			WHERE DOP.GuideSerie = @GuideSerie
				AND DOP.GuideNumber = @GuideNumber
				AND DOP.NoPiece = @GuidePiece;

			IF (@StatusGuideByContainer <> @StatusPendingGuideByContainer)
			BEGIN
				SET @Description = 'La Guía : ' + @GuideSerie + CONVERT(NVARCHAR(25), @GuideNumber) + ' ya no esta disponible para escaneo.';
				SELECT 3 AS StatusCode, @Description AS Description, CONCAT(@GuideSerie, @GuideNumber) AS Guide, 0 AS SubStatusCode, 0 AS IsDry, 0 AS IsTerminal;
				RETURN;
			END;
	END
	ELSE
	BEGIN
		IF NOT EXISTS (SELECT 1
						FROM DeliveryOrderPiece DOP WITH(NOLOCK)
						WHERE DOP.GuideSerie = @GuideSerie
							AND DOP.GuideNumber = @GuideNumber
							AND ISNULL(DOP.IdStatusGuideByContainer,1) = 1
				)
			BEGIN
				SET @Description = 'La Guía : ' + @GuideSerie + CONVERT(NVARCHAR(25), @GuideNumber) + ' ya no esta disponible para escaneo.';
				SELECT 3 AS StatusCode, @Description AS Description, CONCAT(@GuideSerie, @GuideNumber) AS Guide, 0 AS SubStatusCode, 0 AS IsDry, 0 AS IsTerminal;
				RETURN;
			END;
	END

	SELECT TOP 1 
				@Container =  SC.ReferenceContainer,
				@IdContainer = SC.IdContainer
			FROM ShippingContainerDetail SCD WITH (NOLOCK)
			INNER JOIN ShippingContainer SC WITH (NOLOCK)
				ON SC.IdContainer = SCD.IdContainer
			INNER JOIN DeliveryOrderPiece DOP WITH(NOLOCK)
				ON DOP.GuideSerie = SCD.GuideSerie
					AND DOP.GuideNumber = SCD.GuideNumber
			WHERE DOP.GuideSerie = @GuideSerie
				AND DOP.GuideNumber = @GuideNumber

	IF (@Container IS NOT NULL  AND @Container <> @ReferenceContainer)
	BEGIN
		SET @Description = 'La Guía : ' + @GuideSerie + CONVERT(NVARCHAR(25), @GuideNumber) + ' pertenece a otro contenedor. Ref:' + @Container;
		SELECT 2 AS StatusCode, @Description AS Description, CONCAT(@GuideSerie, @GuideNumber) AS Guide, 0 AS SubStatusCode, 0 AS IsDry, 0 AS IsTerminal;
		RETURN;
	END;


	IF NOT EXISTS( SELECT 1  FROM DeliveryOrder WITH(NOLOCK) WHERE Guide_Number = @GuideNumber AND Guide_Serie = @GuideSerie)
	BEGIN
		SET @Description = 'La Guía : ' + @GuideSerie + CONVERT(NVARCHAR(25), @GuideNumber) + ' no existe';
		SELECT 4 AS StatusCode, @Description AS Description, CONCAT(@GuideSerie, @GuideNumber) AS Guide, 0 AS SubStatusCode, 0 AS IsDry, 0 AS IsTerminal;
		RETURN;
	END

	--INSERTAR GUIA EN CONTENEDOR
	IF (@Container IS NULL )
	BEGIN
		SELECT TOP 1 @IdContainer = SC.IdContainer
		FROM ShippingContainerDetail SCD WITH (NOLOCK)
		INNER JOIN ShippingContainer SC WITH (NOLOCK)
			ON SC.IdContainer = SCD.IdContainer
		WHERE SC.ReferenceContainer = @ReferenceContainer

		SET @Description = 'La Guía : ' + @GuideSerie + CONVERT(NVARCHAR(25), @GuideNumber) + ' ha sido asociada al contenedor Ref:' + @ReferenceContainer;
		SET @isNEwRegistGuide = 1;

		INSERT INTO ShippingContainerDetail VALUES (@IdContainer,@GuideSerie,@GuideNumber,@TicketNumber,1,'SYS-PICKUP',GETDATE(),'SYS-PICKUP',NULL,NULL,NULL)
		
		UPDATE ShippingContainer
		SET CountGuides = CountGuides + 1
		WHERE IdContainer = @IdContainer
		
		IF @GuidePiece <> 0			
		BEGIN 
			UPDATE DeliveryOrderPiece
				SET IsNewInContainer = 1
				WHERE GuideSerie = @GuideSerie
					AND GuideNumber = @GuideNumber
					AND NoPiece = @GuidePiece
		END
		ELSE
		BEGIN
			UPDATE DeliveryOrderPiece
			SET IsNewInContainer = 1
			WHERE GuideSerie = @GuideSerie
				AND GuideNumber = @GuideNumber
		END

	END;

	IF @GuidePiece <> 0
	BEGIN
		UPDATE DeliveryOrderPiece
		SET IdStatusGuideByContainer = @StatusScannedGuideByContainer
		WHERE GuideSerie = @GuideSerie
			AND GuideNumber = @GuideNumber
			AND NoPiece = @GuidePiece

		SELECT 200 AS StatusCode,
				@Description AS [Message],
				DO.Guide_Serie AS GuideSerie,
				DO.Guide_Number AS GuideNumber,
				DOP.NoPiece AS GuidePieces,
				ISNULL(DO.Ticket_Number, '') AS TicketNumber,
				ISNULL(DO.Ticket_Number, '') AS [Description],
				DO.DateCreated,
				ISNULL(A2.[Name], A2.[Description]) AS Customer,
				ISNULL(CAT.[Name], 'Pendiente') AS StatusGuide,
				SC.IdCustomer AS IdCustomer,
				@isNEwRegistGuide AS NewRegister
		FROM DeliveryOrder DO WITH (NOLOCK)
		INNER JOIN Customer A2 WITH (NOLOCK) 
			ON DO.IdCustomer = A2.IdCustomer
		INNER JOIN DeliveryOrderPiece DOP WITH (NOLOCK)
			ON DO.Guide_Serie = DOP.GuideSerie
			AND DO.Guide_Number = DOP.GuideNumber
		LEFT JOIN ShippingContainerDetail SCD WITH (NOLOCK)
			ON SCD.GuideSerie = DO.Guide_Serie
			AND SCD.GuideNumber = DO.Guide_Number
		INNER JOIN ShippingContainer SC WITH (NOLOCK)
			ON SC.IdContainer = SCD.IdContainer
		LEFT JOIN CatStatusGuideByContainer CAT WITH (NOLOCK)
			ON CAT.IdStatus = DOP.IdStatusGuideByContainer
		WHERE SC.ReferenceContainer = @ReferenceContainer
			AND SCD.RowStatus = 1 
			AND DO.IdCustomer = @IdCustomer
			AND DO.Guide_Serie = @GuideSerie
			AND DO.Guide_Number = @GuideNumber
			AND DOP.NoPiece = @GuidePiece;

	END
	ELSE
	BEGIN
		UPDATE DeliveryOrderPiece
		SET IdStatusGuideByContainer = @StatusScannedGuideByContainer
		WHERE GuideSerie = @GuideSerie
			AND GuideNumber = @GuideNumber

		SELECT 200 AS StatusCode,
				@Description AS [Message],
				DO.Guide_Serie AS GuideSerie,
				DO.Guide_Number AS GuideNumber,
				DOP.NoPiece AS GuidePieces,
				ISNULL(DO.Ticket_Number, '') AS TicketNumber,
				ISNULL(DO.Ticket_Number, '') AS [Description],
				DO.DateCreated,
				ISNULL(A2.[Name], A2.[Description]) AS Customer,
				ISNULL(CAT.[Name], 'Pendiente') AS StatusGuide,
				SC.IdCustomer AS IdCustomer,
				@isNEwRegistGuide AS NewRegister
		FROM DeliveryOrder DO WITH (NOLOCK)
		INNER JOIN Customer A2 WITH (NOLOCK) 
			ON DO.IdCustomer = A2.IdCustomer
		INNER JOIN DeliveryOrderPiece DOP WITH (NOLOCK)
			ON DO.Guide_Serie = DOP.GuideSerie
			AND DO.Guide_Number = DOP.GuideNumber
		LEFT JOIN ShippingContainerDetail SCD WITH (NOLOCK)
			ON SCD.GuideSerie = DO.Guide_Serie
			AND SCD.GuideNumber = DO.Guide_Number
		INNER JOIN ShippingContainer SC WITH (NOLOCK)
			ON SC.IdContainer = SCD.IdContainer
		LEFT JOIN CatStatusGuideByContainer CAT WITH (NOLOCK)
			ON CAT.IdStatus = DOP.IdStatusGuideByContainer
		WHERE SC.ReferenceContainer = @ReferenceContainer
			AND SCD.RowStatus = 1 
			AND DO.IdCustomer = @IdCustomer
			AND DO.Guide_Serie = @GuideSerie
			AND DO.Guide_Number = @GuideNumber;
		END

END;