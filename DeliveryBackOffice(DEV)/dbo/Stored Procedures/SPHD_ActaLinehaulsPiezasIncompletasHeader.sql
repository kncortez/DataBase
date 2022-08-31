-- =============================================
-- Author:		<Edelman Váquez>
-- Create date: <2022-08-11>
-- Description:	<Encabezado de reporte de actas rutas linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ActaLinehaulsPiezasIncompletasHeader] 
	
@IdAct AS INT
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
		SELECT DISTINCT A.IdAct, 
		       A.ResponsibleName Piloto,
			   CTA.ActName,
			   AD.GuideDryPieceTotal PiezasSecasTotal,
			   AD.GuideColdPieceTotal PiezasFriasTotal,
			   AD2.TotalGuide,
			   SUBSTRING(CONVERT(VARCHAR, A.DateCreated,101),1,10) AS DateCreated ,
			   AD.RowStatus
		FROM dbo.Act A WITH (NOLOCK)
		LEFT  JOIN
			 dbo.ActDetail AD WITH (NOLOCK)
	    ON A.IdAct = AD.ActId
		LEFT JOIN 	(SELECT COUNT(DD.GuideNumber) TotalGuide, DD.ActId FROM ActDetail DD
		             WHERE DD.RowStatus = 1
			          GROUP BY DD.ActId) AD2
		ON AD.ActId = AD2.ActId
		LEFT JOIN CatTypeAct CTA WITH (NOLOCK)
		ON A.CatTypeActId = CTA.IdCatTypeAct
		WHERE AD.ActId= @IdAct  
		AND AD.RowStatus=1
END