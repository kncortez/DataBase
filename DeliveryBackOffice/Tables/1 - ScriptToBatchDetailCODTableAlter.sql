USE [DeliveryBackOffice]

BEGIN TRAN

--AGREGAR COLUMNAS
ALTER TABLE [dbo].[BatchDetailCOD] ADD [Comments] [nvarchar](2000) NULL;

--AGREGAR COMENTARIO A LA COLUMNA AGREGADA
EXEC sys.sp_addextendedproperty @name=N'MS_Description', 
								@value=N'Se almacena el motivo por el que se excluye el registro.' , 
								@level0type=N'SCHEMA',
								@level0name=N'dbo', 
								@level1type=N'TABLE',
								@level1name=N'BatchDetailCOD', 
								@level2type=N'COLUMN',
								@level2name=N'Comments';

--COMMIT



