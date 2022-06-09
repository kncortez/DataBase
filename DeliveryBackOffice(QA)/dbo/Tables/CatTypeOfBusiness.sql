CREATE TABLE [dbo].[CatTypeOfBusiness] (
    [IdTypeOfBusiness]          INT            IDENTITY (1, 1) NOT NULL,
    [TypeOfBusinessName]        NVARCHAR (50)  NULL,
    [TypeOfBusinessDescription] NVARCHAR (200) NULL,
    [CountryID]                 VARCHAR (2)    NULL,
    [RowStatus]                 BIT            NULL,
    [TokenCreated]              NVARCHAR (50)  NULL,
    [DateCreated]               DATETIME       NULL,
    [TokenUpdated]              NVARCHAR (50)  NULL,
    [DateUpdated]               DATETIME       NULL,
    CONSTRAINT [PK_CatTypeOfBusiness] PRIMARY KEY CLUSTERED ([IdTypeOfBusiness] ASC)
);

