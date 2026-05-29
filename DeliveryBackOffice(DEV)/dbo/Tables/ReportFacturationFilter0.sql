CREATE TABLE [dbo].[ReportFacturationFilter0] (
    [Ultimo_estado]            NVARCHAR (MAX)  NULL,
    [Origen_de_guia]           NVARCHAR (MAX)  NULL,
    [Cliente]                  NVARCHAR (MAX)  NULL,
    [Codigo_SAP]               NVARCHAR (MAX)  NULL,
    [Remitente]                NVARCHAR (MAX)  NULL,
    [Destinatario]             NVARCHAR (MAX)  NULL,
    [Departamento_Destino]     NVARCHAR (MAX)  NULL,
    [Municipio_Destino]        NVARCHAR (MAX)  NULL,
    [Fecha_solicitud_servicio] DATETIME        NULL,
    [Fecha_entrega]            DATETIME        NULL,
    [No_Manifiesto]            INT             NULL,
    [Guia]                     NVARCHAR (MAX)  NULL,
    [Entregado]                NVARCHAR (100)  NULL,
    [Tipo_tarifa_aplicada]     NVARCHAR (MAX)  NULL,
    [Descripcion_bien]         NVARCHAR (MAX)  NULL,
    [Piezas]                   INT             NULL,
    [Tarifa_servicio]          DECIMAL (18, 2) NULL,
    [Monto_envio]              DECIMAL (18, 2) NULL,
    [Monto_COD]                DECIMAL (18, 2) NULL,
    [Correo_remitente]         NVARCHAR (MAX)  NULL,
    [Nombre_cuenta]            NVARCHAR (MAX)  NULL,
    [Tipo_servicio]            NVARCHAR (MAX)  NULL,
    [Collect]                  NVARCHAR (MAX)  NULL,
    [NIT_Cliente]              NVARCHAR (MAX)  NULL,
    [Certificacion_FEL]        NVARCHAR (MAX)  NULL,
    [Exclusion_envio]          NVARCHAR (MAX)  NULL,
    [Codigo_socio_negocios]    NVARCHAR (MAX)  NULL,
    [Peso_total]               DECIMAL (18, 2) NULL,
    [Tarifa_excedente_libra]   DECIMAL (18, 2) NULL,
    [Peso_Base]                DECIMAL (18, 2) NULL,
    [Peso_a_Facturar]          DECIMAL (18, 2) NULL,
    [Credito_Collect]          NVARCHAR (MAX)  NULL,
    [SaleAdvisorCode]          NVARCHAR (MAX)  NULL,
    [BusinessSegmentName]      NVARCHAR (MAX)  NULL,
    [KindOfVPName]             NVARCHAR (MAX)  NULL,
    [CommercialSegmentName]    NVARCHAR (MAX)  NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_ReportFacturationFilter0_FechaSolicitud]
    ON [dbo].[ReportFacturationFilter0]([Fecha_solicitud_servicio] ASC);

