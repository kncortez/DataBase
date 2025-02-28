-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-04-02>
-- Description:	<Método para devolver la información del pago de COD para notificaciones>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_GetCODInformationNoti]
@BatchCODId INT
AS
BEGIN
    BEGIN TRY
        SELECT  a.AccIdAccount AS [IdAccount],
                bdc.GuideSerie AS [GuideSerie],
                bdc.GuideNumber AS [GuideNumber],
                bdc.AccountNumber AS [AccountNumber],
                bdc.Amount AS [Amount],
                ISNULL(bdc.IdCountry,'GT') AS [IdCountry]
            FROM BatchDetailCOD bdc
            INNER JOIN DeliveryOrder do ON bdc.GuideSerie = do.Guide_Serie AND bdc.GuideNumber = do.Guide_Number
            INNER JOIN Account a ON do.IdCustomer = a.IdCustomer
            WHERE bdc.BatchCODId = @BatchCODId AND bdc.Excluded = 0
    END TRY
    BEGIN CATCH
        SELECT 0 AS [StatusCode], ERROR_MESSAGE() AS [Message]
            INSERT INTO dbo.RoutePreparationLogError
            (
                ErrorDescription,
                ErrorNumber,
                ErrorProcedure,
                ErrorLine,
                GuideSerie,
                GuideNumber,
                TokenCreated,
                DateCreated
            )
            VALUES
            (CAST(ERROR_MESSAGE() AS VARCHAR(300))
                    ,ERROR_NUMBER()
                    ,CAST(ERROR_PROCEDURE() AS VARCHAR(100))
                    ,ERROR_LINE()
                    ,0
                    ,0
                    ,'Error al consultar información de COD'
                    ,GETDATE())
    END CATCH;
END