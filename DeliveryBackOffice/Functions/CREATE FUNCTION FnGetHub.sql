USE [DeliveryBackOffice]
GO
/****** Object:  UserDefinedFunction [dbo].[FnGetHub]    Script Date: 31/01/2022 08:24:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Devuelve el ID de un HUB dando como entrada el ID del Township(Municipio)
CREATE FUNCTION [dbo].[FnGetHub](
    @IdTown INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    
    DECLARE @Hub NVARCHAR(10) =
	(SELECT TOP 1 Hub FROM DeliveryBackOffice.dbo.DumpServiceCoverage
							  WHERE HeaderCode = (SELECT HeaderCode FROM DeliveryBackOffice.dbo.Township
												  WHERE IdTownship = @IdTown))

    
    RETURN @Hub
 
END
