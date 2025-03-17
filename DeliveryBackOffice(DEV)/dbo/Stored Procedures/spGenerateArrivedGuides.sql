
-- =============================================
-- Author: <Daniel Ramirez>
-- Create date: <2024-05-09>
-- Description: < Procedimiento para automatizar el registro de arribos para guias no registrados>
-- =============================================
CREATE PROCEDURE [dbo].[spGenerateArrivedGuides]
(
 @InitDate AS DATETIME, --Fecha de inicio del periodo a considerar / Opcional - valor defecto fecha inicial del mes
 @EndDate  AS DATETIME, --Fecha final del periodo a considerar / Opcional - valor por defecto fecha final del mes
 @user     AS NVARCHAR(70) = 'SYS-MANUALINVJOB' --Usuario a reportar en los registros de guias / Opcional - valor por defecto SYS-MANUALINV + <fecha fin del mes>
)
AS
BEGIN
  BEGIN TRY

     DECLARE @factor DECIMAL(10,6)= CAST((2.00/24.00) AS DECIMAL(10,6))

     SELECT @user = CASE
                        WHEN @user IS NULL OR @user = '' THEN 'SYS-MANUALINVJOB' + FORMAT(EOMONTH(GETDATE()),'yyyyMMdd')
                           ELSE @user
                    END,
            @InitDate = CASE
                            WHEN @InitDate IS NULL OR @InitDate = '' THEN DATEADD(DAY, 1, EOMONTH(GETDATE(), -1))
                            ELSE @InitDate
                        END,
            @EndDate = CASE
                            WHEN @EndDate IS NULL OR @EndDate = '' THEN EOMONTH(GETDATE())
                            ELSE @EndDate
                        END

     IF OBJECT_ID('tempdb..#transData') IS NOT NULL
     BEGIN 
          DROP TABLE #transData
     END

     SELECT 'FD' AS Guide_Serie,
            dor.Guide_Number AS Guide_Number,
            '11' AS StatusOrderId,
            @user AS UserCreated,
            CASE
                WHEN DATEPART(MILLISECOND, dor.DateCreated) >= 500
                    THEN DATEADD(SECOND, 1, dor.DateCreated)
                ELSE DATEADD(MILLISECOND, -DATEPART(MILLISECOND, dor.DateCreated), dor.DateCreated)
            END DateCreated,
            fechaCreacion AS DateCreatedInSystem
       INTO #transData
       FROM DeliveryBackOffice.dbo.DeliveryOrder dor WITH(NOLOCK)
            OUTER APPLY (
                         SELECT TOP 1 dod.DateCreatedInSystem AS fechaCreacion
                           FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod
                          WHERE dod.Guide_Serie = dor.Guide_Serie
                            AND dod.Guide_Number = dor.Guide_Number
                            AND dod.StatusOrderId IN (4,5,22)
                          ORDER BY dod.DateCreated ASC
                        ) AS fechas
      WHERE NOT EXISTS
                      (
                       -- 7 Anulado
                       -- 11 Arribo a instalaciones
                       SELECT TOP 1 1
                         FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod
                        WHERE dod.Guide_Serie = dor.Guide_Serie
                          AND dod.Guide_Number = dor.Guide_Number
                          AND dod.StatusOrderId IN (7, 11)
                      )
        AND EXISTS
                  (
                   SELECT TOP 1 1
                     FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod
                    WHERE dod.Guide_Serie = dor.Guide_Serie
                      AND dod.Guide_Number = dor.Guide_Number
                      AND dod.StatusOrderId IN (4,5,22) 
                  )
        AND CAST(dor.DateCreated AS DATE) BETWEEN CAST(@InitDate AS DATE) AND CAST(@EndDate AS DATE)
      ORDER BY dor.DateCreated ASC

     INSERT INTO DeliveryOrderDetail
            (
             Guide_Serie,
             Guide_Number,
             StatusOrderId,
             UserCreated,
             DateCreated,
             DateCreatedInSystem,
             Observations,
             Temperature_Celsius,
             PieceId
            )
     SELECT Guide_Serie,
            Guide_Number,
            StatusOrderId,
            UserCreated,
            CASE
               WHEN CAST(DATEDIFF(DAY,dor.DateCreated,(dor.DateCreatedInSystem)) AS INT) = 1
                   THEN CONVERT(NVARCHAR,dor.DateCreated + @factor,20)
               ELSE CONVERT(NVARCHAR,(dor.DateCreated + DATEDIFF(DAY,dor.DateCreated,(dor.DateCreatedInSystem))) - 1,20)
            END DateCreated,
            CASE
               WHEN CAST(DATEDIFF(DAY,dor.DateCreated,(dor.DateCreatedInSystem)) AS INT) = 1
                   THEN CONVERT(NVARCHAR,dor.DateCreated + @factor,20)
               ELSE CONVERT(NVARCHAR,(dor.DateCreated + DATEDIFF(DAY,dor.DateCreated,(dor.DateCreatedInSystem))) - 1,20)
            END DateCreatedInSystem,
            '',
            NULL,
            NULL
       FROM #transData dor
      ORDER BY dor.Guide_Number ASC

  END TRY
  BEGIN CATCH
        SELECT ERROR_MESSAGE() AS 'DescriptionResult',
               CONCAT(' Start date: ',@InitDate, ' End Date: ',@EndDate,' User: ',@user) AS 'Params';
  END CATCH;
END