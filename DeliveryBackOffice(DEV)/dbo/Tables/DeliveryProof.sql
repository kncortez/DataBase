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

