CREATE TABLE [dbo].[CierreEnero2022] (
    [FechaFact]       DATETIME        NULL,
    [Origen]          NVARCHAR (100)  NULL,
    [Cliente]         NVARCHAR (100)  NULL,
    [Remitente]       NVARCHAR (100)  NULL,
    [Destinatario]    NVARCHAR (100)  NULL,
    [Municipio]       NVARCHAR (100)  NULL,
    [Departamento]    NVARCHAR (100)  NULL,
    [FechaSolicitud]  NVARCHAR (100)  NULL,
    [FechaEntrega]    NVARCHAR (100)  NULL,
    [Manifiesto]      NVARCHAR (100)  NULL,
    [Guia]            NVARCHAR (100)  NULL,
    [Estado]          NVARCHAR (100)  NULL,
    [Clasificacion]   NVARCHAR (100)  NULL,
    [Descripcion]     NVARCHAR (2000) NULL,
    [Pieza]           INT             NULL,
    [Tarifa]          DECIMAL (18, 2) NULL,
    [MontoDevolucion] DECIMAL (18, 2) NULL,
    [TotalAFacturar]  DECIMAL (18, 2) NULL
);

