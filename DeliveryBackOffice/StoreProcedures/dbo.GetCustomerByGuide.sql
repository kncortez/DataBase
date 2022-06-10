USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <10/06/2022>
-- Description:	<Obtiene el cliente y visitpoint de una guía>
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomerByGuide]
	-- Add the parameters for the stored procedure here
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		cu.IdCustomer Customer
	   ,vpc.IdVisitPointClient VisitPoint
	FROM DeliveryOrder do
	LEFT JOIN VisitPointClient vpc
		ON vpc.CodeOfReference = do.Sender_ID
	INNER JOIN Customer cu
		ON cu.IdCustomer = COALESCE(do.IdCustomer, vpc.CustomerID)
	WHERE do.Guide_Serie = @GuideSerie
	AND do.Guide_Number = @GuideNumber

END
GO
