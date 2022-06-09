CREATE TABLE [dbo].[KindOfVPBusiness] (
    [IdKindOfVPBusiness]     INT            IDENTITY (1, 1) NOT NULL,
    [KindOfVPNameBussiness]  NVARCHAR (100) NULL,
    [Shorthand]              NVARCHAR (15)  NULL,
    [StatusKindOfVPBusiness] BIT            NULL,
    [TokenCreated]           NVARCHAR (50)  NULL,
    [DateCreated]            DATETIME       NULL,
    [TokenUpdate]            NVARCHAR (50)  NULL,
    [DateUpdated]            DATETIME       NULL,
    CONSTRAINT [PK_KindOfVPBusiness] PRIMARY KEY CLUSTERED ([IdKindOfVPBusiness] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 activo, 0 inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'KindOfVPBusiness', @level2type = N'COLUMN', @level2name = N'StatusKindOfVPBusiness';

