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
CREATE NONCLUSTERED INDEX [idx_date_proof]
    ON [dbo].[DeliveryProof]([Date_Photo] ASC);

