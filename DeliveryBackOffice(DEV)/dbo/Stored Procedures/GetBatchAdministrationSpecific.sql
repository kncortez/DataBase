/* =================================================
   SP:        [dbo].[GetBatchAdministrationSpecific]
   Propósito: <Administración de lotes - Consulta de lote especifico>
   Autor:     <Walter Orozco>
   Historia:  <FDAPI-2997>
   Fecha:     2024-09-13
============================================
=== CHANGELOG ================================
-- 2025-01-16 | Historia/épica: FDAPI-2982 | Autor: Cristian Azurdia |
-- 2024-10-22 | Historia/épica: FDAPI-3105 | Autor: Walter Orozco |
-- 2024-09-13 | Historia/épica: FDAPI-2997 | Autor: Walter Orozco |
=========================================== */

CREATE PROCEDURE [dbo].[GetBatchAdministrationSpecific]
@IdLote INT
AS
BEGIN
    BEGIN TRY

    --Devuelva toda la información de un Lote especifico
    SELECT 
       [IBH].[Id_Lote]								AS [Id_Lote]
      ,ISNULL([IBH].[RTN],'')						AS [RTN]
      ,[IBH].[NoDeclaracion]						AS [NoDeclaracion]
      ,[IBH].[CAI]									AS [CAI]
      ,[IBH].[LimitDateEmision]						AS [LimitDateEmision]
      ,[IBH].[Establishment]						AS [Establishment]
      ,[IBH].[Emision_Point]						AS [Emision_Point]
      ,[IBH].[TypeDocument]							AS [TypeDocument]
      ,[CTD].[Name]									AS [NameTypeDocument]
      ,[IBH].[RecepcionDate]						AS [RecepcionDate]
      ,[IBH].[Administration_Code]					AS [Administration_Code]
      ,[IBH].[Status]								AS [Status]
      ,[IBH].[Enable]								AS [Enable]
      ,[IBH].[InitialRange]							AS [InitialRange]
      ,[IBH].[FinalRange]							AS [FinalRange]
      ,[IBH].[Last_Process]							AS [Last_Process]
      ,[IBH].[AmountGranted]						AS [AmountGranted]
      ,[IBH].[EmailNotification]					AS [EmailNotification]
      ,[IBH].[DaysLeftNotifycation]					AS [DaysLeftNotifycation]
      ,[IBH].[PercentInvoiceLeftNotifycation]		AS [PercentInvoiceLeftNotifycation]
      ,ISNULL([IBH].[AmountRequested],0)			AS [AmountRequested]
      ,[IBH].[RowStatus]							AS [RowStatus]
    FROM [dbo].[InvoiceBatchHeader] IBH WITH (NOLOCK)
    INNER JOIN [dbo].[CatTypeDocument] CTD WITH(NOLOCK)
       ON [IBH].[TypeDocument] = [CTD].[IdTypeDocument]
    WHERE [Id_Lote] = @IdLote

    --Devuelve toda la información de los puntos de ventas relacionado a este Lote
    SELECT IBR.CodeOfReference             [ID],
        PF.dpf_SAPcardCode                 [Code],
        VPC.[DescriptionOfClient]          [Punto de venta],
        IBR.[CodeOfReference]              [CodeOfReference],
        ISNULL(F.[Facturas generadas],0)   [Facturas generadas],
        ISNULL(F.[Moneda],'L')             [Moneda],
        ISNULL(F.[Monto facturado], 0.00)  [Monto facturado],
        IBR.RowStatus                      [RowStatus]
    FROM dbo.InvoiceBatchHeader IBH WITH (NOLOCK)
    LEFT JOIN dbo.InvoiceBatchRelationships IBR WITH(NOLOCK)
        ON IBR.Id_Lote = IBH.Id_Lote
    INNER JOIN dbo.VisitPointClient VPC         WITH(NOLOCK)
        ON VPC.CodeOfReference = IBR.CodeOfReference
    INNER JOIN dbo.del_ParametrosFactura PF     WITH(NOLOCK)
        ON PF.dpf_VpCodeOfReference = IBR.CodeOfReference
    OUTER APPLY(
        SELECT COUNT(IBD.Id_Lote)                 [Facturas generadas]
             , MAX(CCC.Symbol)                    [Moneda]
             , SUM(ISNULL(IH.inv_amount,0))       [Monto facturado]
        FROM dbo.InvoiceBatchDetail IBD WITH (NOLOCK)
        INNER JOIN dbo.InvoiceHeader IH WITH (NOLOCK)
            ON IBD.inv_pk_id = IH.inv_pk_id
        INNER JOIN dbo.CatCurrencyCOD CCC WITH(NOLOCK)
            ON CCC.IdCatCurrencyCOD = IH.IdCurrency
        WHERE inv_vpCodeOfReferences = IBR.CodeOfReference
          AND IH.inv_type = @TypeDocument
          AND IBD.Id_Lote = IBH.Id_Lote
    ) F
    WHERE IBH.Id_Lote = @IdLote
    ORDER BY VPC.[DescriptionOfClient]
		
    END TRY
    BEGIN CATCH
		-- Manejo de errores con PRINT
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE();
		PRINT 'Error: ' + @ErrorMessage;
	END CATCH;
END;