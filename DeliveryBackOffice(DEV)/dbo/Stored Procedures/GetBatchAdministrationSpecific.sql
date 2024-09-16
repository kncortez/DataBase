-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-09-13>
-- Description:	<Administración de lotes - Consulta de lote especifico>
-- =============================================

CREATE PROCEDURE [dbo].[GetBatchAdministrationSpecific]
@IdLote INT
AS
BEGIN
    BEGIN TRY

	--Devuelva toda la información de un Lote especifico
	SELECT 
	   [Id_Lote]							AS [Id_Lote]
      ,ISNULL([RTN],'')						AS [RTN]
      ,[NoDeclaracion]						AS [NoDeclaracion]
      ,[CAI]								AS [CAI]
      ,[LimitDateEmision]					AS [LimitDateEmision]
      ,[Establishment]						AS [Establishment]
      ,[Emision_Point]						AS [Emision_Point]
      ,[TypeDocument]						AS [TypeDocument]
      ,[RecepcionDate]						AS [RecepcionDate]
      ,[Administration_Code]				AS [Administration_Code]
      ,[Status]								AS [Status]
      ,[Enable]								AS [Enable]
      ,[InitialRange]						AS [InitialRange]
      ,[FinalRange]							AS [FinalRange]
      ,[Last_Process]						AS [Last_Process]
      ,[AmountGranted]						AS [AmountGranted]
      ,[EmailNotification]					AS [EmailNotification]
      ,[DaysLeftNotifycation]				AS [DaysLeftNotifycation]
      ,[PercentInvoiceLeftNotifycation]		AS [PercentInvoiceLeftNotifycation]
      ,ISNULL([AmountRequested],0)			AS [AmountRequested]
      ,[RowStatus]							AS [RowStatus]
	FROM [dbo].[InvoiceBatchHeader] WITH (NOLOCK)
	WHERE [Id_Lote] = @IdLote

	--Devuelve toda la información de los puntos de ventas relacionado a este Lote
	SELECT
		ISNULL(PF.dpf_SAPcardCode,'')			AS 'Code',
		ISNULL(VPC.DescriptionOfClient,'')		AS 'Punto de venta',
		ISNULL(VPC.CodeOfReference,0)			AS 'CodeOfReference',
		ISNULL(COUNT(IBD.Id_Lote),0)			AS 'Facturas generadas',
		ISNULL(CCC.Symbol,'Q')					AS 'Moneda',
		ISNULL(SUM(IH.inv_amount),0)			AS 'Monto facturado'
	FROM dbo.InvoiceBatchHeader IBH WITH (NOLOCK)
	INNER JOIN dbo.InvoiceBatchDetail IBD WITH (NOLOCK)
		ON IBH.Id_Lote = IBD.Id_Lote
	INNER JOIN dbo.InvoiceHeader IH WITH (NOLOCK)
		ON IBD.inv_pk_id = IH.inv_pk_id
	INNER JOIN dbo.VisitPointClient VPC WITH(NOLOCK)
		ON IH.inv_vpCodeOfReferences = VPC.CodeOfReference
	INNER JOIN dbo.CatCurrencyCOD CCC WITH(NOLOCK)
		ON IH.IdCurrency = CCC.IdCatCurrencyCOD
	LEFT JOIN dbo.del_ParametrosFactura PF WITH(NOLOCK)
		ON VPC.CodeOfReference = PF.dpf_VpCodeOfReference
	WHERE IBH.Id_Lote = @IdLote
	GROUP BY IBD.Id_Lote , VPC.DescriptionOfClient, VPC.CodeOfReference, CCC.Symbol, PF.dpf_SAPcardCode
	ORDER BY VPC.DescriptionOfClient
		
    END TRY
    BEGIN CATCH
		-- Manejo de errores con PRINT
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE();
		PRINT 'Error: ' + @ErrorMessage;
	END CATCH;
END;
