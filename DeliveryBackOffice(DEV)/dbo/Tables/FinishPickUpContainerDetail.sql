
CREATE TABLE [dbo].[FinishPickUpContainerDetail] (
    [IdFinishPickUpContainerDetail] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SchedulePickupId]              BIGINT         NULL,
    [Container]                     NVARCHAR (50)  NOT NULL,
    [Rowstatus]                     BIT            NOT NULL,
    [TokenCreated]                  NVARCHAR (150) NOT NULL,
    [DateCreated]                   DATETIME       NOT NULL,
    [TokenUpdate]                   NVARCHAR (150) NULL,
    [DateUpdate]                    NVARCHAR (150) NULL,
    CONSTRAINT [PK_FinishPickUpContainer] PRIMARY KEY CLUSTERED ([IdFinishPickUpContainerDetail] ASC),
    CONSTRAINT [FK_FinishPickUpContainerDetail_PickupHeader] FOREIGN KEY ([SchedulePickupId]) REFERENCES [dbo].[FinishPickUpHeader] ([SchedulePickupId])
);


GO


GO


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
CREATE NONCLUSTERED INDEX [IX_FinishPickUpContainerDetail_Pickup_Container]
    ON [dbo].[FinishPickUpContainerDetail]([SchedulePickupId] ASC, [Container] ASC);

