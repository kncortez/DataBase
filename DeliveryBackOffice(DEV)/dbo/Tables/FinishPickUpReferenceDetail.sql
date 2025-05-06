
CREATE TABLE [dbo].[FinishPickUpReferenceDetail](
	[FinishPickUpReferenceDetailId] [int] IDENTITY(1,1) NOT NULL,
	[SchedulePickupId] [bigint] NULL,
	[Reference] [nvarchar](150) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](150) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](150) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_FinishPickUpReferenceDetail] PRIMARY KEY CLUSTERED 
(
	[FinishPickUpReferenceDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[FinishPickUpReferenceDetail]  WITH CHECK ADD  CONSTRAINT [FK_FinishPickUpReferenceDetail_PickupHeader] FOREIGN KEY([SchedulePickupId])
REFERENCES [dbo].[FinishPickUpHeader] ([SchedulePickupId])
GO

ALTER TABLE [dbo].[FinishPickUpReferenceDetail] CHECK CONSTRAINT [FK_FinishPickUpReferenceDetail_PickupHeader]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificación de guía para recoleción por referencia' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpReferenceDetail', @level2type=N'COLUMN',@level2name=N'FinishPickUpReferenceDetailId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificación de cabecera de recolección por referencia' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpReferenceDetail', @level2type=N'COLUMN',@level2name=N'SchedulePickupId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referencia para la guía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpReferenceDetail', @level2type=N'COLUMN',@level2name=N'Reference'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica que el registro esta activo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpReferenceDetail', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de ussuario que creo el registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpReferenceDetail', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'fecha de creación del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpReferenceDetail', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de usuario que actualzia el registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpReferenceDetail', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'fecha de actualización del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpReferenceDetail', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para guardar la referencia de las guías en recolección POD.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FinishPickUpReferenceDetail'
GO


