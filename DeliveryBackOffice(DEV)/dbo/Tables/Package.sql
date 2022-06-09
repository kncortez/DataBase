CREATE TABLE [dbo].[Package] (
    [Package_Type] TINYINT       NOT NULL,
    [Package_Name] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Package] PRIMARY KEY CLUSTERED ([Package_Type] ASC)
);

