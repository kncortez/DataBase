-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-09-05>
-- Description:	<Administración de lotes - Consulta de lotes>
-- =============================================

CREATE PROCEDURE [dbo].[GetBatchAdministration]
@RTN NVARCHAR(100) = NULL,
@IsActive BIT = 0
AS
BEGIN
    BEGIN TRY

    DECLARE @SQL NVARCHAR(MAX) = '
    SELECT 
        IBH.Id_Lote AS [IdLote]
        ,IBH.RTN    AS [RTN]
        ,IBH.CAI    AS [CAI]
        ,IBH.LimitDateEmision  AS [Vigente hasta]
        ,IBH.Establishment     AS [Establecimiento]
        ,IBH.Emision_Point     AS [Punto de emisión]
        ,IBH.TypeDocument      AS [Tipo de documento]
        ,ISNULL(CTD.Name,'''') AS [Nombre de tipo de documento]
        ,IBH.Status            AS [Estado]
        ,IBH.Enable            AS [Detenido]
        ,IBH.AmountGranted     AS [Cantidad otorgada]
        ,CASE 
            WHEN IBH.Last_Process > IBH.InitialRange 
            THEN (IBH.FinalRange - IBH.InitialRange) - (IBH.Last_Process - IBH.InitialRange)
            ELSE (IBH.FinalRange - IBH.InitialRange)
        END AS [Disponible]
        ,IBH.EmailNotification    AS [EmailNotification]
        ,IBH.LimitDateEmision     AS [LimitDateEmision]
        ,IBH.DaysLeftNotifycation AS [DaysLeftNotifycation]
        ,IBH.PercentInvoiceLeftNotifycation AS [PercentInvoiceLeftNotifycation]
        ,IBH.InitialRange         AS [InitialRange]
        ,IBH.FinalRange           AS [FinalRange]
        ,IBH.Last_Process         AS [Last_Process]
    FROM DeliveryBackOffice.dbo.InvoiceBatchHeader IBH WITH(NOLOCK)
    LEFT JOIN DeliveryBackOffice.dbo.CatTypeDocument CTD WITH(NOLOCK)
        ON IBH.TypeDocument = CTD.IdTypeDocument
    WHERE 1=1'

    IF @RTN IS NOT NULL
    BEGIN
    SET @SQL = @SQL + ' AND IBH.RTN = @RTN'
    END

    IF @isActive = 1
    BEGIN
    SET @SQL = @SQL + ' AND IBH.Enable = @isActive'
    SET @SQL = @SQL + ' AND IBH.Status = @isActive'
    END

    EXEC sp_executesql @SQL, 
    N'@RTN VARCHAR(50), @isActive BIT', 
    @RTN, @isActive

    END TRY
    BEGIN CATCH

        -- Manejo de errores con PRINT
        DECLARE @ErrorMessage NVARCHAR(4000);
        SELECT @ErrorMessage = ERROR_MESSAGE();

        PRINT 'Error: ' + @ErrorMessage;
    END CATCH;
END;
