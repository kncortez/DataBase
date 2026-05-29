-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2025-09-16>
-- Description:	<Asignación de Articulo a Pieza>
-- =============================================
--=================================================================================
--== Proyecto Ultra Entregas  --  WeebhookService
--== REF.: https://cashlogisticsgroup.atlassian.net/browse/FDAPI-4063
--== Configuración Inicial
--=================================================================================

CREATE PROCEDURE [dbo].SupportUpdateParcelCode
    @GuideSerie NVARCHAR(3) --= 6
  , @GuideNumber INT    --= 'Caja 30'
  , @ParcelCode NVARCHAR(20)
  , @Token NVARCHAR(50)  --= 'SYS-CAQUINO'


AS
BEGIN

    BEGIN TRY

        BEGIN TRANSACTION;

        

		UPDATE dbo.DeliveryOrderPiece
		SET	 ParcelCode = @ParcelCode
		, TokenRegistrationExternalCode = @Token
		, DateRegistrationExternalCode = GETDATE()
		WHERE GuideSerie =@GuideSerie AND GuideNumber = @GuideNumber

        COMMIT TRANSACTION;

        SELECT 'Pieza configurada correctamente';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_LINE()
             , ERROR_MESSAGE()
             , ERROR_NUMBER();
    END CATCH;

END;