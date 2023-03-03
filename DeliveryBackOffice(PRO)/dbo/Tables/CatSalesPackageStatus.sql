CREATE TABLE [dbo].[CatSalesPackageStatus] (
    [IdCatSalesPackageStatus] INT           IDENTITY (1, 1) NOT NULL,
    [SalesPackageStatusName]  NVARCHAR (50) NOT NULL,
    [RowStatus]               BIT           CONSTRAINT [DF_CatSalesPackageStatus_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]            NVARCHAR (50) NOT NULL,
    [DateCreated]             DATETIME      NOT NULL,
    [TokenUpdated]            NVARCHAR (50) NULL,
    [DateUpdated]             DATETIME      NULL,
    CONSTRAINT [PK_CatSalesPackageStatus] PRIMARY KEY CLUSTERED ([IdCatSalesPackageStatus] ASC)
);

