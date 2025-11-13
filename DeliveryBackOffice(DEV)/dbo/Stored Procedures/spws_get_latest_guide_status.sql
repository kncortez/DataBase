-- =============================================
-- Author:		<Freddy>
-- Create date: <2025-11-12>
-- Description:	<Obtiene el estado más reciente de una guía por serie y número>
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[spws_get_latest_guide_status]
    @GuideSerie NVARCHAR(50),
    @GuideNumber INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        s.StatusOrderId,
        s.OrderDescription,
        s.CatCheckpointTypeId
    FROM dbo.DeliveryOrder AS d WITH (NOLOCK)
        INNER JOIN dbo.StatusOrder AS s WITH (NOLOCK)
        ON d.StatusOrderId = s.StatusOrderId
    WHERE d.Guide_Serie = @GuideSerie
        AND d.Guide_Number = @GuideNumber
    ORDER BY d.DateUpdated DESC;
END;
GO
