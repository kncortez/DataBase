USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetArticlesSAP]    Script Date: 12/10/2021 17:18:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-10-12>
-- Description:	<Obtiene información de artículos SAP>
-- =============================================

CREATE PROCEDURE [dbo].[GetArticlesSAP] 
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
	FROM CatArticleSAP
	WHERE RowSatus = 1
	ORDER BY Id ASC

	SET NOCOUNT OFF;
END