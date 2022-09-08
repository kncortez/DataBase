-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-09>
-- Description:	<Método para Cancelar procesos abiertos en preparación de entregas en hermes mobile>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_CancelOpenProcessesPreparationDeliveries] 
	@GuideSerie AS NVARCHAR(2),
	@GuideNumber AS INT,
	@Token AS NVARCHAR(50)

AS
BEGIN
      DECLARE @IdDetail AS INT;
	  DECLARE @Result AS INT = 0; /* 0 GUÍA SIN PROCESO ABIERTO */
	  
		SET NOCOUNT ON;
		SELECT @IdDetail = ISNULL(LRPCD.IdRoutePreparationDetail,0)
					FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetail] LRPCD WITH (NOLOCK)
					WHERE LRPCD.Guide_Serie  = @GuideSerie   AND 
						  LRPCD.Guide_Number = @GuideNumber  AND 
						  LRPCD.UserProcess  = @Token        AND 
						  LRPCD.RowStatus=1                  AND 
						  LRPCD.IsOpenProcess = 1

   IF (@IdDetail > 0 OR  @IdDetail IS NOT NULL)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY

			UPDATE [DeliveryBackOffice].[dbo].[RoutePreparationDetail] 
			SET    UserProcess = NULL,
				   IsOpenProcess = 0,
				   RowStatus = 0
			WHERE  Guide_Serie   =  @GuideSerie   AND 
				   Guide_Number  =  @GuideNumber  AND 
				   UserProcess   =  @Token        AND 
				   RowStatus=1                    AND 
				   IsOpenProcess = 1;
           
		   UPDATE [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece]
		   SET RowStatus =0
		   WHERE RoutePreparationDetailId = @IdDetail;
			
			SET @RESULT = 1; /* PROCESESO EXITOSO */
		COMMIT TRANSACTION
		
        END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				SET @RESULT = 2; /* PROCESESO FALLIDO */
			END  CATCH
	END 
	
     
	 SELECT @Result AS Result;

END