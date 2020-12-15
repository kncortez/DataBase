USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_get_delivery_proof]    Script Date: 15/12/2020 12:01:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <15-Diciembre-2020>
-- Description:	<Obtiene la categoría, peso y dimensiones de todas las piezas de la guía>
-- =============================================
CREATE PROCEDURE [dbo].[spg_delivery_piece_by_guide]
	-- Add the parameters for the stored procedure here
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- obtener cantidad de piezas totales (secas + frías)
	SELECT
		SUM(do.Pieces_Cold + do.Pieces_Dry) as Total_Pieces
	FROM DeliveryBackOffice.dbo.DeliveryOrder do
	WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber

	-- popular categoría basado en guía (requiere conocer cliente)
	SELECT TOP (1000) [Category_Id]
		  ,[Category_Name]
		  ,[Customer_Id]
		  --,c2.[Name]
	  FROM [DeliveryBackOffice].[dbo].[PieceCategory]
	  --JOIN DeliveryBackOffice.dbo.Customer c2 ON c2.IdCustomer = Customer_Id
	  WHERE Customer_Id IN (
		  SELECT 
			CustomerID
			--, c.[Name]
			--, Sender_ID
			--, v.DescriptionOfClient
		  FROM DeliveryBackOffice.dbo.DeliveryOrder do
		  JOIN DeliveryBackOffice.dbo.VisitPointClient v ON v.CodeOfReference = do.Sender_ID
		  JOIN DeliveryBackOffice.dbo.Customer c ON c.IdCustomer = v.CustomerID
		  WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
	  )

	-- recuperar valores de dimensiones y peso
	SELECT 
		[Guide_Serie]
		,[Guide_Number]
		,[Guide_Piece]
		,[Piece_PhysicalWeight]
		,[Piece_Category]
		,[Piece_Height]
		,[Piece_Width]
		,[Piece_Length]
		,[Piece_Weight]
	FROM DeliveryBackOffice.dbo.DeliveryPiece dp
	WHERE dp.Guide_Serie = @GuideSerie AND dp.Guide_Number = @GuideNumber

END
GO


