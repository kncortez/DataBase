CREATE TABLE [dbo].[BatchDetailCOD] (
    [IdBatchDetailCOD]        INT             IDENTITY (1, 1) NOT NULL,
    [BatchCODId]              INT             NOT NULL,
    [GuideSerie]              NVARCHAR (2)    NOT NULL,
    [GuideNumber]             INT             NOT NULL,
    [CatDebitAccountCODId]    INT             NULL,
    [CreditAccountId]         INT             NULL,
    [CreditDate]              DATE            CONSTRAINT [DF_BatchDetailCOD_CreditDate] DEFAULT (getdate()) NOT NULL,
    [Amount]                  DECIMAL (18, 2) CONSTRAINT [DF_BatchDetailCOD_Amount] DEFAULT ((0)) NOT NULL,
    [Commission]              DECIMAL (18, 2) CONSTRAINT [DF_BatchDetailCOD_Commission] DEFAULT ((0)) NOT NULL,
    [Reference]               INT             NULL,
    [CatTransactionTypeCODId] INT             NULL,
    [CatCurrencyCODId]        INT             CONSTRAINT [DF_BatchDetailCOD_CatCurrencyCODId] DEFAULT ((1)) NOT NULL,
    [BankId]                  INT             NULL,
    [CatAccountTypeCODId]     INT             NULL,
    [CatConceptCODId]         INT             NOT NULL,
    [Password]                INT             CONSTRAINT [DF_BatchDetailCOD_Password] DEFAULT ((0)) NULL,
    [AuthorizationNumber]     NVARCHAR (50)   NULL,
    [AuthorizationDate]       DATETIME        NULL,
    [Excluded]                BIT             CONSTRAINT [DF_BatchDetailCOD_Excluded] DEFAULT ('FALSE') NOT NULL,
    [Comments]                NVARCHAR (2000) NULL,
    [BankName]                NVARCHAR (50)   NULL,
    [TypeAccountName]         VARCHAR (40)    NULL,
    [AccountNumber]           NVARCHAR (50)   NULL,
    [AccountName]             NVARCHAR (2000) NULL,
    [CommissionNotified]      BIT             NULL,
    [CODCommissionPercentage] DECIMAL (12, 2) NULL,
    [CommissionId]            INT             NULL,
    [CommissionDate]          DATETIME        NULL,
    [DiscountPrice]           DECIMAL (18, 2) NULL,
    [CollectId]               BIGINT          NULL,
    [RecolectionId]           BIGINT          NULL,
    [RecolectionDate]         DATETIME        NULL,
    [CollectDate]             DATETIME        NULL,
    [CollectBatch]            BIT             NULL,
    [RecolectionBatch]        BIT             NULL,
    [CODBatch]                BIT             NULL,
    [RowStatus]               BIT             CONSTRAINT [DF_BatchDetailCOD_RowStatus] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_BatchDetailCOD_IdBatchDetailCOD] PRIMARY KEY CLUSTERED ([IdBatchDetailCOD] ASC),
    CONSTRAINT [FK_BatchDetailCOD_BatchCOD] FOREIGN KEY ([BatchCODId]) REFERENCES [dbo].[BatchCOD] ([IdBatchCOD]),
    CONSTRAINT [FK_BatchDetailCOD_CatAccountTypeCOD] FOREIGN KEY ([CatAccountTypeCODId]) REFERENCES [dbo].[CatAccountTypeCOD] ([IdCatAccountTypeCOD]),
    CONSTRAINT [FK_BatchDetailCOD_CatConceptCOD] FOREIGN KEY ([CatConceptCODId]) REFERENCES [dbo].[CatConceptCOD] ([IdCatConceptCOD]),
    CONSTRAINT [FK_BatchDetailCOD_CatCurrencyCOD] FOREIGN KEY ([CatCurrencyCODId]) REFERENCES [dbo].[CatCurrencyCOD] ([IdCatCurrencyCOD]),
    CONSTRAINT [FK_BatchDetailCOD_CatDebitAccountCOD] FOREIGN KEY ([CatDebitAccountCODId]) REFERENCES [dbo].[CatDebitAccountCOD] ([IdCatDebitAccountCOD]),
    CONSTRAINT [FK_BatchDetailCOD_CatTransactionTypeCOD] FOREIGN KEY ([CatTransactionTypeCODId]) REFERENCES [dbo].[CatTransactionTypeCOD] ([IdCatTransactionTypeCOD]),
    CONSTRAINT [FK_BatchDetailCOD_DeliveryBank] FOREIGN KEY ([BankId]) REFERENCES [dbo].[DeliveryBank] ([Id_bank]),
    CONSTRAINT [FK_BatchDetailCOD_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);










GO
CREATE NONCLUSTERED INDEX [idx_AuthorizationNumber]
    ON [dbo].[BatchDetailCOD]([AuthorizationNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_BatchCODId]
    ON [dbo].[BatchDetailCOD]([BatchCODId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_BatchCODId_CatConceptCODId_Excluded]
    ON [dbo].[BatchDetailCOD]([BatchCODId] ASC, [CatConceptCODId] ASC, [Excluded] ASC)
    INCLUDE([GuideSerie], [GuideNumber], [CatDebitAccountCODId], [CreditDate], [Amount], [Reference], [CatTransactionTypeCODId], [CatCurrencyCODId], [BankId], [CatAccountTypeCODId], [Password], [AccountNumber], [AccountName]);


GO
CREATE NONCLUSTERED INDEX [idx_CatConceptCODId]
    ON [dbo].[BatchDetailCOD]([CatConceptCODId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_CatConceptCODId_Excluded]
    ON [dbo].[BatchDetailCOD]([CatConceptCODId] ASC, [Excluded] ASC)
    INCLUDE([CatDebitAccountCODId], [CreditDate], [Amount], [Reference], [CatTransactionTypeCODId], [CatCurrencyCODId], [BankId], [CatAccountTypeCODId], [Password], [AccountNumber], [AccountName], [CommissionNotified]);


GO
CREATE NONCLUSTERED INDEX [idx_CatDebitAccountCODId]
    ON [dbo].[BatchDetailCOD]([CatDebitAccountCODId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_CatTransactionTypeCODId]
    ON [dbo].[BatchDetailCOD]([CatTransactionTypeCODId] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_CommissionDate]
    ON [dbo].[BatchDetailCOD]([CommissionDate] ASC)
    INCLUDE([CommissionId]);


GO
CREATE NONCLUSTERED INDEX [idx_GuideSerie_GuideSerie_GuideNumber_CreditAccountId_BankId]
    ON [dbo].[BatchDetailCOD]([GuideSerie] ASC, [GuideNumber] ASC, [CreditAccountId] ASC, [BankId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Se almacena el motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'Comments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del banco al que pertenece la cuenta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'BankName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de cuenta al que pertenece la misma.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'TypeAccountName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de cuenta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'AccountNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la cuenta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'AccountName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag para poder saber cuando el correo de comisiones fue enviado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'CommissionNotified';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar el Id de comisión al que pertenece.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'CommissionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar la fecha en la que se genera la comisión.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'CommissionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar el precio que se descuenta al cálcular comisiones COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'DiscountPrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder almacenar el porcentaje de comisión', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'CODCommissionPercentage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de secuencia para poder identificar los lotes que son de COLLECT y poder volver a generar el archivo de envíos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'CollectId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de secuencia para poder identificar los lotes que son de pagos en Recolección y poder volver a generar el archivo de envíos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'RecolectionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de generación de los lotes que son de pagos en Recolección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'RecolectionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de generación de los lotes que son de envíos COLLECT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'CollectDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica los lotes que son de COLLECT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'CollectBatch';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica los lotes que son de pagos en Recolección ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'RecolectionBatch';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica los lotes que son de pagos de COD ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'CODBatch';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para indicar el status del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCOD', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
CREATE NONCLUSTERED INDEX [idx_AuthorizationNumber_include]
    ON [dbo].[BatchDetailCOD]([AuthorizationNumber] ASC)
    INCLUDE([GuideSerie], [GuideNumber], [Amount], [Commission], [BankId], [AuthorizationDate], [BankName], [AccountNumber], [CODCommissionPercentage]);


GO
CREATE NONCLUSTERED INDEX [idx_bankid_authorizationnumber]
    ON [dbo].[BatchDetailCOD]([BankId] ASC, [AuthorizationNumber] ASC)
    INCLUDE([GuideSerie], [GuideNumber]);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20221216-222500]
    ON [dbo].[BatchDetailCOD]([GuideSerie] ASC, [GuideNumber] ASC, [CatConceptCODId] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_GuideNumber]
    ON [dbo].[BatchDetailCOD]([GuideNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_GUIDE_SERIE]
    ON [dbo].[BatchDetailCOD]([GuideSerie] ASC, [GuideNumber] ASC);

