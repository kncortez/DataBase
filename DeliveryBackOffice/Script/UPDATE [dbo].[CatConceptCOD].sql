USE [DeliveryBackOffice]

BEGIN TRAN

--MODIFICACION DE LOS CONCEPTOS
UPDATE [dbo].[CatConceptCOD]
SET [Concept] = 'PAGO DE LA GUIA',
	[TokenUpdated] = 'AORTIZ',
	[DateUpdated] = GETDATE()
WHERE [IdCatConceptCOD] = 2
AND [RowStatus] = 1

UPDATE [dbo].[CatConceptCOD]
SET [Concept] = 'COMISION Y ENVIO',
	[TokenUpdated] = 'AORTIZ',
	[DateUpdated] = GETDATE()
WHERE [IdCatConceptCOD] = 1
AND [RowStatus] = 1

--COMMIT




