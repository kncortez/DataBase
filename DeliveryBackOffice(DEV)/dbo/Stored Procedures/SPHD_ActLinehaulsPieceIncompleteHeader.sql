-- =============================================
-- Author:		<Edelman Váquez>
-- Create date: <2022-08-11>
-- Description:	<Encabezado de reporte de actas rutas linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ActLinehaulsPieceIncompleteHeader] 
	
@IdAct AS INT
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
		SELECT  DISTINCT   'ACT'+Cast(A.IdAct AS varchar) AS IdAct, 
		       A.ResponsibleName Piloto,
			   CTA.ActName,
			   (
				select  COUNT(IsDryPiece) from
				dbo.ActDetailPiece 
				where ActDetailId in(select IdActDetail
				from dbo.ActDetail 
				where ActId=A.IdAct) and IsDryPiece=1) PiezasSecasTotal,
			   (select  COUNT(IsDryPiece) 
			    from dbo.ActDetailPiece 
				where ActDetailId in(select IdActDetail
				from dbo.ActDetail 
				where ActId=A.IdAct) and IsDryPiece=0) PiezasFriasTotal,
			   AD2.TotalGuide,
			   FORMAT(A.DateCreated,'dd/MM/yyyy') AS DateCreated,
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
		GROUP BY A.IdAct,A.ResponsibleName,
				CTA.ActName,
				AD.GuideDryPieceTotal,
				AD.GuideColdPieceTotal,
				AD2.TotalGuide,
				A.DateCreated,AD.RowStatus

END