
-- =============================================
-- Author:		<Azurdia, Cristian>
-- Create date: <2024-08-01>
-- Description:	<Recupera información de lote especificado o lotes en general>
-- =============================================

CREATE	PROCEDURE [dbo].[GetBatchInvoice]
    @Id_Lote INT
AS
BEGIN
    -- SET NOCOUNT ON 

	IF(@Id_Lote > 0)
	BEGIN
		
		IF EXISTS( SELECT 1	FROM InvoiceBatchHeader	WHERE Id_Lote = @Id_Lote )
		BEGIN
			SELECT '200' [StatusCode], 'Lote identificado' [Message]

			SELECT	Id_Lote
					,RTN
					,NoDeclaracion
					,CAI
					,LimitDateEmision
					,Emision_Point
					,Establishment
					,TypeDocument
					,RecepcionDate
					,Administration_Code
					,InitialRange
					,FinalRange
					,AmountGranted
					,EmailNotification
					,DaysLeftNotifycation
					,PercentInvoiceLeftNotifycation
					,[Status]
					,[Enable] 
			FROM InvoiceBatchHeader
			WHERE Id_Lote = @Id_Lote
		END
		ELSE
		BEGIN
			SELECT '400' [StatusCode], 'Lote NO identificado' [Message]
		END
	END
	ELSE
	BEGIN
		SELECT 
				Id_Lote
				,RTN
				,NoDeclaracion
				,CAI
				,LimitDateEmision
				,Emision_Point
				,Establishment
				,TypeDocument
				,RecepcionDate
				,Administration_Code
				,InitialRange
				,FinalRange
				,AmountGranted
				,EmailNotification
				,DaysLeftNotifycation
				,PercentInvoiceLeftNotifycation
				,[Status]
				,[Enable]
		FROM InvoiceBatchHeader
	END

   
END	