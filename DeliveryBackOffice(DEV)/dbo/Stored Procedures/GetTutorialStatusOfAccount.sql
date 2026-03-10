
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-09-05>
-- Description:	< Obtener si a usuario se le debe desplegar algun tutorial >
-- =============================================
-- Modified:    <Brenda, Echeverria>
-- Create date: <2026-03-04>
-- Description: < Se paso el filtro del inner join al where >
-- =============================================
CREATE PROCEDURE [dbo].[GetTutorialStatusOfAccount]
	@AccountId BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT
		Tut.IdTutorial,
		Tut.TutorialName,
		Tut.TutorialDescription
	FROM
		[DeliveryBackOffice].[dbo].[TutorialByAccount] TBA WITH(NOLOCK)
	INNER JOIN
		[DeliveryBackOffice].[dbo].[Tutorial] Tut WITH(NOLOCK)
		ON
			TBA.TutorialId = Tut.IdTutorial				
	WHERE
		TBA.AccountId = @AccountId
		AND
		TBA.ToDisplay = 1
		AND
		TBA.RowStatus = 1
		AND
		Tut.RowStatus = 1;

END