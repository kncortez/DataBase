USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_get_GuidePiece]    Script Date: 16/02/2022 10:05:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-24>
-- Description:	<Retorna las piezas de una guía>
-- =============================================
ALTER PROCEDURE [dbo].[spg_get_GuidePiece]
	@numberPiece AS INT,
	@serieGuide AS NVARCHAR(2),
	@numberGuide AS INT
AS
BEGIN
	IF EXISTS (SELECT GuideNumber FROM DeliveryBackOffice.dbo.DeliveryOrderPiece WITH(NOLOCK)
		   WHERE GuideSerie = @serieGuide AND GuideNumber = @numberGuide)
	BEGIN
		IF @numberPiece = 0
		BEGIN
			IF (SELECT IdCustomer 
				FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
				WHERE Guide_Number = @numberGuide AND Guide_Serie = @serieGuide) is NULL
			BEGIN
				SELECT dop.GuideSerie,
					dop.GuideNumber,
					dop.NoPiece,
					dop.Detail,
					dop.PiecePhysicalWeight,
					dop.PieceWeight,
					'Punto Vacio' as Name,
					vpc.DescriptionOfClient,
					dop.CategoryCheck
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop WITH(NOLOCK)
				JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro WITH(NOLOCK) ON dro.Guide_Serie = dop.GuideSerie AND dro.Guide_Number = dop.GuideNumber
				JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc WITH(NOLOCK) ON vpc.CodeOfReference = dro.Sender_ID 
				WHERE dop.GuideSerie = @serieGuide AND dop.GuideNumber = @numberGuide
			END
			ELSE
			BEGIN
				SELECT dop.GuideSerie,
					dop.GuideNumber,
					dop.NoPiece,
					dop.Detail,
					dop.PiecePhysicalWeight,
					dop.PieceWeight,
					cli.Name,
					vpc.DescriptionOfClient,
					dop.CategoryCheck
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop WITH(NOLOCK)
				JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro WITH(NOLOCK) ON dro.Guide_Serie = dop.GuideSerie AND dro.Guide_Number = dop.GuideNumber
				JOIN DeliveryBackOffice.[dbo].[Customer] cli WITH(NOLOCK) ON cli.IdCustomer = dro.IdCustomer
				JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc WITH(NOLOCK) ON vpc.CodeOfReference = dro.Sender_ID 
				WHERE dop.GuideSerie = @serieGuide AND dop.GuideNumber = @numberGuide
			END
		END
		ELSE 
		BEGIN
			IF (SELECT IdCustomer 
				FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
				WHERE Guide_Number = @numberGuide AND Guide_Serie = @serieGuide) IS NULL
			BEGIN
				SELECT dop.GuideSerie,
					dop.GuideNumber,
					dop.NoPiece,
					dop.Detail,
					dop.PiecePhysicalWeight,
					dop.PieceWeight,
					'Punto Vacio' as Name,
					vpc.DescriptionOfClient,
					dop.CategoryCheck
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop WITH(NOLOCK)
				JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro WITH(NOLOCK) ON dro.Guide_Serie = dop.GuideSerie AND dro.Guide_Number = dop.GuideNumber
				JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc WITH(NOLOCK) ON vpc.CodeOfReference = dro.Sender_ID 
				WHERE dop.GuideSerie = @serieGuide AND dop.GuideNumber = @numberGuide AND dop.NoPiece = @numberPiece
			END
			ELSE
			BEGIN
				SELECT dop.GuideSerie,
					dop.GuideNumber,
					dop.NoPiece,
					dop.Detail,
					dop.PiecePhysicalWeight,
					dop.PieceWeight,
					cli.Name,
					cli.IdCustomer,
					vpc.DescriptionOfClient,
					dop.CategoryCheck
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop WITH(NOLOCK)
				JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro WITH(NOLOCK) ON dro.Guide_Serie = dop.GuideSerie AND dro.Guide_Number = dop.GuideNumber
				JOIN DeliveryBackOffice.[dbo].[Customer] cli WITH(NOLOCK) ON cli.IdCustomer = dro.IdCustomer
				JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc WITH(NOLOCK) ON vpc.CodeOfReference = dro.Sender_ID 
				WHERE dop.GuideSerie = @serieGuide AND dop.GuideNumber = @numberGuide AND dop.NoPiece = @numberPiece
			END
		END
	END
	ELSE
	BEGIN
		DECLARE @count int
		SET @count = 0

		DECLARE @statusOrderId int
		SELECT @statusOrderId = StatusOrderId FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK) WHERE Guide_Serie = @serieGuide AND Guide_Number = @numberGuide

		WHILE @count < (SELECT SUM(Pieces_Dry + Pieces_Cold) 
						FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
						WHERE Guide_Serie = @serieGuide AND Guide_Number = @numberGuide)
		BEGIN
			INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderPiece 
			(GuideSerie,GuideNumber,Currency,DateCreated,NoPiece,StatusOrderId)
			VALUES (@serieGuide,@numberGuide,'GTQ',GETDATE(),@count + 1,@statusOrderId)
			SET @count = @count + 1
		END

		IF (SELECT IdCustomer 
			FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
			WHERE Guide_Number = @numberGuide AND Guide_Serie = @serieGuide) IS NULL
		BEGIN
			IF @numberPiece = 0
			BEGIN
				SELECT dop.GuideSerie,
					dop.GuideNumber,
					dop.NoPiece,
					dop.Detail,
					dop.PiecePhysicalWeight,
					dop.PieceWeight,
					'Punto Vacio' as Name,
					vpc.DescriptionOfClient,
					dop.CategoryCheck
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop WITH(NOLOCK)
				JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro WITH(NOLOCK) ON dro.Guide_Serie = dop.GuideSerie AND dro.Guide_Number = dop.GuideNumber
				JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc WITH(NOLOCK) ON vpc.CodeOfReference = dro.Sender_ID 
				WHERE dop.GuideSerie = @serieGuide AND dop.GuideNumber = @numberGuide
			END
			ELSE 
			BEGIN
				SELECT dop.GuideSerie,
					dop.GuideNumber,
					dop.NoPiece,
					dop.Detail,
					dop.PiecePhysicalWeight,
					dop.PieceWeight,
					'Punto Vacio' AS Name,
					vpc.DescriptionOfClient,
					dop.CategoryCheck
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop WITH(NOLOCK)
				JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro WITH(NOLOCK) ON dro.Guide_Serie = dop.GuideSerie AND dro.Guide_Number = dop.GuideNumber
				JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc WITH(NOLOCK) ON vpc.CodeOfReference = dro.Sender_ID 
				WHERE dop.GuideSerie = @serieGuide AND dop.GuideNumber = @numberGuide AND dop.NoPiece = @numberPiece
			END

		END
		ELSE
		BEGIN
			IF @numberPiece = 0
			BEGIN
				SELECT dop.GuideSerie,
					dop.GuideNumber,
					dop.NoPiece,
					dop.Detail,
					dop.PiecePhysicalWeight,
					dop.PieceWeight,
					cli.Name,
					cli.IdCustomer,
					vpc.DescriptionOfClient,
					dop.CategoryCheck
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop WITH(NOLOCK)
				JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro WITH(NOLOCK) ON dro.Guide_Serie = dop.GuideSerie AND dro.Guide_Number = dop.GuideNumber
				JOIN DeliveryBackOffice.[dbo].[Customer] cli WITH(NOLOCK) ON cli.IdCustomer = dro.IdCustomer
				JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc WITH(NOLOCK) ON vpc.CodeOfReference = dro.Sender_ID 
				WHERE dop.GuideSerie = @serieGuide AND dop.GuideNumber = @numberGuide
			END
			ELSE 
			BEGIN
				SELECT dop.GuideSerie,
					dop.GuideNumber,
					dop.NoPiece,
					dop.Detail,
					dop.PiecePhysicalWeight,
					dop.PieceWeight,
					cli.Name,
					cli.IdCustomer,
					vpc.DescriptionOfClient,
					dop.CategoryCheck
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop WITH(NOLOCK)
				JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro WITH(NOLOCK) ON dro.Guide_Serie = dop.GuideSerie AND dro.Guide_Number = dop.GuideNumber
				JOIN DeliveryBackOffice.[dbo].[Customer] cli WITH(NOLOCK) ON cli.IdCustomer = dro.IdCustomer
				JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc WITH(NOLOCK) ON vpc.CodeOfReference = dro.Sender_ID 
				WHERE dop.GuideSerie = @serieGuide AND dop.GuideNumber = @numberGuide AND dop.NoPiece = @numberPiece
			END
		END
	END
END
GO


