
/* =================================================
   SP:        [dbo].[GetLastWorkingDayByVisitPoint]
   Propósito: Obtiene la fecha más antigua con actividad pendiente de cierre.
   Autor:     Keila Cortéz
   Historia:  FDAPI-5784
   Fecha:     2026-05-19
============================================
=== CHANGELOG ================================
2026-05-19 | Historia/épica: FDAPI-5784 | Autor: Keila Cortéz |
=========================================== */

CREATE PROCEDURE [dbo].[sp_GetLastWorkingDayByVisitPoint]
    @visitPoint INT
AS
BEGIN
    SET NOCOUNT ON;

    WITH Operadores AS
    (
        SELECT DISTINCT
            RUA.RuaIdAccount AS AccountId
        FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointByUser] VPU WITH (NOLOCK)
            ON VPU.IdVisitPointClient = VPC.IdVisitPointClient
        INNER JOIN [DeliveryBackOffice].[dbo].[RegisterUser] RU WITH (NOLOCK)
            ON RU.UsrIdUser = VPU.RegisterUserID
        INNER JOIN [DeliveryBackOffice].[dbo].[RolByUserByAccount] RUA WITH (NOLOCK)
            ON RUA.RuaIdUser = RU.UsrIdUser
            AND RUA.RuaRowStatus = 1
        WHERE VPC.CodeOfReference = @visitPoint
          AND VPU.RowStatus = 1
    ),
    FechasPorOperador AS
    (
        SELECT
            O.AccountId,
            MIN(CAST(DOPT.DateCreated AS DATE)) AS Fecha
        FROM Operadores O
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentTransaction] DOPT WITH (NOLOCK)
            ON DOPT.AccountId = O.AccountId
        WHERE DOPT.VisitPoint = @visitPoint
          AND DOPT.ShipmentCompleted = 1
          AND NOT EXISTS
          (
              SELECT 1
              FROM [DeliveryBackOffice].[dbo].[AccountingClosuresDetail] ACD WITH (NOLOCK)
              WHERE ACD.DopId = DOPT.DopId
                AND ACD.RowStatus = 1
          )
        GROUP BY
            O.AccountId
    ),
    FechasValidas AS
    (
        SELECT
            F.AccountId,
            F.Fecha
        FROM FechasPorOperador F
        WHERE EXISTS
        (
            SELECT 1
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentTransaction] DOPT WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DOR WITH (NOLOCK)
                ON DOR.Guide_Serie = DOPT.GuideSerie
                AND DOR.Guide_Number = DOPT.GuideNumber
            WHERE DOPT.AccountId = F.AccountId
              AND CAST(DOPT.DateCreated AS DATE) = F.Fecha
              AND DOPT.VisitPoint = @visitPoint
              AND DOPT.ShipmentCompleted = 1
              AND DOR.StatusOrderId != 7
              AND (
                    ISNULL(DOPT.Amount, 0) > 0
                    OR ISNULL(DOPT.CODAmountProcess, 0) > 0
                  )
              AND DOPT.TypeofInOutMoneyId != 8
              AND NOT EXISTS
              (
                  SELECT 1
                                    FROM [DeliveryBackOffice].[dbo].[AccountingClosuresDetail] ACD WITH (NOLOCK)
                  WHERE ACD.DopId = DOPT.DopId
                    AND ACD.RowStatus = 1
              )
        )
    )
    SELECT
        MIN(Fecha) AS Fecha
    FROM FechasValidas;
END