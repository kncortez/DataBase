/* =========================================
   SP:        [DeliveryBackOffice].[dbo].[GetBatchAdministrationAlert]
   Propósito: Obtener listado de alertas de lotes activos
   Autor:     Walter Orozco
   Historia:  FDAPI-2990
   Fecha:     2024-09-05
==== CHANGELOG ============================
2025-12-05 | Historia/épica: FDAPI-5244 | Autor: Cristian Azurdia |
2024-09-05 | Historia/épica: FDAPI-2990 | Autor: Walter Orozco |
=========================================== */

CREATE PROCEDURE [dbo].[GetBatchAdministrationAlert]
@RTN NVARCHAR(100) = NULL
AS
BEGIN
    BEGIN TRY

    Declare @Percent INT;
    Declare @days INT;

    SELECT 
        Id_Lote				AS 'IdLote',
        RTN,
        CAI,
        Emision_Point		AS 'Punto de emisión',
        Establishment		AS 'Establecimiento',
        TypeDocument		AS 'Tipo de documento',
        CASE
            -- SE superaron ambas condiciones
            WHEN  (GETDATE() > LimitDateEmision) AND (Last_Process > FinalRange)
            THEN 'AMBAS EXPIRO'
            --Condiciones por Lote expirado
            WHEN  GETDATE() > LimitDateEmision
            THEN 'DIAS EXPIRO'
            -- Condición por Porcentaje Superado
            WHEN (Last_Process > FinalRange)
            THEN 'PORCENTAJE EXPIRO'
            -- Cumple ambas condiciones
            WHEN DATEDIFF(day, GETDATE(), LimitDateEmision) <= DaysLeftNotifycation 
                 AND (FinalRange - InitialRange - (Last_Process - InitialRange)) <= (FinalRange - InitialRange) *  (PercentInvoiceLeftNotifycation * 0.01)
            THEN 'AMBAS'
            -- Condición por Días Restantes
            WHEN DATEDIFF(day, GETDATE(), LimitDateEmision) <= DaysLeftNotifycation 
            THEN 'DIAS'
            -- Condición por Porcentaje Restante
            WHEN (FinalRange - InitialRange - (Last_Process - InitialRange)) <= (FinalRange - InitialRange) *  (PercentInvoiceLeftNotifycation * 0.01) 
            THEN 'PORCENTAJE'
        END AS 'Alerta'
    FROM DeliveryBackOffice.dbo.InvoiceBatchHeader WITH(NOLOCK)
    WHERE
        (RTN = @RTN OR @RTN IS NULL)
    -- Evaluar ambas condiciones combinadas
    AND (
            DATEDIFF(day, GETDATE(), LimitDateEmision) <= DaysLeftNotifycation
            OR (FinalRange - InitialRange - (Last_Process - InitialRange)) <= (FinalRange - InitialRange) *  (PercentInvoiceLeftNotifycation * 0.01)
         )
        AND Status = 1 
        AND Enable = 1 
        AND RowStatus = 1
    ORDER BY LimitDateEmision ASC;

    END TRY
    BEGIN CATCH
		-- Manejo de errores con PRINT
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE();
		PRINT 'Error: ' + @ErrorMessage;
	END CATCH;
END;