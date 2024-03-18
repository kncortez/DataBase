-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-03-13>
-- Description:	<Consulta para determinar si la guía y/o pieza de Forza se pueden relacionar con los códigos de las guías y/o piezas externas.>
-- =============================================

CREATE PROCEDURE [dbo].[spGetQueryRelationshipPieceCode]
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT,
    @NoPiece INT,
    @GuideExternal NVARCHAR(300),
    @PieceExternal NVARCHAR(100)
AS
BEGIN
	BEGIN TRY
	 
	DECLARE @pGuideNumber INT;
	DECLARE @pGuideSerie NVARCHAR(4);
	DECLARE @pNoPiece INT;
	DECLARE @pGuideExternal NVARCHAR(300);
    DECLARE @pPieceExternal NVARCHAR(100);
    DECLARE @pDescripcion INT = 0;

	--La guía externa ya está relacionada con una guía de Forza.
	SELECT @pGuideNumber = [Guide_Number], @pGuideSerie = [Guide_Serie]
	FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] WITH (NOLOCK)
	WHERE [Ticket_Number] = @GuideExternal AND [Guide_Number] != @GuideNumber

	IF (@pGuideNumber IS NULL)
	BEGIN

		--La pieza externa ya está relacionada con una pieza de Forza.
		SELECT @pGuideNumber = [GuideNumber], @pGuideSerie = [GuideSerie], @pNoPiece = [NoPiece]
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] WITH (NOLOCK)
		WHERE [ExternalPieceId] = @PieceExternal

		IF (@pGuideNumber IS NULL)
		BEGIN
			--La guía de Forza ya tiene asociada una guía externa.
			SELECT 
				@pGuideExternal = DO.[Ticket_Number],
				@pPieceExternal = DOP.[ExternalPieceId]
			FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH (NOLOCK)
				ON DOP.[GuideSerie] = DO.[Guide_Serie] AND DOP.[GuideNumber] = DO.[Guide_Number]
			WHERE DOP.[GuideSerie] = @GuideSerie AND DOP.[GuideNumber] = @GuideNumber AND DOP.[NoPiece] = @NoPiece

			IF (@pGuideExternal IS NOT NULL)
			BEGIN
				SET @pDescripcion = 3; --La pieza de Forza ya está asociada a una pieza externa. ¿Desea actualizarla?
			END;
		END;
		ELSE
		BEGIN
			SET @pDescripcion = 2; --La pieza externa ya está asociada a una pieza de Forza.
		END;
	END;
	ELSE
	BEGIN
		SET @pDescripcion = 1; --La guía externa ya se encuentra asociada a una guía de Forza.
	END;

	IF(@pDescripcion = 0)
	BEGIN	
		SELECT 
				'' AS 'GuideForza',
				'' AS 'GuideDHL',
				'' AS 'PieceForza',
				'' AS 'PieceDHL',
				0  AS 'Message'
	END;
	ELSE
	BEGIN
		SELECT 
				CONCAT(@pGuideSerie, @pGuideNumber) AS 'GuideForza',
				@pGuideExternal AS 'GuideDHL',
				CONCAT(@pGuideSerie, @pGuideNumber, '-', @pNoPiece) AS 'PieceForza',
				@pPieceExternal AS 'PieceDHL',
				@pDescripcion  AS 'Message'
	END;

	END TRY
	BEGIN CATCH
		SELECT
				'' AS 'GuideForza',
				'' AS 'GuideDHL',
				'' AS 'PieceForza',
				'' AS 'PieceDHL',
				ERROR_MESSAGE() AS 'Message'
	END CATCH;
END
