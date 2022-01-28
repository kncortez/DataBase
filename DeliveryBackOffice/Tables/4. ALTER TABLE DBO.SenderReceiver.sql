ALTER TABLE DBO.SenderReceiver ADD
 HubLogisticId INT, 
 CatTypeSenderReceiverId INT,
 CONSTRAINT FK_SenderReceiver_HubLogistic FOREIGN KEY (HubLogisticId) REFERENCES HubLogistics(IdHubLogistic),
 CONSTRAINT FK_SenderReceiver_CatTypeSenderReceiver FOREIGN KEY (CatTypeSenderReceiverId) REFERENCES CatTypeSenderReceiver(IdCatTypeSenderReceiver)

--Fields table description    
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id del hub al que pertenece' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SenderReceiver', @level2type=N'COLUMN',@level2name=N'HubLogisticId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id del tipo de piloto/courierman' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SenderReceiver', @level2type=N'COLUMN',@level2name=N'CatTypeSenderReceiverId'
GO

