USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetArticlesSAP]    Script Date: 29/10/2021 16:07:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-10-12>
-- Description:	<Obtiene información de artículos SAP>
-- =============================================

ALTER PROCEDURE [dbo].[GetArticlesSAP] 
-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT IdCatCategoryArticleSAP Id
		, Name
		, Description
	FROM CatArticleCategorySAP 
	WHERE RowSatus = 1
	ORDER BY Id ASC

	SELECT IdCatArticleSAP Id
		,CatCategoryArticleSAPId IdCategory
		,Name
		,Description
		,SAPCode
		,Category
		,Price
		,CardPercent
		,CardAmount
		,IsSurcharge
	FROM CatArticleSAP
	WHERE RowSatus = 1
	ORDER BY Id ASC

	SET NOCOUNT OFF;
END