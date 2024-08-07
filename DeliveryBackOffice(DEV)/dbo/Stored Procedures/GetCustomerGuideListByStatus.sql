-- =============================================
-- Author:		<Luis Ardón>
-- Create date: <2023-11-22>
-- Modify:      <Carlos Vicente>
-- Modify on:   <2024-06-25>
-- Description:	Este procedimiento almacenado, GetCustomerGuideListByStatus, se utiliza para obtener una lista de guías para un cliente, estado y rango de fechas en especifico.
-- =============================================

CREATE PROCEDURE [dbo].[GetCustomerGuideListByStatus]
@IdCustomer INT,
@ListStatus AS VARCHAR(500),
@InitDate AS DATETIME,
@EndDate AS DATETIME,
@Method AS VARCHAR(5) = NULL

AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY

--Verificación si el cliente cuenta con guias 
IF NOT EXISTS (
    SELECT
        TOP 1 1
    FROM
        [DeliveryBackOffice].[dbo].[Customer]
    WHERE
        Idcustomer = @IdCustomer
) 
BEGIN
    SELECT 
        204 AS 'responseCode','Cliente no encontrado' AS 'responseMessage';
    RETURN;
END;

--Verificación si el cliente cuenta con guías en el o los estados requeridos
IF @ListStatus <> '0' AND NOT EXISTS(
        SELECT
            TOP 1 1
        FROM
            [DeliveryBackOffice].[dbo].[DeliveryOrder] AS do WITH(NOLOCK)
        OUTER APPLY
            [DeliveryBackOffice].[dbo].[DelimitedSplit8K](@ListStatus,',') AS ds
        WHERE
            do.Idcustomer = @IdCustomer
            AND do.StatusOrderId = ds.Item
)
BEGIN
SELECT
    204 AS 'responseCode',
    'No hay guías para el cliente específico con el o los estados requeridos' AS 'responseMessage'
RETURN;
END;

--Verificación si el cliente cuenta con guías en el rango de fecha requerido
IF NOT EXISTS (
    SELECT
        TOP 1 1
    FROM
        [DeliveryBackOffice].[dbo].[DeliveryOrder] WITH(NOLOCK)
    WHERE
        IdCustomer = @IdCustomer
        AND DateCreated BETWEEN @InitDate AND @EndDate
) 
BEGIN
    SELECT
        204 AS 'responseCode',
        'No hay guías en el periodo indicado para el cliente en específico' AS 'responseMessage';
    RETURN;
END;

--Devolviendo resultado acorde a la petición del estado de la guía
DECLARE @BlackListId AS VARCHAR(100) = '7,15';

SELECT
    200 AS 'responseCode',
    'Transacción exitosa' AS 'responseMessage';
    IF (@Method IS NULL)
        IF (@ListStatus = '0')
            SELECT 
                CAST(serv.Sender_ID AS VARCHAR) + ' - ' + ISNULL(UPPER(serv.Sender_FirstName), '') + ' ' + ISNULL(UPPER(serv.Sender_LastName), '') [Sender],
                ISNULL(UPPER(serv.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(serv.Receiver_LastName), '') [Receiver],
                ISNULL(serv.Receiver_Department, '') [ReceiverDepartment],
                CONVERT(VARCHAR, serv.DateCreated, 103) [RequestedDate],
                serv.Guide_Serie + CAST(serv.Guide_Number AS VARCHAR) [Guide],
                so.OrderDescription AS [Status]
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] AS serv WITH (NOLOCK)
            LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder] AS so WITH (NOLOCK) ON serv.StatusOrderId = so.StatusOrderId
            WHERE 
                serv.DateCreated BETWEEN @InitDate AND @EndDate
                AND serv.IdCustomer = @IdCustomer
                AND NOT EXISTS 
                (
                    SELECT TOP 1 1 FROM [dbo].[DelimitedSplit8K](@BlackListId, ',')AS dsb
                    WHERE serv.StatusOrderId = dsb.Item
                )
        ELSE
            SELECT 
                CAST(serv.Sender_ID AS VARCHAR) + ' - ' + ISNULL(UPPER(serv.Sender_FirstName), '') + ' ' + ISNULL(UPPER(serv.Sender_LastName), '') [Sender],
                ISNULL(UPPER(serv.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(serv.Receiver_LastName), '') [Receiver],
                ISNULL(serv.Receiver_Department, '') [ReceiverDepartment],
                CONVERT(VARCHAR, serv.DateCreated, 103) [RequestedDate],
                serv.Guide_Serie + CAST(serv.Guide_Number AS VARCHAR) [Guide],
                so.OrderDescription AS [Status]
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] AS serv WITH (NOLOCK)
            LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder] AS so WITH (NOLOCK) ON serv.StatusOrderId = so.StatusOrderId
            WHERE 
                serv.DateCreated BETWEEN @InitDate AND @EndDate            
                AND serv.IdCustomer = @IdCustomer
                AND EXISTS 
                (
                    SELECT TOP 1 1 FROM [dbo].[DelimitedSplit8K](@ListStatus, ',')AS dsl
                    WHERE serv.StatusOrderId = dsl.Item
                )
                AND NOT EXISTS 
                (
                    SELECT TOP 1 1 FROM [dbo].[DelimitedSplit8K](@BlackListId, ',')AS dsb
                    WHERE serv.StatusOrderId = dsb.Item
                )
    ELSE IF (@Method = 'LST01')
    --LST01: Reporte diseñado para el cliente ADOC a petición del equipo de ATC
        SELECT A1.Guide_Serie + CAST(A1.Guide_Number AS VARCHAR) [Numero de guia],
            CONVERT(VARCHAR, A1.DateCreated, 103) [Creacion guia],
            O1.DateCreated [Recoleccion],
            O2.DateCreated [Entrega de pedido],
            A2.OrderDescription AS [Estado],
            O3.ActionObservation [Motivo de rechazo],
            ISNULL(UPPER(A1.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(A1.Receiver_LastName), '') [Destinatario],
            ISNULL(A1.Receiver_Department, '') [Departamento],
            A1.TypeService [Servicio],
            A1.Collect_OnDelivery [CCE Monto],
            CASE
                WHEN ISNULL(O4.DateCreated, '') = '' THEN ''
                ELSE 'Pagado'
            END AS [Estatus del CCE],
            O4.DateCreated [Fecha de reintegro],
            CAST(A1.Sender_ID AS VARCHAR) + ' - ' + ISNULL(UPPER(A1.Sender_FirstName), '') + ' '
            + ISNULL(UPPER(A1.Sender_LastName), '') [Sede/tienda origen]
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] AS A1 WITH (NOLOCK)
            LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder] AS A2 WITH (NOLOCK)
                ON A1.StatusOrderId = A2.StatusOrderId

            --Fecha de recolección
            OUTER APPLY
        (
            SELECT TOP 1
                DateCreated
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] WITH (NOLOCK)
            WHERE Guide_Serie = A1.Guide_Serie
                AND Guide_Number = A1.Guide_Number
                AND StatusOrderId = 2
        ) AS O1

            --Fecha de entrega de pedido (último estado final identificado)
            OUTER APPLY
        (
            SELECT TOP 1
                AO1.DateCreated
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] AS AO1 WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder] AS AO2 WITH (NOLOCK)
                    ON AO1.StatusOrderId = AO2.StatusOrderId
            WHERE Guide_Serie = A1.Guide_Serie
                AND Guide_Number = A1.Guide_Number
                AND AO2.CatCheckpointTypeId = 3
        ) AS O2

            --Motivo de rechazo
            OUTER APPLY
        (
            SELECT TOP 1
                AO2.ActionObservation
            FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] AS AO1 WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] AS AO2 WITH (NOLOCK)
                    ON AO1.ConfirmationOfIncidenceId = AO2.IdConfirmationOfIncidence
            WHERE AO1.Guide_Serie = A1.Guide_Serie
                AND AO1.Guide_Number = A1.Guide_Number
                AND AO1.ConfirmationOfIncidenceId IS NOT NULL
            ORDER BY Date_Created DESC
        ) AS O3

            --Fecha de reintegro y estado de pago
            OUTER APPLY
        (
            SELECT TOP 1
                DateCreated
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] WITH (NOLOCK)
            WHERE Guide_Serie = A1.Guide_Serie
                AND Guide_Number = A1.Guide_Number
                AND StatusOrderId = 25
        ) AS O4

        WHERE A1.DateCreated
            BETWEEN @InitDate AND @EndDate
            AND A1.IdCustomer = @Idcustomer

END TRY 
BEGIN CATCH
--Devolviendo resultado de error en caso de generarse
SELECT
    500 AS 'responseCode',
    ERROR_MESSAGE() AS 'responseMessage';
END CATCH;
END;