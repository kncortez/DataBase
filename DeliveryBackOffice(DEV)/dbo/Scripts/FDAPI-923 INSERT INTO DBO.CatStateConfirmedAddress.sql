USE [DeliveryBackOffice]
GO
INSERT INTO DBO.CatStateConfirmedAddress 
(NameState,TokenCreated,DateCreated,TokenUpdate,DateUPdate,RowStatus) 
Values('CONFIRMADO','SYS-AIXCHOP',GETDATE(),NULL,NULL,1);



