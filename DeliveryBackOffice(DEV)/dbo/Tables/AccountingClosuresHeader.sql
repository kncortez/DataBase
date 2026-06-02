CREATE TABLE [dbo].[AccountingClosuresHeader] (
    [IdAccountingClosuresHeader]           INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [UserId]                               BIGINT          NOT NULL,
    [ClosurerPOS]                          NVARCHAR (50)   NULL,
    [TotalAmountCash]                      DECIMAL (18, 5) NOT NULL,
    [TotalAmountCashDeclared]              DECIMAL (18, 5) NOT NULL,
    [TotalAmountCredit]                    DECIMAL (18, 5) NOT NULL,
    [TotalAmountCreditDeclared]            DECIMAL (18, 5) NOT NULL,
    [InvoiceAmountCash]                    INT             NOT NULL,
    [InvoiceAmountCredit]                  INT             NOT NULL,
    [VisitPoint]                           INT             NOT NULL,
    [Voucher1]                             NVARCHAR (50)   NULL,
    [Bag1]                                 NVARCHAR (50)   NULL,
    [Voucher2]                             NVARCHAR (50)   NULL,
    [Bag2]                                 NVARCHAR (50)   NULL,
    [RowStatus]                            BIT             NOT NULL,
    [TokenCreated]                         NVARCHAR (50)   NOT NULL,
    [DateCreated]                          DATETIME        NOT NULL,
    [ClosureDate]                          DATETIME        NULL,
    [TokenUpdated]                         NVARCHAR (50)   NULL,
    [DateUpdated]                          DATETIME        NULL,
    [TotalAmountCODCash]                   DECIMAL (18, 5) DEFAULT ((0)) NOT NULL,
    [TotalAmountCODCredit]                 DECIMAL (18, 5) DEFAULT ((0)) NOT NULL,
    [TotalAmountCODCashDeclared]           DECIMAL (18, 5) CONSTRAINT [ACH_TotalAmountCODCashDeclared] DEFAULT ((0)) NOT NULL,
    [TotalAmountCODCreditDeclared]         DECIMAL (18, 5) CONSTRAINT [ACH_TotalAmountCODCreditDeclared] DEFAULT ((0)) NOT NULL,
    [TotalAmountFacturaCash]               DECIMAL (18, 5) CONSTRAINT [ACH_TotalAmountFacturaCash] DEFAULT ((0)) NOT NULL,
    [InvoiceAmountFacturaCash]             INT             CONSTRAINT [ACH_InvoiceAmountFacturaCash] DEFAULT ((0)) NOT NULL,
    [TotalAmountFacturaCard]               DECIMAL (18, 5) CONSTRAINT [ACH_TotalAmountFacturaCard] DEFAULT ((0)) NOT NULL,
    [InvoiceAmountFacturaCard]             INT             CONSTRAINT [ACH_InvoiceAmountFacturaCard] DEFAULT ((0)) NOT NULL,
    [TotalAmountFacturaCashDeclared]       DECIMAL (18, 5) CONSTRAINT [ACH_TotalAmountFacturaCashDeclared] DEFAULT ((0)) NOT NULL,
    [TotalAmountFacturaCardDeclared]       DECIMAL (18, 5) CONSTRAINT [ACH_TotalAmountFacturaCardDeclared] DEFAULT ((0)) NOT NULL,
    [InvoiceAmountCOD]                     INT             CONSTRAINT [ACH_InvoiceAmountCOD] DEFAULT ((0)) NOT NULL,
    [AccountingClosuresHeaderVisitPointId] INT             CONSTRAINT [ACH_AccountClosuresHeaderVisitPointId] DEFAULT (NULL) NULL,
    CONSTRAINT [PK_AccountingClosuresHeader] PRIMARY KEY CLUSTERED ([IdAccountingClosuresHeader] ASC),
    CONSTRAINT [FK_AccountingClosuresHeader_AccountingClosuresHeaderVisitPoint] FOREIGN KEY ([AccountingClosuresHeaderVisitPointId]) REFERENCES [dbo].[AccountingClosuresHeaderVisitPoint] ([IdAccountingClosuresHeaderVisitPoint]),
    CONSTRAINT [FK_AccountingClosuresHeader_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser]),
    CONSTRAINT [FK_AccountingClosuresHeader_VisitPointClient] FOREIGN KEY ([VisitPoint]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Encabezado de cierres contables para Express Centers', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'IdAccountingClosuresHeader';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operador del express center', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'UserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cierre POS, documento generado cuando en el dispositivo de cobro con tarjeta se cierra la operación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'ClosurerPOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total efectivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'TotalAmountCash';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total efectivo declarado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'TotalAmountCashDeclared';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total tarjeta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'TotalAmountCredit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total tarjeta declarado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'TotalAmountCreditDeclared';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de facturas efectivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'InvoiceAmountCash';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de facturas tarjeta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'InvoiceAmountCredit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'EXC quien hizo cierre', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'VisitPoint';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Voucher para envíos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'Voucher1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bolsa para envíos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'Bag1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Voucher para COD y comisiones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'Voucher2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bolsa para COD y comisiones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'Bag2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de Express Center quien crea registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en la que se crear registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha lógica del cierre (día que se está cerrando)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'ClosureDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que actualiza información', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en la que se actualiza información', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total de COD en efectivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'TotalAmountCODCash';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total de COD con tarjeta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'TotalAmountCODCredit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total de COD en efectivo declarado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'TotalAmountCODCashDeclared';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total de COD con tarjeta declarado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'TotalAmountCODCreditDeclared';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total de facturas en efectivo para COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'TotalAmountFacturaCash';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de facturas efectivo para COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'InvoiceAmountFacturaCash';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total de facturas con tarjeta para COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'TotalAmountFacturaCard';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de facturas tarjeta para COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'InvoiceAmountFacturaCard';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total de facturas en efectivo para COD declarado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'TotalAmountFacturaCashDeclared';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total de facturas con tarjeta para COD declarado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'TotalAmountFacturaCardDeclared';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de cobros de COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'InvoiceAmountCOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID del cierre de VisitPoint en el que se registró este cierre', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresHeader', @level2type = N'COLUMN', @level2name = N'AccountingClosuresHeaderVisitPointId';


GO


