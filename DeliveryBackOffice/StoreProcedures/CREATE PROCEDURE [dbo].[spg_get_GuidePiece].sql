USE [DeliveryBackOffice]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-24>
-- Description:	<Retorna las piezas de una guía>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_GuidePiece]
	@numberPiece as int,
	@serieGuide as nvarchar(2),
	@numberGuide as int
AS
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
			vpc.DescriptionOfClient
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop
		JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro ON dro.Guide_Serie = dop.GuideSerie AND dro.Guide_Number = dop.GuideNumber
		JOIN DeliveryBackOffice.[dbo].[Customer] cli ON cli.IdCustomer = dro.IdCustomer
		JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc ON vpc.CodeOfReference = dro.Sender_ID 
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
			vpc.DescriptionOfClient
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop
		JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro ON dro.Guide_Serie = dop.GuideSerie AND dro.Guide_Number = dop.GuideNumber
		JOIN DeliveryBackOffice.[dbo].[Customer] cli ON cli.IdCustomer = dro.IdCustomer
		JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc ON vpc.CodeOfReference = dro.Sender_ID 
		WHERE dop.GuideSerie = @serieGuide AND dop.GuideNumber = @numberGuide AND dop.NoPiece = @numberPiece
	END
END