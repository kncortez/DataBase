CREATE TABLE [dbo].[del_ParametrosFactura] (
    [dpf_VpCodeOfReference]          INT            NOT NULL,
    [dpf_FELRequestor]               VARCHAR (200)  NOT NULL,
    [dpf_FELTransaction]             VARCHAR (200)  NOT NULL,
    [dpf_FELCountry]                 VARCHAR (10)   NOT NULL,
    [dpf_FELEntity]                  VARCHAR (20)   NOT NULL,
    [dpf_FELUser]                    VARCHAR (200)  NOT NULL,
    [dpf_FELUserName]                VARCHAR (50)   NOT NULL,
    [dpf_FELData1]                   VARCHAR (50)   NOT NULL,
    [dpf_FELData3]                   VARCHAR (10)   NOT NULL,
    [dpf_FELCorreo]                  VARCHAR (50)   NOT NULL,
    [dpf_FELAsuntoCorreoFactura]     VARCHAR (200)  NOT NULL,
    [dpf_FELAsuntoCorreoNotaCredito] VARCHAR (200)  NOT NULL,
    [dpf_FELEstablecimiento]         VARCHAR (15)   NOT NULL,
    [dpf_FELCorreoCCO]               VARCHAR (50)   NOT NULL,
    [dpf_SAPServidorLicencias]       VARCHAR (50)   NOT NULL,
    [dpf_SAPCompania]                VARCHAR (50)   NOT NULL,
    [dpf_SAPUsuario]                 VARCHAR (50)   NOT NULL,
    [dpf_SAPContrasenia]             NVARCHAR (100) NOT NULL,
    [dpf_SAPServidor]                VARCHAR (50)   NOT NULL,
    [dpf_SAPUsuarioBD]               VARCHAR (50)   NOT NULL,
    [dpf_SAPContraseniaBD]           NVARCHAR (100) NOT NULL,
    [dpf_SAPserieFactura]            VARCHAR (50)   NOT NULL,
    [dpf_SAPserieNC]                 VARCHAR (50)   NOT NULL,
    [dpf_SAPseriePago]               VARCHAR (50)   NOT NULL,
    [dpf_SAPcardCode]                VARCHAR (50)   NOT NULL,
    [dpf_SAParticulo]                VARCHAR (50)   NOT NULL,
    [dpf_SAPvendor]                  VARCHAR (50)   NOT NULL,
    [dpf_SAPcreditCard]              VARCHAR (50)   NOT NULL,
    [dpf_OcrCode]                    NVARCHAR (50)  NULL,
    [dpf_OcrCode2]                   NVARCHAR (50)  NULL,
    [dpf_StatusFACE]                 NVARCHAR (1)   NULL,
    [dpf_WarehouseCode]              INT            NULL,
    CONSTRAINT [PK_del_ParametrosFactura] PRIMARY KEY CLUSTERED ([dpf_VpCodeOfReference] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar código de almacen de Express Center.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'del_ParametrosFactura', @level2type = N'COLUMN', @level2name = N'dpf_WarehouseCode';

