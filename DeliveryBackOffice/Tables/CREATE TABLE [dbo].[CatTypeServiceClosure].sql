USE [DeliveryBackOffice]
GO
/****** Object:  Table [dbo].[TransferLog]    Script Date: 10/12/2021 10:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CatTypeServiceClosure](
    [IdTypeService] [int] IDENTITY(1,1) NOT NULL,
    [NameTypeService] [nvarchar](55) NOT NULL,
    [DescriptionTypeService] [nvarchar](100) NOT NULL,
	[StatusTypeService] [int] NOT NULL,
    [TokenCreated] [nvarchar](50) NOT NULL,
    [DateCreated] [datetime] NOT NULL,
    [TokenUpdate] [nvarchar](50) NULL,
    [DateUpdate] [datetime] NULL,
 CONSTRAINT [Pk_CatTypeService] PRIMARY KEY CLUSTERED 
(
    [IdTypeService] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'ID del tipo de servicio', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeServiceClosure', N'COLUMN', N'IdTypeService'
EXECUTE sp_addextendedproperty N'MS_Description', N'Nombre del tipo de servicio', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeServiceClosure', N'COLUMN', N'NameTypeService'
EXECUTE sp_addextendedproperty N'MS_Description', N'Descripción del tipo de servicio', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeServiceClosure', N'COLUMN', N'DescriptionTypeService'
EXECUTE sp_addextendedproperty N'MS_Description', N'Token de creacion', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeServiceClosure', N'COLUMN', N'TokenCreated'
EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de creacion', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeServiceClosure', N'COLUMN', N'DateCreated'
EXECUTE sp_addextendedproperty N'MS_Description', N'Token de actualizacion', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeServiceClosure', N'COLUMN', N'TokenUpdate'
EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de actualizacion', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeServiceClosure', N'COLUMN', N'DateUpdate'
