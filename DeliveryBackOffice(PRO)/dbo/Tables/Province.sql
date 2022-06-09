CREATE TABLE [dbo].[Province] (
    [IdProvince]           INT            IDENTITY (1, 1) NOT NULL,
    [ProvinceName]         NVARCHAR (50)  NULL,
    [ProvinceDescription]  NVARCHAR (100) NULL,
    [ProvinceStatus]       BIT            NULL,
    [ProvinceLatitud]      DECIMAL (9, 6) NULL,
    [ProvinceLongitud]     DECIMAL (9, 6) NULL,
    [PostalCode]           NVARCHAR (5)   NULL,
    [IdCountry]            NVARCHAR (2)   NULL,
    [TokenCreated]         NVARCHAR (50)  NULL,
    [DateCreated]          DATETIME       NULL,
    [TokenUpdated]         NVARCHAR (50)  NULL,
    [DateUpdated]          DATETIME       NULL,
    [ProvinceAbbreviation] NVARCHAR (3)   NULL,
    [LocalCode]            VARCHAR (10)   NULL,
    CONSTRAINT [PK_Province] PRIMARY KEY CLUSTERED ([IdProvince] ASC)
);

