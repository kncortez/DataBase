USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Marcelo del Aguila
-- Create date: 2026-04-05
-- Description: Obtiene el reporte de conciliación de transferencias bancarias y ZiGi entre cobros POD y movimientos EC.
-- =============================================

CREATE PROCEDURE dbo.SP_ConciliacionTransferenciasYZigi
(
    @FechaInicio DATE,
    @FechaFin DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    /*
        @FechaInicio = fecha inicial incluida
        @FechaFin    = fecha final incluida

        Ejemplo:
        EXEC dbo.SP_ConciliacionTransferenciasYZigi
            @FechaInicio = '2026-04-26',
            @FechaFin = '2026-04-28';
    */

    DECLARE @FechaFinExclusiva DATE = DATEADD(DAY, 1, @FechaFin);

    WITH Entrega AS
    (
        SELECT
            od.Guide_Number,
            FechaEntrega = MIN(od.DateCreated)
        FROM dbo.DeliveryOrderDetail od WITH (NOLOCK)
        WHERE od.StatusOrderId = 5
        GROUP BY od.Guide_Number
    ),
    Settlement AS
    (
        SELECT
            s.ID,
            s.User_Dispatched,
            s.Date_Dispatched
        FROM dbo.DeliveryOrderBySettlement s WITH (NOLOCK)
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
            'POD' AS [Origen],

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

            vd.Voucher AS [ID Transferencia POD],

            CONVERT(VARCHAR(16), vd.DateCreated, 103) + ' ' 
            + LEFT(CONVERT(VARCHAR(8), vd.DateCreated, 108), 5) 
            AS [Fecha hora cobro en POD],

            CAST(NULL AS VARCHAR(100)) AS [ID transferencia en EC],
            CAST(NULL AS DATE) AS [Fecha hora recepcion en EC],
            CAST(NULL AS VARCHAR(100)) AS [No. Cuenta],
            CAST(NULL AS VARCHAR(MAX)) AS [Descripcion de transferencia EC],

            vd.DateCreated AS [FechaOrdenamiento]

        FROM dbo.DeliveryOrder o WITH (NOLOCK)
        INNER JOIN Entrega e
            ON e.Guide_Number = o.Guide_Number
        LEFT JOIN VoucherData vd
            ON vd.GuideNumber = o.Guide_Number
           AND vd.rn = 1
        LEFT JOIN dbo.HubLogistics h WITH (NOLOCK)
            ON h.IdHubLogistic = o.HubDestinationId
        OUTER APPLY
        (
            SELECT TOP (1)
                s.ID
            FROM Settlement s
            WHERE s.User_Dispatched = o.TokenUpdated
              AND CAST(s.Date_Dispatched AS DATE) = CAST(o.Dispatched_Date AS DATE)
            ORDER BY s.Date_Dispatched DESC, s.ID DESC
        ) sbs
        WHERE vd.VoucherPath IS NOT NULL
          AND sbs.ID IS NOT NULL
    ),
    DatosEC AS
    (
        SELECT
            'EC' AS [Origen],

            CAST(NULL AS VARCHAR(30)) AS [Guía],
            CAST(NULL AS VARCHAR(50)) AS [Monto cobrado en transferencia],
            CAST(NULL AS VARCHAR(100)) AS [Ruta],
            CAST(NULL AS VARCHAR(200)) AS [Piloto],
            CAST(NULL AS VARCHAR(200)) AS [Hub],
            CAST(NULL AS VARCHAR(50)) AS [Producto cobrado en transferencia],
            CAST(NULL AS VARCHAR(100)) AS [ID Transferencia POD],
            CAST(NULL AS VARCHAR(30)) AS [Fecha hora cobro en POD],

            CAST(TransactionReference AS VARCHAR(100)) AS [ID transferencia en EC],
            TransactionDate AS [Fecha hora recepcion en EC],
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
            END AS [Descripcion de transferencia EC],

            CAST(TransactionDate AS DATETIME) AS [FechaOrdenamiento]

        FROM dbo.StatementAccount_MT940 WITH (NOLOCK)
        WHERE TransactionDate >= @FechaInicio
          AND TransactionDate <  @FechaFinExclusiva
          AND TransactionType = 'C'
    )

    SELECT
        [Origen],
        [Guía],
        [Monto cobrado en transferencia],
        [Ruta],
        [Piloto],
        [Hub],
        [Producto cobrado en transferencia],
        [ID Transferencia POD],
        [Fecha hora cobro en POD],
        [ID transferencia en EC],
        [Fecha hora recepcion en EC],
        [No. Cuenta],
        [Descripcion de transferencia EC]
    FROM
    (
        SELECT
            [Origen],
            [Guía],
            [Monto cobrado en transferencia],
            [Ruta],
            [Piloto],
            [Hub],
            [Producto cobrado en transferencia],
            [ID Transferencia POD],
            [Fecha hora cobro en POD],
            [ID transferencia en EC],
            [Fecha hora recepcion en EC],
            [No. Cuenta],
            [Descripcion de transferencia EC],
            [FechaOrdenamiento]
        FROM DatosPOD

        UNION ALL

        SELECT
            [Origen],
            [Guía],
            [Monto cobrado en transferencia],
            [Ruta],
            [Piloto],
            [Hub],
            [Producto cobrado en transferencia],
            [ID Transferencia POD],
            [Fecha hora cobro en POD],
            [ID transferencia en EC],
            [Fecha hora recepcion en EC],
            [No. Cuenta],
            [Descripcion de transferencia EC],
            [FechaOrdenamiento]
        FROM DatosEC
    ) Resultado
    ORDER BY 
        [Origen],
        [FechaOrdenamiento] DESC;

END;
GO