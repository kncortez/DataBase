-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2024-09-02>
-- Description:	<Sp para revertir estado de guias>
-- =============================================

CREATE PROCEDURE [dbo].[SupportSetReversalStatus]
    @GuideSerie NVARCHAR(2)
  , @GuideNumber INT
  , @IdStatus INT
  , @UserToken NVARCHAR(100)
  , @DateCreated DATETIME
AS
BEGIN

    DECLARE @CurrentStatus INT;
    DECLARE @lastStatus INT;

    SELECT @CurrentStatus = ord.StatusOrderId
    FROM dbo.DeliveryOrder ord
    WHERE ord.Guide_Serie = @GuideSerie
          AND ord.Guide_Number = @GuideNumber;


    IF @CurrentStatus IN ( 24 )
    BEGIN
        SELECT 'Estos estados no pueden ser revertidos';
    END;
    ELSE
    BEGIN

        IF EXISTS
        (
            SELECT 1
            FROM dbo.DeliveryOrderDetail
            WHERE Guide_Serie = @GuideSerie
                  AND Guide_Number = @GuideNumber
                  AND StatusOrderId = @IdStatus
                  AND UserCreated = @UserToken
                  AND DateCreated = @DateCreated
        )
        BEGIN

            BEGIN TRY

                BEGIN TRANSACTION;

                DELETE dbo.DeliveryOrderDetail
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber
                      AND StatusOrderId = @IdStatus
                      AND UserCreated = @UserToken
                      AND DateCreated = @DateCreated;

                SELECT TOP 1
                       @lastStatus = did.StatusOrderId
                FROM dbo.DeliveryOrderDetail did
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber
                      AND StatusOrderId != @IdStatus
                ORDER BY did.DateCreated DESC;

                UPDATE dbo.DeliveryOrder
                SET StatusOrderId = @lastStatus
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber;

                COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                ROLLBACK TRANSACTION;
                SELECT ERROR_NUMBER()
                     , ERROR_MESSAGE()
                     , ERROR_LINE();
            END CATCH;
        END;
        ELSE
        BEGIN
            SELECT 'No existe el estado seleccionado para revertir verifique sus datos de entrada';
        END;
    END;
END;