USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_document_image_url]    Script Date: 25/07/2020 15:44:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fn_get_rackposition]
    (
      @GuideSerie NVARCHAR(2),
	  @GuideNumber INT
    )
   RETURNS VARCHAR(MAX)
AS

BEGIN

	DECLARE @location VARCHAR(MAX) 

	SELECT @location = COALESCE(@location + ', ','') + Rack_Position
	FROM   (SELECT DISTINCT Rack_Position 
			FROM   Warehouse 
			WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber AND Active = 1) wh
	
RETURN @location
END



GO


