
CREATE TABLE [dbo].[FinishPickUpContainerDetail](
	[IdFinishPickUpContainerDetail] [int] IDENTITY(1,1) NOT NULL,
	[SchedulePickupId] [bigint] NULL,
	[Container] [nvarchar](50) NOT NULL,
	[Rowstatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](150) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdate] [nvarchar](150) NULL,
	[DateUpdate] [nvarchar](150) NULL,
 CONSTRAINT [PK_FinishPickUpContainer] PRIMARY KEY CLUSTERED 
(
	[IdFinishPickUpContainerDetail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[FinishPickUpContainerDetail]  WITH CHECK ADD  CONSTRAINT [FK_FinishPickUpContainerDetail_PickupHeader] FOREIGN KEY([SchedulePickupId])
REFERENCES [dbo].[FinishPickUpHeader] ([SchedulePickupId])
GO

ALTER TABLE [dbo].[FinishPickUpContainerDetail] CHECK CONSTRAINT [FK_FinishPickUpContainerDetail_PickupHeader]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Llave primaria de tabla que almacena contenedor de guías para recolección' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpContainerDetail', @level2type=N'COLUMN',@level2name=N'IdFinishPickUpContainerDetail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de recolección programada' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpContainerDetail', @level2type=N'COLUMN',@level2name=N'SchedulePickupId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contenedor de las guias para recolección' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpContainerDetail', @level2type=N'COLUMN',@level2name=N'Container'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si el registro esta activo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpContainerDetail', @level2type=N'COLUMN',@level2name=N'Rowstatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de usuario que crea el registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpContainerDetail', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'fecha de creación de registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpContainerDetail', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de usuario que actualiza el registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpContainerDetail', @level2type=N'COLUMN',@level2name=N'TokenUpdate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpContainerDetail', @level2type=N'COLUMN',@level2name=N'DateUpdate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para guardar los contenedores de las guías en recolección POD.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpContainerDetail'
GO



