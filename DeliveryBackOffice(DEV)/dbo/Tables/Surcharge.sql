CREATE TABLE [dbo].[Surcharge] (
    [IdSurcharge]    INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SurchargeName]  NVARCHAR (50)   NULL,
    [PercentValue]   DECIMAL (18, 2) NULL,
    [SuchargeStatus] BIT             NULL,
    [TokenCreated]   NVARCHAR (50)   NULL,
    [DateCreated]    DATETIME        NULL,
    [TokenUpdated]   NVARCHAR (50)   NULL,
    [DateUpdated]    DATETIME        NULL,
    CONSTRAINT [PK_Surcharge] PRIMARY KEY CLUSTERED ([IdSurcharge] ASC)
);

