USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_SetCompleteStatusGuideBatch]    Script Date: 9/6/2021 3:21:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-- =============================================
-- Author:		<Michael Espinoza>
-- Create date: <2021-09-09>
-- Description:	<Actualiza el estado de un lote de guias a estado completado>
-- =============================================
*/

CREATE PROCEDURE [dbo].[spws_SetCompleteStatusGuideBatch]	  	
@Token as nvarchar(50) = '',
@NumberGuides as varchar(MAX) = ''

AS

BEGIN

  DECLARE @jsonResult NVARCHAR(MAX);
	DECLARE @COUNTGUIDES INT = 0, @IDENTYGUIDES INT = 1, @TOTAL INT = 0;

	DECLARE @TBGUIDES TABLE (ITERATOR INT IDENTITY(1,1), GuideNumber INT );
		;WITH CTE
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
				WHERE GuideNumber = @TempGuide AND RowStatus = 1

			    SET @IDENTYGUIDES = @IDENTYGUIDES + 1;
				SET @COUNTGUIDES = @COUNTGUIDES  - 1;
			END 

      END TRY

      BEGIN CATCH

      SET @jsonResult =
                (
                    SELECT STUFF(
                (
                    SELECT '{"IdResult": 409, "Message":"Error al procesar lote de guias"}'
                    FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'), 1, 1, '')
                );

      ROLLBACK TRANSACTION

      END CATCH;

      IF @@TRANCOUNT > 0 BEGIN

      COMMIT TRANSACTION;

      SET @jsonResult =
                (
                    SELECT STUFF(
                (
                    SELECT '{"IdResult": 200,"Message":"Lote de guias ha sido procesado exitosamente"}'
                    FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'), 1, 1, '')
                );

      END

      SELECT('[{' + @jsonResult + ']') jsonResult;

END
 
