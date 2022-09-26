CREATE TYPE [dbo].[TblServiceRoutesParcel] AS TABLE (
    [IdTblServiceRoutesParcel] INT             NOT NULL,
    [TblServiceRoutesId]       INT             NOT NULL,
    [length]                   DECIMAL (12, 2) NULL,
    [width]                    DECIMAL (12, 2) NULL,
    [height]                   DECIMAL (12, 2) NULL,
    [weight]                   DECIMAL (12, 2) NULL,
    [amount]                   DECIMAL (12, 2) NULL,
    [currency]                 VARCHAR (20)    NULL,
    [fragil]                   BIT             NULL,
    [description]              VARCHAR (2500)  NULL,
    PRIMARY KEY CLUSTERED ([IdTblServiceRoutesParcel] ASC));

