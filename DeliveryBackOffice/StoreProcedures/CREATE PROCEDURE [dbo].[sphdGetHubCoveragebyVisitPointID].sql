USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sphdGetHubCoveragebyVisitPointID]    Script Date: 6/25/2021 6:28:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-05-31>
-- Description:	<get all hub for segment id by visitpointid>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetHubCoveragebyVisitPointID]
	-- Add the parameters for the stored procedure here
	@IdVisitPoint AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		SELECT vcov.IdVpbySegment,
			   vcov.VisitPointId,
			   vcov.SegmentId,
			   vcov.HubLogisticId,
			   vcov.RowStatus
		FROM dbo.VisitPointCoverage vcov
		WHERE vcov.VisitPointId = @IdVisitPoint--160103
			  AND vcov.RowStatus = 'TRUE';
END
GO


