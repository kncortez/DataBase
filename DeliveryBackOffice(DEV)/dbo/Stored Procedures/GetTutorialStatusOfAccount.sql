
/* =================================================
   SP:        [dbo].[GetTutorialStatusOfAccount]
   Propósito: Obtener si se le debe desplegar algun tutorial al usuario 
   Autor:     Andres Ruiz
   Historia:  
   Fecha:     2022-09-05
============================================
=== CHANGELOG ================================
2025-09-01 | Historia/épica: FDAPI-5759 | Autor: Brenda Echeverria |

=========================================== */
CREATE PROCEDURE [dbo].[GetTutorialStatusOfAccount]
	@AccountId BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		Tut.IdTutorial,
		Tut.TutorialName,
		Tut.TutorialDescription
	FROM
		[DeliveryBackOffice].[dbo].[TutorialByAccount] TBA WITH(NOLOCK)
		INNER JOIN [DeliveryBackOffice].[dbo].[Tutorial] Tut WITH(NOLOCK)
				ON TBA.TutorialId = Tut.IdTutorial				
	WHERE TBA.AccountId = @AccountId
		AND TBA.ToDisplay = 1
		AND TBA.RowStatus = 1
		AND Tut.RowStatus = 1;

END