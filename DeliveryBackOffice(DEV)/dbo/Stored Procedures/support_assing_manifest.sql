-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2023-04-03>
-- Description:	<Traslado de manifiesto entre courierman>
-- =============================================
-- =============================================
-- Author:		<Carlos Valdes>
-- Create date: <2025-06-05>
-- Description:	<Traslado de manifiesto entre courierman>
-- =============================================
CREATE PROCEDURE [dbo].[support_assing_manifest]
    @manifiesto INT,  -- Id de maniefiesto de última milla
    @DPI NVARCHAR(25) -- dpi de courierman que se va a asignar
AS
BEGIN

    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.DeliveryOrderBySettlement st WITH (NOLOCK)
        WHERE st.ID = @manifiesto
              AND CONVERT(DATE, st.Date_Dispatched) = CONVERT(DATE, GETDATE())
    )
    BEGIN

        DECLARE @IdCourierman INT = 0;
        SET @IdCourierman =
        (
            SELECT TOP 1 sr.ID FROM dbo.SenderReceiver sr WITH (NOLOCK)
			WHERE sr.CUI = @DPI
        );

        IF @IdCourierman > 0
        BEGIN

            BEGIN TRANSACTION;
            BEGIN TRY


                UPDATE dbo.DeliveryOrderBySettlement
                SET ID_Courier = @IdCourierman
                WHERE ID = @manifiesto;
                UPDATE dbo.DeliveryAttempt
                SET ID_Courier = @IdCourierman
                WHERE ID_DeliveryOrderBySettlement = @manifiesto;

                COMMIT TRANSACTION;
                SELECT 'Cambios realizados exitosamente';

            END TRY
            BEGIN CATCH

                ROLLBACK TRANSACTION;
                SELECT CAST(ERROR_NUMBER() AS NVARCHAR) AS ErrorNumber,
                       CAST(ERROR_SEVERITY() AS NVARCHAR) AS ErrorSeverity,
                       CAST(ERROR_STATE() AS NVARCHAR) AS ErrorState,
                       CAST(ERROR_PROCEDURE() AS NVARCHAR) AS ErrorProcedure,
                       CAST(ERROR_LINE() AS NVARCHAR) AS ErrorLine,
                       CAST(ERROR_MESSAGE() AS NVARCHAR) AS ErrorMessage;

            END CATCH;
        END;
        ELSE
        BEGIN
            SELECT 'El courierman no existe por favor verifica el número de dpi';
        END;
    END;
    ELSE
    BEGIN
        SELECT 'El manifiesto no existe o no fue despachado el día de hoy por favor verifica el número';
    END;



END;