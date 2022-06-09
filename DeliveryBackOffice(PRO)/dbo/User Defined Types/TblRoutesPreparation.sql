CREATE TYPE [dbo].[TblRoutesPreparation] AS TABLE (
    [rwNumber]        INT           NULL,
    [StartDate]       DATETIME      NULL,
    [EndDate]         DATETIME      NULL,
    [CodeOfReference] INT           NULL,
    [nameSender]      VARCHAR (200) NULL,
    [phoneSender]     VARCHAR (50)  NULL,
    [addressPickUp]   VARCHAR (500) NULL,
    [idTownship]      INT           NULL,
    [OrderP]          SMALLINT      NULL);

