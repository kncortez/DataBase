-- =============================================
-- Author:      Juan Ramirez
-- Create date: 2025/11/06
-- Description: Tabla de información para llevar el correlativo 
-- =============================================
CREATE TABLE InvoiceSequenceByEstablishment (
    IdInvoiceSequenceByEstablishment INT IDENTITY(1,1),    
    [Establishment]                  VARCHAR(50) NOT NULL, 
    [TypeDocument]                   INT,                  
    [Sequence]                       VARCHAR(500) NULL,    
    RowStatus                        BIT NOT NULL DEFAULT 1,
    DateCreated                      DATETIME NOT NULL,
    TokenCreated                     NVARCHAR(50) NOT NULL,
    DateUpdated                      DATETIME NULL,
    TokenUpdated                     NVARCHAR(50) NULL,
    CONSTRAINT [PK_InvoiceSequenceByEstablishment] PRIMARY KEY
    CLUSTERED ([IdInvoiceSequenceByEstablishment] ASC),
    CONSTRAINT [FK_InvoiceSequenceByEstablishment_CatTypeDocument] 
    FOREIGN KEY ([TypeDocument]) REFERENCES dbo.CatTypeDocument (IdRegister)
);
GO 