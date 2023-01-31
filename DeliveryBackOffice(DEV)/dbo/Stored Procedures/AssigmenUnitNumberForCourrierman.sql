-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-01-31>
-- Description:	<Description,SP para obtener unidad asignada a piloto (courrierman)>
-- =============================================
CREATE PROCEDURE [dbo].[AssigmenUnitNumberForCourrierman] 
@CUI AS nvarchar(25)
AS
BEGIN
	
	SET NOCOUNT ON;

	

	SELECT  Top 1 
	        CV.UnitNumber 
	FROM [dbo].[SenderReceiver] SR 
		INNER JOIN [dbo].[RouteAssigment] RA
	ON SR.ID = RA.IdCurrierMan
		INNER JOIN [dbo].[CatVehicle] CV
	ON RA.IdVehicle =CV.IdVehicle
	WHERE SR.CUI = @CUI
	ORDER BY
	SR.Date_Created DESC

	

    
END