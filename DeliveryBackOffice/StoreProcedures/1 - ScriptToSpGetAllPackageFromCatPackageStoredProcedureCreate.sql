USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sp_get_all_package_from_catpackage]    Script Date: 9/07/2021 16:23:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_all_package_from_catpackage]
AS
BEGIN

DECLARE @FlagEnabledPackage INT = 1;

SELECT PckId, PckName
FROM dbo.CatPackage
WHERE PckRowStatus = @FlagEnabledPackage;

END

GO


