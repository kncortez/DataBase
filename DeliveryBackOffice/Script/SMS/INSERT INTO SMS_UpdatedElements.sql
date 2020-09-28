USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[SMS_UpdatedElements]
           ([UpdateStatus]
           ,[ElementId]
           ,[ElementName]
           ,[RowStatus]
           ,[Token]
           ,[UpdateDateTime])
     VALUES
           (1--<UpdateStatus, bit,>
           ,1001--<ElementId, int,>
           ,'DeliveryBackOffice.dbo.DeliveryOrder'--<ElementName, nvarchar(300),>
           ,1--<RowStatus, bit,>
           ,'SYS-INIT'--<Token, nvarchar(50),>
           ,GETDATE()--<UpdateDateTime, datetime,>--Setear la fecha con que se requiere iniciar el envió de SMS
		   )
GO


