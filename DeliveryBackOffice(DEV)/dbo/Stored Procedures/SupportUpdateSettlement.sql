-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2025-09-16>
-- Description:	<Asignación de poblado a deliveryorder>
-- =============================================
--=================================================================================
--== Proyecto Ultra Entregas  --  WeebhookService
--== REF.: https://cashlogisticsgroup.atlassian.net/browse/FDAPI-4063
--== Configuración Inicial
--=================================================================================

CREATE PROCEDURE [dbo].SupportUpdateSettlement
    @GuideSerie NVARCHAR(3) --= 6
  , @GuideNumber INT        --= 'Caja 30'
  , @SettlementId INT
  , @Token NVARCHAR(50)     --= 'SYS-CAQUINO'


AS
BEGIN

    BEGIN TRY

        BEGIN TRANSACTION;


        UPDATE dbo.DeliveryOrder
        SET ReceiverIdSettlement = @SettlementId
          , TokenUpdated = @Token
        WHERE Guide_Serie = @GuideSerie
              AND Guide_Number = @GuideNumber;

        COMMIT TRANSACTION;

        SELECT 'Poblado configurado correctamente';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_LINE()
             , ERROR_MESSAGE()
             , ERROR_NUMBER();
    END CATCH;

END;