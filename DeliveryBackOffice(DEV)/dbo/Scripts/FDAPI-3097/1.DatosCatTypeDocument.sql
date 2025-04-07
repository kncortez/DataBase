-- Insert para Factura
INSERT INTO [dbo].[CatTypeDocument] (
    [IdTypeDocument], [Name], [Descripcion], [RowStatus], [TokenCreated], [DateCreated]
)
VALUES ( 1,'Factura','Documento que representa la venta de productos o servicios', 1, 'SYS-DRAMIREZ', GETDATE());

-- Insert para Nota de crédito
INSERT INTO [dbo].[CatTypeDocument] (
    [IdTypeDocument], [Name], [Descripcion], [RowStatus], [TokenCreated], [DateCreated]
)
VALUES ( 6,'Nota de crédito','Documento para corregir o anular una factura previa', 1, 'SYS-DRAMIREZ', GETDATE());

-- Insert para Guía de Remisión
INSERT INTO [dbo].[CatTypeDocument] (
    [IdTypeDocument], [Name], [Descripcion], [RowStatus], [TokenCreated], [DateCreated]
)
VALUES ( 8,'Guía de Remisión','Documento que acompaña mercancías en tránsito para fines de control', 1, 'SYS-DRAMIREZ', GETDATE());
