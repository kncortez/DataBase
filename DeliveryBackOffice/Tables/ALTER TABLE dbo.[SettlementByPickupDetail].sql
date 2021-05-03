/****** Se agrega Columna IsDispatched para poder tener el control de las piezas despachadas y no despachadas ******/

  ALTER TABLE dbo.[SettlementByPickupDetail]
	ADD IsDispatched BIT NULL 
GO
