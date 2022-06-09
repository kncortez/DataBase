CREATE TABLE [dbo].[Unit] (
    [IdUnit]       INT           IDENTITY (1, 1) NOT NULL,
    [UnitName]     NVARCHAR (50) NULL,
    [Prefix]       NVARCHAR (5)  NULL,
    [TypeUnit]     NVARCHAR (10) NULL,
    [UnitStatus]   BIT           CONSTRAINT [DF_Unit_UnitStatus] DEFAULT ('TRUE') NULL,
    [TokenCreated] NVARCHAR (50) NULL,
    [DateCreated]  DATETIME      NULL,
    [TokenUpdated] NVARCHAR (50) NULL,
    [DateUpdated]  DATETIME      NULL,
    CONSTRAINT [PK_Unit] PRIMARY KEY CLUSTERED ([IdUnit] ASC)
);

