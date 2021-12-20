CREATE TABLE BatchDetailCODLog(
	IdBatchDeatilCODLog int identity(1,1) not null,
	BatchCODId int,
	GuideSerie nvarchar(2) not null,
	GuideNumber int not null,
	Excluded bit not null,
	RowStatus bit not null,
	TokenCreated nvarchar(50) not null,
	DateCreated datetime not null,
	TokenUpdated nvarchar(50) not null,
	DateUpdated datetime not null,
	CONSTRAINT PK_BatchDetailCODLog PRIMARY KEY (IdBatchDeatilCODLog),
);


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id del registro'  , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchDetailCODLog', @level2type=N'COLUMN',@level2name=N'IdBatchDeatilCODLog'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id del lote COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchDetailCODLog', @level2type=N'COLUMN',@level2name=N'BatchCODId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie de guía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchDetailCODLog', @level2type=N'COLUMN',@level2name=N'GuideSerie'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de guía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchDetailCODLog', @level2type=N'COLUMN',@level2name=N'GuideNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si la guía fue excluida' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchDetailCODLog', @level2type=N'COLUMN',@level2name=N'Excluded'
GO
