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
	LEFT JOIN [dbo].[CatTypeDocument] CTD WITH(NOLOCK)
		ON [IBH].[TypeDocument] = [CTD].[IdTypeDocument]
	WHERE [Id_Lote] = @IdLote

	--Devuelve toda la información de los puntos de ventas relacionado a este Lote
	SELECT 
		F.[Code],
		VPC.[DescriptionOfClient]          [Punto de venta],
		IBR.[CodeOfReference]              [CodeOfReference],
		ISNULL(F.[Facturas generadas],0)   [Facturas generadas],
		ISNULL(F.[Moneda], 'L')            [Moneda],
		ISNULL(F.[Monto facturado], 0.00)  [Monto facturado],
		ISNULL(IBR.RowStatus,0)            [RowStatus]
	FROM dbo.InvoiceBatchHeader IBH WITH (NOLOCK)
	LEFT JOIN dbo.InvoiceBatchRelationships IBR WITH(NOLOCK)
		ON IBR.Id_Lote = IBH.Id_Lote 
	INNER JOIN dbo.VisitPointClient VPC WITH(NOLOCK)
		ON  VPC.CodeOfReference = IBR.CodeOfReference
	OUTER APPLY(
		SELECT ISNULL(PF.dpf_SAPcardCode,'')        [Code]
			  ,ISNULL(COUNT(IBD.Id_Lote),0)			[Facturas generadas]
			  ,ISNULL(CCC.Symbol,'L')				[Moneda]
			  ,ISNULL(SUM(IH.inv_amount),0)			[Monto facturado]
		FROM dbo.InvoiceHeader IH WITH (NOLOCK)
		INNER JOIN dbo.InvoiceBatchDetail IBD WITH (NOLOCK)
			ON IBD.inv_pk_id = IH.inv_pk_id
		INNER JOIN dbo.CatCurrencyCOD CCC WITH(NOLOCK)
			ON IH.IdCurrency = CCC.IdCatCurrencyCOD
		LEFT JOIN dbo.del_ParametrosFactura PF WITH(NOLOCK)
			ON VPC.CodeOfReference = PF.dpf_VpCodeOfReference
		WHERE IdCountry = 'HN'
		  AND IBD.Id_Lote = IBH.Id_Lote
		  AND inv_vpCodeOfReferences =IBR.CodeOfReference
		GROUP BY PF.dpf_SAPcardCode,
				 IBD.Id_Lote,
				 CCC.Symbol
	) F
	WHERE IBH.Id_Lote = @IdLote --and IBR.RowStatus = 1
	ORDER BY VPC.[DescriptionOfClient]
		
    END TRY
    BEGIN CATCH
		-- Manejo de errores con PRINT
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE();
		PRINT 'Error: ' + @ErrorMessage;
	END CATCH;
END;