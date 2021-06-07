ALTER TABLE  dbo.DeliveryOrder 
ADD SalePipeLineId int null


ALTER TABLE  dbo.DeliveryOrder 
ADD FOREIGN KEY(SalePipeLineId) REFERENCES CatSalePipelines(IdSalePipeLine)


