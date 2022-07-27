USE DeliveryBackOffice
ALTER TABLE Deliveryorder
ADD CatSystemId INT NULL 

EXECUTE sp_addextendedproperty N'MS_Description', N'ID de la tabla CatSystem, el cual indica en que sistema se creo la guía', N'SCHEMA', N'dbo', N'TABLE', N'DeliveryOrder', N'COLUMN', N'CatSystemId'

ALTER TABLE Deliveryorder
ADD CatModuleId INT NULL 

EXECUTE sp_addextendedproperty N'MS_Description', N'ID de la tabla CatModule, el cual indica en que módulo del sistema se creo la guía', N'SCHEMA', N'dbo', N'TABLE', N'DeliveryOrder', N'COLUMN', N'CatModuleId'

ALTER TABLE [dbo].[Deliveryorder]  WITH CHECK ADD  CONSTRAINT [FK_Deliveryorder_CatSystemId] FOREIGN KEY([CatSystemId])
REFERENCES [dbo].[CatSystem] ([SysIdSystem])
GO

ALTER TABLE [dbo].[Deliveryorder] CHECK CONSTRAINT [FK_Deliveryorder_CatSystemId]
GO

ALTER TABLE [dbo].[Deliveryorder]  WITH CHECK ADD  CONSTRAINT [FK_Deliveryorder_CatModuleId] FOREIGN KEY([CatModuleId])
REFERENCES [dbo].[CatModule] ([ModIdModule])
GO

ALTER TABLE [dbo].[Deliveryorder] CHECK CONSTRAINT [FK_Deliveryorder_CatModuleId]
GO