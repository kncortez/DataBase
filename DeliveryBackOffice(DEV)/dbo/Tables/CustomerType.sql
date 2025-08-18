CREATE TABLE [dbo].[CustomerType] (
    [IdCustomerType]     INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Description]        NVARCHAR (100) NULL,
    [CustomerTypeStatus] BIT            CONSTRAINT [DF_CustomerType_StatusCustomerType] DEFAULT ('TRUE') NULL,
    [TokenCreated]       NVARCHAR (50)  NULL,
    [DateCreated]        DATETIME       NULL,
    [TokenUpdate]        NVARCHAR (50)  NULL,
    [DateUpdated]        DATETIME       NULL,
    CONSTRAINT [PK_CustomerType] PRIMARY KEY CLUSTERED ([IdCustomerType] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 ACTIVO ; 0 INACTIVO', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerType', @level2type = N'COLUMN', @level2name = N'CustomerTypeStatus';

