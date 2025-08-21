DECLARE @Mes INT = 12;
DECLARE @Year INT = 2024;
BEGIN TRY
    DECLARE @FechaInicio DATE,
            @FechaFin DATE;

    -- Definir rango de fechas dinámico según el mes recibido
    SET @FechaInicio = DATEFROMPARTS(@Year, @Mes, 1);
    SET @FechaFin = EOMONTH(@FechaInicio); -- último día del mes

    --  Validar y borrar la tabla temporal si ya existe
    IF OBJECT_ID('tempdb..#Duplicados') IS NOT NULL
        DROP TABLE #Duplicados;

    --  Crear tabla temporal con los duplicados
    SELECT GuideNumber,
           GuideSerie,
           COUNT(*) AS 'Ocurrencias en DeliveryOrderPaymentDetail'
    INTO #Duplicados
    FROM DeliveryOrderPaymentDetail WITH (NOLOCK)
    WHERE DateCreated >= @FechaInicio
          AND DateCreated <= @FechaFin
    GROUP BY GuideNumber,
             GuideSerie
    HAVING COUNT(*) > 1;

    --  Crear índice para mejorar performance en los JOIN
    CREATE NONCLUSTERED INDEX IX_Duplicados
    ON #Duplicados
    (
        GuideNumber,
        GuideSerie
    );

    ------------------------------------------------------------
    --  OBTENER CANTIDAD DE REGISTROS EN DELIVERYORDERPAYMENTDETAIL POR GUIA
    ------------------------------------------------------------
    SELECT *
    FROM #Duplicados

    ------------------------------------------------------------
    --   CONSULTA PARA OBTENER REGISTROS DE DeliveryOrder
    ------------------------------------------------------------
    SELECT DO.Guide_Serie,
           DO.Guide_Number,
           DO.StatusOrderId,
           SO.OrderDescription,
           DO.DateCreated,
           DO.PriceShippment,
           DO.Collect_OnDelivery,
           DO.*
    FROM DeliveryOrder DO WITH (NOLOCK)
        INNER JOIN StatusOrder SO
            ON SO.StatusOrderId = DO.StatusOrderId
        INNER JOIN #Duplicados TBL
            ON DO.Guide_Number = TBL.GuideNumber
               AND DO.Guide_Serie = TBL.GuideSerie
    ORDER BY DO.Guide_Number DESC,
             DO.DateCreated DESC;

    ------------------------------------------------------------
    --  CONSULTA obtener datos de DeliveryOrderDetail
    ------------------------------------------------------------
    SELECT DOD.Guide_Serie,
           DOD.Guide_Number,
           DOD.StatusOrderId,
           SO.OrderDescription AS EstadoTransitorio,
           DOD.*
    FROM DeliveryOrderDetail DOD WITH (NOLOCK)
        INNER JOIN StatusOrder SO
            ON SO.StatusOrderId = DOD.StatusOrderId
        INNER JOIN #Duplicados TBL
            ON DOD.Guide_Number = TBL.GuideNumber
               AND DOD.Guide_Serie = TBL.GuideSerie
    ORDER BY DOD.Guide_Number DESC,
             DOD.DateCreated ASC;

    ------------------------------------------------------------
    --  CONSULTA EN COST
    ------------------------------------------------------------
    SELECT 'Cost' AS '---',
           CS.*,
           'CostDetail' AS '---',
           CSD.*,
           'BreakdownPayment' AS '---',
           BDP.*,
           CBDPT.IdCatBreakdownOfPaymentType,
           CBDPT.BreakdownOfPaymentTypeName
    FROM Cost CS WITH (NOLOCK)
        INNER JOIN #Duplicados TBL
            ON CS.GuideNumber = TBL.GuideNumber
               AND CS.GuideSerie = TBL.GuideSerie
        LEFT JOIN CostDetail CSD
            ON CSD.IdCost = CS.IdCost
        LEFT JOIN BreakdownOfPayment BDP
            ON BDP.IdCost = CS.IdCost
        left join CatBreakdownOfPaymentType CBDPT
            ON BDP.BreakdownOfPaymentTypeId = CBDPT.IdCatBreakdownOfPaymentType
    ORDER BY CS.GuideNumber DESC;

    ------------------------------------------------------------
    --  CONSULTA EN DELIVERYORDERPAYMENTDETAIL
    ------------------------------------------------------------
    SELECT TP.tio_pk_id,
           TP.tio_pk_name,
           CPTY.PayTypeId,
           CPTY.PayTypeName,
           CPTI.TimePlaId,
           CPTI.TimePlaName,
           CPTI.TimePlaDescription,
           DDD.*
    FROM DeliveryOrderPaymentDetail DDD WITH (NOLOCK)
        INNER JOIN #Duplicados TBL
            ON DDD.GuideNumber = TBL.GuideNumber
               AND DDD.GuideSerie = TBL.GuideSerie
        INNER JOIN ctgTypeOfInOutOfMoney TP
            ON DDD.TypeofInOutMoneyId = TP.tio_pk_id
        INNER JOIN CatPaymentType CPTY
            ON DDD.PayTypeId = CPTY.PayTypeId
        INNER JOIN CatPaymentTime CPTI
            ON DDD.TimePlaId = CPTI.TimePlaId
    ORDER BY DDD.GuideNumber DESC,
             DDD.DateCreated ASC;

    --  Elimino la tabla temporal
    DROP TABLE #Duplicados;
END TRY
BEGIN CATCH
    -- Manejo de errores
    DECLARE @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;

    SELECT @ErrorMessage = ERROR_MESSAGE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH