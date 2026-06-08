-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2025-09-16>
-- Description:	<Reenviar peticion de webhook>
-- =============================================
--=================================================================================
--== Proyecto Ultra Entregas  --  WeebhookService
--== REF.: https://cashlogisticsgroup.atlassian.net/browse/FDAPI-4063
--== Configuración Inicial
--=================================================================================

CREATE PROCEDURE [dbo].SupportUpdateWebhookTrackingQueue
    @GuideSerie NVARCHAR(3) --= 6
  , @GuideNumber INT        --= 'Caja 30'
  , @StatusOrderId INT
  , @Token NVARCHAR(50)     --= 'SYS-CAQUINO'


AS
BEGIN

    BEGIN TRY


		IF EXISTS (SELECT * FROM WebhookTrackingQueue WHERE GuideSerie =@GuideSerie AND GuideNumber = @GuideNumber AND StatusOrderId = @StatusOrderId )
		BEGIN

        BEGIN TRANSACTION;


			UPDATE dbo.WebhookTrackingQueue
			SET	 HasNotified =0
			WHERE GuideSerie = @GuideSerie  AND GuideNumber = @GuideNumber AND StatusOrderId = @StatusOrderId AND HasNotified = 1


        COMMIT TRANSACTION;

        SELECT 'Poblado configurado correctamente';

		END
		ELSE
		BEGIN
			SELECT ' El registro no existe'
		END

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_LINE()
             , ERROR_MESSAGE()
             , ERROR_NUMBER();
    END CATCH;

END;