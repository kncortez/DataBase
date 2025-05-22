/*
-- =============================================
-- Author:		<Michael Espinoza>
-- Create date: <2021-09-09>
-- Description:	<Actualiza el estado de un lote de guias a estado completado>
-- =============================================
-- Author:		<Cristian Azurdia>
-- Create date: <2025-05-22>
-- Description:	<Eliminación de Json>
-- =============================================
*/

CREATE PROCEDURE [dbo].[spws_SetCompleteStatusGuideBatch]	  	
@Token as nvarchar(50) = '',
@NumberGuides as varchar(MAX) = ''

AS

BEGIN

	DECLARE @IdResult INT;
	DECLARE @Message  NVARCHAR(MAX);
	DECLARE @COUNTGUIDES INT = 0, @IDENTYGUIDES INT = 1, @TOTAL INT = 0;
	DECLARE @TBGUIDES TABLE (ITERATOR INT IDENTITY(1,1), GuideNumber INT );

		WITH CTE
			AS (
			SELECT Split.a.value('.', 'NVARCHAR(MAX)') GuideNumber,
			       ROW_NUMBER() OVER(ORDER BY
			                        (
			                            SELECT NULL
			                        )) RN
			FROM
			(
			    SELECT CAST('<X>'+REPLACE(@NumberGuides, ',', '</X><X>')+'</X>' AS XML) AS String
			) AS A
			CROSS APPLY String.nodes('/X') AS Split(a))
			
			INSERT INTO @TBGUIDES (GuideNumber)
			       SELECT C.GuideNumber
			       FROM CTE C;

		SELECT @COUNTGUIDES = COUNT(1) FROM @TBGUIDES

      BEGIN TRANSACTION

      BEGIN TRY
			
			WHILE (@COUNTGUIDES > 0)

			BEGIN 

				DECLARE @TempGuide NVARCHAR(MAX) = (select T.GuideNumber from @TBGUIDES T where T.ITERATOR = @IDENTYGUIDES);

				UPDATE DeliveryBackOffice.dbo.GuideBatch
				SET Status = 2 -- 2 stands for status completed, this means the services were requested by customer, so now all these guides will be recollected at some point by a courier men.
				WHERE GuideSeries = 'FD' and GuideNumber = @TempGuide AND RowStatus = 1

			    SET @IDENTYGUIDES = @IDENTYGUIDES + 1;
				SET @COUNTGUIDES = @COUNTGUIDES  - 1;
			END 

      END TRY

      BEGIN CATCH

          SET @IDResult = 409;
          SET @Message = 'Error al procesar lote de guias'

      ROLLBACK TRANSACTION

      END CATCH;

      IF @@TRANCOUNT > 0 BEGIN

      COMMIT TRANSACTION;

          SET @IDResult = 200;
          SET @Message = 'Lote de guias ha sido procesado exitosamente';

      END

      SELECT @IdResult [IdResult], @Message [Message];

END
 
