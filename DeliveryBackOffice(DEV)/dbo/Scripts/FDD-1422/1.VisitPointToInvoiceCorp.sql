-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-11-25>
-- Description: <Configuraciones para CodeOfReference por defecto por pais para facturar corporativo>
-- =============================================
INSERT INTO dbo.ConfigParams
(
    [Name], [Description], [Value], [Status], [CreateDate], [IdCountry], [IdCurrencyCOD]
)
VALUES
(
   'InvoicesCodeOfReferenceCorp', 'CodeOfReference del punto de visita por defecto configurado para facturar en Hermes Desktop para clientes corporativos', '999', 1, GETDATE(), 'GT', NULL
),
(
   'InvoicesCodeOfReferenceCorp', 'CodeOfReference del punto de visita por defecto configurado para facturar en Hermes Desktop para clientes corporativos', '677888', 1, GETDATE(), 'HN', NULL
)