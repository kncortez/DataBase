/* =============================================
    SP:          [dbo].[GetConciliacionTransferenciasYZigi]
    Propósito:   Obtener el reporte de conciliación de transferencias bancarias y ZiGi entre cobros POD y movimientos EC.
    Autor:       Marcelo del Aguila
    Historia:    FDAPI-5972
    Fecha:       2026-04-05

    === CHANGELOG ===================================
    2026-04-05 | Historia/épica: FDAPI-5972 | Autor: Marcelo del Aguila |
    ============================================== */

CREATE PROCEDURE dbo.GetConciliacionTransferenciasYZigi
(
    @FechaInicio DATE,
    @FechaFin DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FechaFinExclusiva DATE = DATEADD(DAY, 1, @FechaFin);

    WITH Entrega AS
    (
        SELECT
            od.Guide_Serie,
            od.Guide_Number,
            FechaEntrega = MIN(od.DateCreated)
        FROM dbo.DeliveryOrderDetail od WITH (NOLOCK)
        WHERE od.StatusOrderId = 5
        GROUP BY 
            od.Guide_Serie,
            od.Guide_Number 
    ),
    VoucherData AS
    (
        SELECT
            c.GuideNumber,
            cd.Voucher,
            cd.VoucherPath,
            cd.DateCreated,
            rn = ROW_NUMBER() OVER
            (
                PARTITION BY c.GuideNumber
                ORDER BY cd.DateCreated DESC
            )
        FROM dbo.Cost c WITH (NOLOCK)
        INNER JOIN dbo.CostDetail cd WITH (NOLOCK)
            ON cd.IdCost = c.IdCost
        WHERE cd.DateCreated >= @FechaInicio
          AND cd.DateCreated <  @FechaFinExclusiva
          AND cd.IdTypeOfMoney IN (10, 11)
    ),
    DatosPOD AS
    (
        SELECT
            'FD' + CAST(o.Guide_Number AS VARCHAR(20)) AS [Guía],

            'Q ' + CONVERT(
                VARCHAR(20), 
                CAST(ISNULL(o.PriceShippment, 0) + ISNULL(o.Collect_OnDelivery, 0) AS DECIMAL(18,2))
            ) AS [Monto cobrado en transferencia],

            o.Courier_Route AS [Ruta],

            o.Courier_Name AS [Piloto],

            h.HuBName AS [Hub],

            CASE
                WHEN ISNULL(o.PriceShippment, 0) <> 0
                 AND ISNULL(o.Collect_OnDelivery, 0) <> 0
                    THEN 'AMBOS'
                WHEN ISNULL(o.Collect_OnDelivery, 0) <> 0
                    THEN 'COD'
                WHEN ISNULL(o.PriceShippment, 0) <> 0
                    THEN 'ENVÍO'
                ELSE ''
            END AS [Producto cobrado en transferencia],

            CAST(vd.Voucher AS VARCHAR(100)) AS [ID Transferencia POD],

            CONVERT(VARCHAR(16), vd.DateCreated, 103) + ' ' 
            + LEFT(CONVERT(VARCHAR(8), vd.DateCreated, 108), 5) 
            AS [Fecha hora cobro en POD],

            vd.DateCreated AS [FechaOrdenamiento]

        FROM dbo.DeliveryOrder o WITH (NOLOCK)
        INNER JOIN Entrega e
            ON e.Guide_Serie = o.Guide_Serie
           AND e.Guide_Number = o.Guide_Number
        LEFT JOIN VoucherData vd
            ON vd.GuideNumber = o.Guide_Number
           AND vd.rn = 1
        LEFT JOIN dbo.HubLogistics h WITH (NOLOCK)
            ON h.IdHubLogistic = o.HubDestinationId
        OUTER APPLY
        (
            SELECT TOP (1)
                s.ID
            FROM dbo.DeliveryOrderBySettlement s WITH (NOLOCK)
            WHERE s.User_Dispatched = o.TokenUpdated
              AND s.Date_Dispatched >= @FechaInicio
              AND s.Date_Dispatched <  @FechaFinExclusiva
              AND CAST(s.Date_Dispatched AS DATE) = CAST(o.Dispatched_Date AS DATE)
            ORDER BY s.Date_Dispatched DESC, s.ID DESC
        ) sbs
        WHERE vd.VoucherPath IS NOT NULL
          AND sbs.ID IS NOT NULL
    ),
    DatosEC AS
    (
        SELECT
            CAST(TransactionReference AS VARCHAR(100)) AS [ID transferencia EC],

            TransactionDate AS [Fecha Hora recepción en EC],

            Account AS [No. Cuenta],

            CASE
                WHEN CHARINDEX('0002', TransactionDescription) > 0
                    THEN LTRIM(
                        SUBSTRING(
                            TransactionDescription,
                            CHARINDEX('0002', TransactionDescription) + 4,
                            LEN(TransactionDescription)
                        )
                    )
                ELSE TransactionDescription
            END AS [Descripción de transferencia EC],

            CAST(TransactionDate AS DATETIME) AS [FechaOrdenamiento]

        FROM dbo.StatementAccount_MT940 WITH (NOLOCK)
        WHERE TransactionDate >= @FechaInicio
          AND TransactionDate <  @FechaFinExclusiva
          AND TransactionType = 'C'
    ),
    DatosPODUnico AS
    (
        SELECT
            [Guía],
            [Monto cobrado en transferencia],
            [Ruta],
            [Piloto],
            [Hub],
            [Producto cobrado en transferencia],
            [ID Transferencia POD],
            [Fecha hora cobro en POD],
            [FechaOrdenamiento]
        FROM
        (
            SELECT
                POD.*,
                rnPOD = ROW_NUMBER() OVER
                (
                    PARTITION BY LTRIM(RTRIM(POD.[ID Transferencia POD]))
                    ORDER BY POD.[FechaOrdenamiento] DESC
                )
            FROM DatosPOD POD
        ) X
        WHERE X.[ID Transferencia POD] IS NULL
           OR X.rnPOD = 1
    ),
    DatosECUnico AS
    (
        SELECT
            [ID transferencia EC],
            [Fecha Hora recepción en EC],
            [No. Cuenta],
            [Descripción de transferencia EC],
            [FechaOrdenamiento]
        FROM
        (
            SELECT
                EC.*,
                rnEC = ROW_NUMBER() OVER
                (
                    PARTITION BY LTRIM(RTRIM(EC.[ID transferencia EC]))
                    ORDER BY EC.[FechaOrdenamiento] DESC
                )
            FROM DatosEC EC
        ) X
        WHERE X.[ID transferencia EC] IS NULL
           OR X.rnEC = 1
    )

    SELECT
        POD.[Guía],

        POD.[Monto cobrado en transferencia],

        POD.[Ruta],

        POD.[Piloto],

        POD.[Hub],

        POD.[Producto cobrado en transferencia],

        POD.[ID Transferencia POD],

        EC.[ID transferencia EC],

        POD.[Fecha hora cobro en POD],

        EC.[Fecha Hora recepción en EC],

        CASE
            WHEN POD.[ID Transferencia POD] IS NOT NULL
             AND EC.[ID transferencia EC] IS NOT NULL
                THEN 'Conciliado'
            ELSE 'No conciliado'
        END AS [Estado de Conciliación],

        EC.[No. Cuenta],

        EC.[Descripción de transferencia EC]

    FROM DatosPODUnico POD
    FULL OUTER JOIN DatosECUnico EC
        ON LTRIM(RTRIM(POD.[ID Transferencia POD])) = LTRIM(RTRIM(EC.[ID transferencia EC]))

    ORDER BY
        COALESCE(POD.[FechaOrdenamiento], EC.[FechaOrdenamiento]) DESC;

END;
GO