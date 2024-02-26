-- =============================================
-- Author:		<Luis Ardón>
-- Create date: <2023-11-22>
-- Modify:      <Carlos Vicente>
-- Modify on:   <2024-01-05>
-- Description:	Este procedimiento almacenado, GetCustomerGuideListByStatus, se utiliza para obtener una lista de guías para un cliente, estado y rango de fechas en especifico.
-- =============================================

CREATE PROCEDURE [dbo].[GetCustomerGuideListByStatus]
@IdCustomer INT,
@ListStatus AS VARCHAR(500),
@InitDate AS DATETIME,
@EndDate AS DATETIME 
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
END TRY 
BEGIN CATCH
--Devolviendo resultado de error en caso de generarse
SELECT
    500 AS 'responseCode',
    ERROR_MESSAGE() AS 'responseMessage';
END CATCH;
END;
GO