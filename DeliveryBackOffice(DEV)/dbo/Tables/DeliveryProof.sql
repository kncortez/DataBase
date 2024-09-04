CREATE TABLE [dbo].[DeliveryProof] (
    [ID]             INT             IDENTITY (1, 1) NOT NULL,
    [Guide_Serie]    NVARCHAR (2)    NOT NULL,
    [Guide_Number]   INT             NOT NULL,
    [Date_Photo]     DATETIME        NOT NULL,
    [Proof_Dry]      VARBINARY (MAX) NULL,
    [Proof_Cold]     VARBINARY (MAX) NULL,
    [Proof_Incident] VARBINARY (MAX) NULL,
    [PathSignature]  NVARCHAR (300)  NULL,
    [Path_Dry]       NVARCHAR (300)  NULL,
    [Path_Cold]      NVARCHAR (300)  NULL,
    [Path_Incident]  NVARCHAR (300)  NULL,
    CONSTRAINT [PK_DeliveryProof] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DeliveryOrder_DeliveryProof] FOREIGN KEY ([Guide_Serie], [Guide_Number]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);






GO
CREATE NONCLUSTERED INDEX [IDX_DeliveryProof]
    ON [dbo].[DeliveryProof]([Guide_Serie] ASC, [Guide_Number] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar url de imágen dry la cual es evidencia de entrega en courierApp.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryProof', @level2type = N'COLUMN', @level2name = N'Path_Dry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar url de imágen cold la cual es evidencia de entrega en courierApp.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryProof', @level2type = N'COLUMN', @level2name = N'Path_Cold';


GO
CREATE NONCLUSTERED INDEX [IDX_Guide_Number]
    ON [dbo].[DeliveryProof]([Guide_Number] ASC);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryProof',
    @level2type = N'COLUMN',
    @level2name = N'ID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Serie de guía',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryProof',
    @level2type = N'COLUMN',
    @level2name = N'Guide_Serie'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Número de guía',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryProof',
    @level2type = N'COLUMN',
    @level2name = N'Guide_Number'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha en que se tomo foto',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryProof',
    @level2type = N'COLUMN',
    @level2name = N'Date_Photo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Campo para almacenar url de imagen la cual es evidencia de incidencia en courierApp',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryProof',
    @level2type = N'COLUMN',
    @level2name = N'Path_Incident'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Campo para almacenar url de imagen de firma en courierApp',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryProof',
    @level2type = N'COLUMN',
    @level2name = N'PathSignature'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Campo para almacenar archivo imagen dry, evidencia de entrega',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryProof',
    @level2type = N'COLUMN',
    @level2name = N'Proof_Dry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Campo para almacenar archivo imagen cold, evidencia de entrega',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryProof',
    @level2type = N'COLUMN',
    @level2name = N'Proof_Cold'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Campo para almacenar archivo imagen de incidencia',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryProof',
    @level2type = N'COLUMN',
    @level2name = N'Proof_Incident'