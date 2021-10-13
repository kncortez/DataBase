USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spget_all_express_center]    Script Date: 12/10/2021 15:49:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spget_all_express_center]
AS
BEGIN

DECLARE @StatusClient INT = 1;
DECLARE @CountryId VARCHAR(2) = 'GT';
DECLARE @IdKindOfVPClient INT = 1;

SELECT CodeOfReference, 
	   DescriptionOfClient
FROM DeliveryBackOffice.dbo.VisitPointClient
WHERE StatusClient = @StatusClient
AND CountryId = @CountryId
AND IdKindOfVPClient = @IdKindOfVPClient;

END

GO


