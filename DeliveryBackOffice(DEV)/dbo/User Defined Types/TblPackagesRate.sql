CREATE TYPE [dbo].[TblPackagesRate] AS TABLE (
    [PackagesFrom]   INT             NULL,
    [PackagesTo]     INT             NULL,
    [Local]          DECIMAL (14, 2) NULL,
    [Metro]          DECIMAL (14, 2) NULL,
    [Foraneo]        DECIMAL (14, 2) NULL,
    [Especial]       DECIMAL (14, 2) NULL,
    [CatTypeService] INT             NULL,
    [State]          INT             NULL);

