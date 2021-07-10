USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sp_get_typearticle_by_package_from_cattypearticle]    Script Date: 9/07/2021 16:41:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_typearticle_by_package_from_cattypearticle]
	@IdPackage INT
AS
BEGIN

--DECLARE @IdPackage INT = 1;
DECLARE @FlagEnabledTypeArticle INT = 1;

SELECT TarId, TarName
FROM dbo.CatTypeArticle
WHERE TarRowStatus = @FlagEnabledTypeArticle
AND TarIdPackage = @IdPackage;

END
GO


