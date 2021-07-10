USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sp_delete_articlebycustomer_from_articlebycustomer]    Script Date: 9/07/2021 19:53:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_delete_articlebycustomer_from_articlebycustomer]
	@IdABC INT
AS
BEGIN

DELETE FROM dbo.ArticleByCustomer
WHERE AbcId = @IdABC;

END
GO


