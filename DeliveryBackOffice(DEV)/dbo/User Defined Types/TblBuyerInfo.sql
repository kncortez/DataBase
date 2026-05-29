CREATE TYPE [dbo].[TblBuyerInfo] AS TABLE (
    [DistrictCode]           VARCHAR (100) NULL,
    [StateCode]              VARCHAR (100) NULL,
    [ActivityCode]           VARCHAR (100) NULL,
    [ActivityDescription]    VARCHAR (500) NULL,
    [NRC]                    VARCHAR (20)  NULL,
    [TypeDocument]           VARCHAR (100) NULL,
    [IdDocument]             VARCHAR (100) NULL,
    [Phone]                  VARCHAR (100) NULL,
    [OperationConditionCode] INT           NULL);

