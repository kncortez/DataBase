CREATE TYPE [dbo].[TblWeightRate] AS TABLE (
    [WeightFrom]     DECIMAL (12, 2) NULL,
    [WeightTo]       DECIMAL (12, 2) NULL,
    [Local]          DECIMAL (14, 2) NULL,
    [Metro]          DECIMAL (14, 2) NULL,
    [Foraneo]        DECIMAL (14, 2) NULL,
    [Especial]       DECIMAL (14, 2) NULL,
    [CatTypeService] INT             NULL,
    [State]          INT             NULL);



