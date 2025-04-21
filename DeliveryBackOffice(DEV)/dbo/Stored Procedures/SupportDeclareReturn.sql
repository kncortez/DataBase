CREATE PROCEDURE dbo.SupportDeclareReturn
    @guide_serie VARCHAR(2)
  , @GuideNumber INT
  , @Token VARCHAR(25)
AS
BEGIN TRY
    --VALIDAR QUE LA GUIA EXISTE
    IF NOT EXISTS
    (
        SELECT 1
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] WITH (NOLOCK)
        WHERE [Guide_Number] = @GuideNumber
    )
    BEGIN
        RAISERROR('No se encontro la guía', 16, 1);
        RETURN;
    END;
    -- si se encuentra realiza el insert en la deliveryorderdetail
    INSERT INTO DeliveryOrderDetail
    (
        Guide_Serie
      , Guide_Number
      , StatusOrderId
      , UserCreated
      , DateCreated
      , DateCreatedInSystem
      , Observations
      , Temperature_Celsius
      , PieceId
      , RowStatus
      , DeliveryAttemptId
      , SystemOrigin
      , StationId
    )
    VALUES
    (@guide_serie, @GuideNumber, 32, @Token, GETDATE(), GETDATE(), NULL, NULL, NULL, 1, NULL, NULL, NULL);

    --luego realizamos el update
    UPDATE DeliveryOrder
    SET StatusOrderId = 32
      , IsLastMileReturn = 1
    WHERE Guide_Number = @GuideNumber;


    --finaliza realiznado la consulta
    SELECT 'DeliveryOrderDetail'                                                                AS Tabla
         , Dod.[Guide_Serie]                                                                    AS Serie
         , Dod.[Guide_Number]                                                                   AS Numero_Guia
         , st.StatusOrderId                                                                     AS Codigo_estado
         , st.[OrderDescription]                                                                AS Estado
         , ISNULL(LOWER([DenariusUser_Dev].[dbo].[LGN_LogByToken].[SSN_Username]), ru.UsrEmail) AS Usuario
         , Dod.[DateCreated]                                                                    AS Fecha
         , ISNULL([Observations], '')                                                           AS Observaciones
         , CASE Dod.RowStatus
               WHEN 1 THEN
                   'Activo'
               WHEN 0 THEN
                   'Inactivo'
           END                                                                                  AS Estatus
    FROM DeliveryOrderDetail        Dod WITH (NOLOCK)
        INNER JOIN StatusOrder      st WITH (NOLOCK)
            ON st.[StatusOrderId] = Dod.[StatusOrderId]
        LEFT JOIN [DenariusUser_Dev].[dbo].[LGN_LogByToken] WITH (NOLOCK)
            ON Dod.[UserCreated] = [DenariusUser_Dev].[dbo].[LGN_LogByToken].[SSN_IdToken]
        LEFT JOIN TokenLog          tl WITH (NOLOCK)
            ON tl.TknIdToken = Dod.UserCreated
        LEFT JOIN RegisterUser      ru WITH (NOLOCK)
            ON ru.UsrIdUser = tl.TknIdUser
    WHERE [Guide_Number] = @GuideNumber
    ORDER BY Dod.[DateCreated] DESC;
    -- Ahora se verifica el estado en DeliveryOrder
    SELECT 'Estado actual en DeliveryOrder:' AS Informacion
         , Sto.OrderDescription              AS Estado
    FROM dbo.DeliveryOrder         Do WITH (NOLOCK)
        INNER JOIN dbo.StatusOrder Sto WITH (NOLOCK)
            ON Sto.StatusOrderId = Do.StatusOrderId
    WHERE [Guide_Number] = @GuideNumber;

END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS Respuesta;
END CATCH;