CREATE TABLE [dbo].[KindOfVPClient] (
    [IdKindOfVPClient] INT           IDENTITY (1, 1) NOT NULL,
    [KindOfVPName]     NVARCHAR (50) NULL,
    [KindOfVPStatus]   BIT           NULL,
    [TokenCreated]     NVARCHAR (50) NULL,
    [DateCreated]      DATETIME      NULL,
    [TokenUpdate]      NVARCHAR (50) NULL,
    [DateUpdated]      DATETIME      NULL,
    CONSTRAINT [PK_KindOfVPClient] PRIMARY KEY CLUSTERED ([IdKindOfVPClient] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 activo, 2 inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'KindOfVPClient', @level2type = N'COLUMN', @level2name = N'KindOfVPStatus';

