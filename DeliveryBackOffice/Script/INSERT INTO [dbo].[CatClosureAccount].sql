USE [DeliveryBackOffice]
GO


/*******************************
****Cuenta de Express Center****
*******************************/


-- ESTÁNDAR
INSERT INTO [dbo].[CatClosureAccount]
           ([ClosureAccountId]
		   ,[TypeService]
           ,[TypeOfInOutOfMoney]
		   ,[PayTime]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ((SELECT IdClosureAccount FROM ClosureAccount
			WHERE Name = 'Cuenta Express Center')					-- EXC
		   ,(SELECT IdTypeService FROM CatTypeServiceClosure
			WHERE NameTypeService = 'Estándar')						-- Servicio Estandar
           ,(SELECT tio_pk_id FROM ctgTypeOfInOutOfMoney
			WHERE tio_pk_name = 'pago en efectivo')					-- Pago en Efectivo
		   ,(SELECT TimePlaId FROM CatPaymentTime
			WHERE TimePlaName = 'Ahora')							-- Pago ahora
           ,1
           ,'SYS-ORODRIGUEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatClosureAccount]
           ([ClosureAccountId]
		   ,[TypeService]
           ,[TypeOfInOutOfMoney]
		   ,[PayTime]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ((SELECT IdClosureAccount FROM ClosureAccount
			WHERE Name = 'Cuenta Express Center')					-- EXC
		   ,(SELECT IdTypeService FROM CatTypeServiceClosure
			WHERE NameTypeService = 'Estándar')						-- Servicio Estandar
           ,(SELECT tio_pk_id FROM ctgTypeOfInOutOfMoney
			WHERE tio_pk_name = 'pago con tarjeta')					-- Pago con tarjeta
		   ,(SELECT TimePlaId FROM CatPaymentTime
			WHERE TimePlaName = 'Ahora')							-- Pago ahora
           ,1
           ,'SYS-ORODRIGUEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatClosureAccount]
           ([ClosureAccountId]
		   ,[TypeService]
           ,[TypeOfInOutOfMoney]
		   ,[PayTime]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ((SELECT IdClosureAccount FROM ClosureAccount
			WHERE Name = 'Cuenta Express Center')					-- EXC
		   ,(SELECT IdTypeService FROM CatTypeServiceClosure
			WHERE NameTypeService = 'Estándar')						-- Servicio Estandar
           ,(SELECT tio_pk_id FROM ctgTypeOfInOutOfMoney
			WHERE tio_pk_name = 'Datafono')							-- Datafono
		   ,(SELECT TimePlaId FROM CatPaymentTime
			WHERE TimePlaName = 'Ahora')							-- Pago ahora
           ,1
           ,'SYS-ORODRIGUEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

-- DEVOLUCIÓN
INSERT INTO [dbo].[CatClosureAccount]
           ([ClosureAccountId]
		   ,[TypeService]
           ,[TypeOfInOutOfMoney]
		   ,[PayTime]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ((SELECT IdClosureAccount FROM ClosureAccount
			WHERE Name = 'Cuenta Express Center')					-- EXC
		   ,(SELECT IdTypeService FROM CatTypeServiceClosure
			WHERE NameTypeService = 'Devolución')					-- Devolución
           ,(SELECT tio_pk_id FROM ctgTypeOfInOutOfMoney
			WHERE tio_pk_name = 'pago en efectivo')					-- Pago en Efectivo
		   ,(SELECT TimePlaId FROM CatPaymentTime
			WHERE TimePlaName = 'Ahora')							-- Pago ahora
           ,1
           ,'SYS-ORODRIGUEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatClosureAccount]
           ([ClosureAccountId]
		   ,[TypeService]
           ,[TypeOfInOutOfMoney]
		   ,[PayTime]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ((SELECT IdClosureAccount FROM ClosureAccount
			WHERE Name = 'Cuenta Express Center')					-- EXC
		   ,(SELECT IdTypeService FROM CatTypeServiceClosure
			WHERE NameTypeService = 'Devolución')					-- Devolución
           ,(SELECT tio_pk_id FROM ctgTypeOfInOutOfMoney
			WHERE tio_pk_name = 'pago con tarjeta')					-- Pago con tarjeta
		   ,(SELECT TimePlaId FROM CatPaymentTime
			WHERE TimePlaName = 'Ahora')							-- Pago ahora
           ,1
           ,'SYS-ORODRIGUEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatClosureAccount]
           ([ClosureAccountId]
		   ,[TypeService]
           ,[TypeOfInOutOfMoney]
		   ,[PayTime]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ((SELECT IdClosureAccount FROM ClosureAccount
			WHERE Name = 'Cuenta Express Center')					-- EXC
		   ,(SELECT IdTypeService FROM CatTypeServiceClosure
			WHERE NameTypeService = 'Devolución')					-- Devolución
           ,(SELECT tio_pk_id FROM ctgTypeOfInOutOfMoney
			WHERE tio_pk_name = 'Datafono')							-- Datafono
		   ,(SELECT TimePlaId FROM CatPaymentTime
			WHERE TimePlaName = 'Ahora')							-- Pago ahora
           ,1
           ,'SYS-ORODRIGUEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO



/*******************************
*****Cuenta de Área de COD******
*******************************/


-- ENTREGA
INSERT INTO [dbo].[CatClosureAccount]
           ([ClosureAccountId]
		   ,[TypeService]
           ,[TypeOfInOutOfMoney]
		   ,[PayTime]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ((SELECT IdClosureAccount FROM ClosureAccount
			WHERE Name = 'Cuenta Área COD') 						-- EXC
		   ,(SELECT IdTypeService FROM CatTypeServiceClosure
			WHERE NameTypeService = 'Entrega')						-- Entrega
           ,(SELECT tio_pk_id FROM ctgTypeOfInOutOfMoney
			WHERE tio_pk_name = 'pago en efectivo')					-- Pago en Efectivo
		   ,(SELECT TimePlaId FROM CatPaymentTime
			WHERE TimePlaName = 'Ahora')							-- Pago ahora
           ,1
           ,'SYS-ORODRIGUEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatClosureAccount]
           ([ClosureAccountId]
		   ,[TypeService]
           ,[TypeOfInOutOfMoney]
		   ,[PayTime]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ((SELECT IdClosureAccount FROM ClosureAccount
			WHERE Name = 'Cuenta Área COD') 						-- EXC
		   ,(SELECT IdTypeService FROM CatTypeServiceClosure
			WHERE NameTypeService = 'Entrega')						-- Entrega
           ,(SELECT tio_pk_id FROM ctgTypeOfInOutOfMoney
			WHERE tio_pk_name = 'pago con tarjeta')					-- Pago con tarjeta
		   ,(SELECT TimePlaId FROM CatPaymentTime
			WHERE TimePlaName = 'Ahora')							-- Pago ahora
           ,1
           ,'SYS-ORODRIGUEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatClosureAccount]
           ([ClosureAccountId]
		   ,[TypeService]
           ,[TypeOfInOutOfMoney]
		   ,[PayTime]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ((SELECT IdClosureAccount FROM ClosureAccount
			WHERE Name = 'Cuenta Área COD') 						-- EXC
		   ,(SELECT IdTypeService FROM CatTypeServiceClosure
			WHERE NameTypeService = 'Entrega')						-- Entrega
           ,(SELECT tio_pk_id FROM ctgTypeOfInOutOfMoney
			WHERE tio_pk_name = 'Datafono')							-- Datafono
		   ,(SELECT TimePlaId FROM CatPaymentTime
			WHERE TimePlaName = 'Ahora')							-- Pago ahora
           ,1
           ,'SYS-ORODRIGUEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

-- RECEPCIÓN
INSERT INTO [dbo].[CatClosureAccount]
           ([ClosureAccountId]
		   ,[TypeService]
           ,[TypeOfInOutOfMoney]
		   ,[PayTime]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ((SELECT IdClosureAccount FROM ClosureAccount
			WHERE Name = 'Cuenta Área COD') 						-- EXC
		   ,(SELECT IdTypeService FROM CatTypeServiceClosure
			WHERE NameTypeService = 'Recepción')					-- Recepción
           ,(SELECT tio_pk_id FROM ctgTypeOfInOutOfMoney
			WHERE tio_pk_name = 'pago en efectivo')					-- Pago en Efectivo
		   ,(SELECT TimePlaId FROM CatPaymentTime
			WHERE TimePlaName = 'Ahora')								-- Pago ahora
           ,1
           ,'SYS-ORODRIGUEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatClosureAccount]
           ([ClosureAccountId]
		   ,[TypeService]
           ,[TypeOfInOutOfMoney]
		   ,[PayTime]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ((SELECT IdClosureAccount FROM ClosureAccount
			WHERE Name = 'Cuenta Área COD') 						-- EXC
		   ,(SELECT IdTypeService FROM CatTypeServiceClosure
			WHERE NameTypeService = 'Recepción')					-- Recepción
           ,(SELECT tio_pk_id FROM ctgTypeOfInOutOfMoney
			WHERE tio_pk_name = 'pago con tarjeta')					-- Pago con tarjeta
		   ,(SELECT TimePlaId FROM CatPaymentTime
			WHERE TimePlaName = 'Ahora')							-- Pago ahora
           ,1
           ,'SYS-ORODRIGUEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatClosureAccount]
           ([ClosureAccountId]
		   ,[TypeService]
           ,[TypeOfInOutOfMoney]
		   ,[PayTime]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ((SELECT IdClosureAccount FROM ClosureAccount
			WHERE Name = 'Cuenta Área COD') 						-- EXC
		   ,(SELECT IdTypeService FROM CatTypeServiceClosure
			WHERE NameTypeService = 'Recepción')					-- Recepción
           ,(SELECT tio_pk_id FROM ctgTypeOfInOutOfMoney
			WHERE tio_pk_name = 'Datafono')							-- Datafono
		   ,(SELECT TimePlaId FROM CatPaymentTime
			WHERE TimePlaName = 'Ahora')							-- Pago ahora
           ,1
           ,'SYS-ORODRIGUEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO