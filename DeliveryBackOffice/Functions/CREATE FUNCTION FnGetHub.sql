USE [DeliveryBackOffice]
GO
/****** Object:  UserDefinedFunction [dbo].[FnGetHub]    Script Date: 31/01/2022 15:39:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Devuelve el ID de un HUB dando como entrada el ID del Township(Municipio)
ALTER FUNCTION [dbo].[FnGetHub](
    @IdTown INT
)
RETURNS INT
AS
BEGIN
    
    DECLARE @Hub INT =
	(SELECT IdHubLogistic FROM DeliveryBackOffice.dbo.HubLogistics
							WHERE HubAbbreviation = (SELECT TOP 1 Hub FROM DeliveryBackOffice.dbo.DumpServiceCoverage
							  WHERE HeaderCode = (SELECT HeaderCode FROM DeliveryBackOffice.dbo.Township
												  WHERE IdTownship = @IdTown)))

    
    RETURN @Hub
 
END
