-- =============================================
-- Author:		<Edelman>
-- Create date: <2022-12-12>
-- Description:	<SP obtener hub y id por estación>
-- =============================================
CREATE PROCEDURE [dbo].[GetHubRouteLinehaulsForStation]
@IdStation AS INT
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT HL.IdHubLogistic AS Id, 
       HL.HubAbbreviation
FROM   [dbo].[CatStation] CS
       INNER JOIN 
       [dbo].[HubLogistics] HL
ON CS.HubLogisticId=HL.IdHubLogistic
WHERE CS.IdStation=@IdStation ANd CS.RowStatus=1  

END