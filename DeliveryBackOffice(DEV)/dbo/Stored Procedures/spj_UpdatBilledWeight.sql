-- =============================================
-- Author:		<César Aquino>     
-- Create date: <12-12-2022>
-- Description:	<Sp para actualizar campo BilledWeight con la data de DeliveryOrderPiece >
-- =============================================
CREATE PROCEDURE [dbo].[spj_UpdatBilledWeight]
AS
BEGIN

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    BEGIN TRANSACTION;

    BEGIN TRY

        UPDATE ord
        SET ord.BilledWeight =
            (
                SELECT SUM(ISNULL(dpp.MassWeight, ISNULL(dpp.PieceHeight, 0)))
                FROM dbo.DeliveryOrderPiece dpp
                WHERE dpp.GuideSerie = ord.Guide_Serie
                      AND dpp.GuideNumber = ord.Guide_Number
            )
        FROM dbo.DeliveryOrder ord
        WHERE ISNULL(ord.BilledWeight, 0) = 0
              AND CONVERT(DATE, ord.DateCreated)
              BETWEEN CONVERT(DATE, GETDATE() - 100) AND CONVERT(DATE, GETDATE());


        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

    END CATCH;
END;