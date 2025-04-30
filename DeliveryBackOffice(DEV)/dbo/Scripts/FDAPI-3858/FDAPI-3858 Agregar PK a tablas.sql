

-------------------------CatSeries------------------------------------------------------ LISTO
-- Paso 1: Eliminar la columna si ya existe 
-- Paso 3: Establecemos PK
	ALTER TABLE CatSeries
	ALTER COLUMN IdSerie VARCHAR(10) NOT NULL

	ALTER TABLE CatSeries
	ADD CONSTRAINT PK_CatSeries PRIMARY KEY (IdSerie);


---------------------------- ContImg ------------------------------------------------- LISTO
		-- Paso 1: Eliminar la columna si ya existe
	-- Paso 3: Establecer la columna
	ALTER TABLE ContImg
	ALTER COLUMN Id INT NOT NULL

	ALTER TABLE ContImg
	ADD CONSTRAINT PK_ContImg PRIMARY KEY (Id);


--------------------CreditCardTransactionByCustomerDetail----------------------------------------------------- LISTO
		-- Paso 1: Eliminar la columna si ya existe
	IF EXISTS (
		SELECT 1 FROM sys.columns 
		WHERE object_id = OBJECT_ID('CreditCardTransactionByCustomerDetail') 
			AND name = 'IdTransactionDetail'
	)
	BEGIN
		ALTER TABLE CreditCardTransactionByCustomerDetail DROP COLUMN IdTransactionDetail;
	END

	-- Paso 2: Agregar la columna 
	ALTER TABLE CreditCardTransactionByCustomerDetail
	ADD IdTransactionDetail INT IDENTITY(1,1);

	-- Paso 3: Establecer la columna
	ALTER TABLE CreditCardTransactionByCustomerDetail
	ADD CONSTRAINT PK_CreditCardTransactionByCustomerDetail PRIMARY KEY (IdTransactionDetail);




-------------DeliveryOrderContentDelivered    DEJAR CORRIENDO REGISTROS 13721 ------------------------------------- LISTO
	---YA CUENTA CON UN CAMPO UNICO DCBA_Id
	ALTER TABLE DeliveryOrderContentDelivered
	ALTER COLUMN IdDeliveryOrderContentDelivered INT NOT NULL

	ALTER TABLE DeliveryOrderContentDelivered
	ADD CONSTRAINT PK_DeliveryOrderContentDelivered PRIMARY KEY (IdDeliveryOrderContentDelivered);

------DeliveryOrderDetail DEJAR CORRIENDO REGISTROS 159263059 ------------------------------------
		-- Paso 1: Eliminar la columna si ya existe
	IF EXISTS (
		SELECT 1 FROM sys.columns 
		WHERE object_id = OBJECT_ID('DeliveryOrderDetail') 
		  AND name = 'IdDeliveryOrderDetail'
	)
	BEGIN
		ALTER TABLE DeliveryOrderDetail DROP COLUMN IdDeliveryOrderDetail;
	END

	-- Paso 2: Agregar la columna 
	ALTER TABLE DeliveryOrderDetail
	ADD IdDeliveryOrderDetail INT IDENTITY(1,1);

	-- Paso 3: Establecer la columna
	ALTER TABLE DeliveryOrderDetail
	ADD CONSTRAINT PK_DeliveryOrderDetail PRIMARY KEY (IdDeliveryOrderDetail); 

--------------------InvoiceBatchRelationships ------------------------------------- LISTO
		-- Paso 1: Eliminar la columna si ya existe
	IF EXISTS (
		SELECT 1 FROM sys.columns 
		WHERE object_id = OBJECT_ID('InvoiceBatchRelationships') 
		  AND name = 'IdInvoiceBatchRelationships'
	)
	BEGIN
		ALTER TABLE InvoiceBatchRelationships DROP COLUMN IdInvoiceBatchRelationships;
	END

	-- Paso 2: Agregar la columna 
	ALTER TABLE InvoiceBatchRelationships
	ADD IdInvoiceBatchRelationships INT IDENTITY(1,1);

	-- Paso 3: Establecer la columna
	ALTER TABLE InvoiceBatchRelationships
	ADD CONSTRAINT PK_InvoiceBatchRelationships PRIMARY KEY (IdInvoiceBatchRelationships); 

---------------------invoiceDetail DEJAR CORRIENDO REGISTROS ENCONTRADOS 8265428 ------------------------------ LISTO
		-- Paso 1: Eliminar la columna si ya existe
	IF EXISTS (
		SELECT 1 FROM sys.columns 
		WHERE object_id = OBJECT_ID('invoiceDetail') 
		  AND name = 'IdinvoiceDetail'
	)
	BEGIN
		ALTER TABLE invoiceDetail DROP COLUMN IdinvoiceDetail;
	END

	-- Paso 2: Agregar la columna 
	ALTER TABLE invoiceDetail
	ADD IdinvoiceDetail INT IDENTITY(1,1);

	-- Paso 3: Establecer la columna
	ALTER TABLE invoiceDetail
	ADD CONSTRAINT PK_invoiceDetail PRIMARY KEY (IdinvoiceDetail); 

	---------------------------- paymentDetail ------------------------------------------------- LISTO
		-- Paso 1: Eliminar la columna si ya existe
	-- Paso 3: Establecer la columna
	ALTER TABLE paymentDetail
	ALTER COLUMN pay_ticket VARCHAR(100) NOT NULL

	ALTER TABLE paymentDetail
	ADD CONSTRAINT PK_paymentDetail PRIMARY KEY (pay_ticket);

	---------------------------- PointsGuidesLog ------------------------------------------------- LISTO
		-- Paso 1: Eliminar la columna si ya existe
	-- Paso 3: Establecer la columna
	ALTER TABLE PointsGuidesLog
	ALTER COLUMN IdPointsGuidesLog NCHAR(10) NOT NULL

	ALTER TABLE PointsGuidesLog
	ADD CONSTRAINT PK_PointsGuidesLog PRIMARY KEY (IdPointsGuidesLog);


---------------------RolByUserBySystem DEJAR CORRIENDO REGISTROS ENCONTRADOS 86593 ------------------------------ LISTO
		-- Paso 1: Eliminar la columna si ya existe
	IF EXISTS (
		SELECT 1 FROM sys.columns 
		WHERE object_id = OBJECT_ID('RolByUserBySystem') 
		  AND name = 'IdRolByUserBySystem'
	)
	BEGIN
		ALTER TABLE RolByUserBySystem DROP COLUMN IdRolByUserBySystem;
	END

	-- Paso 2: Agregar la columna 
	ALTER TABLE RolByUserBySystem
	ADD IdRolByUserBySystem INT IDENTITY(1,1);

	-- Paso 3: Establecer la columna
	ALTER TABLE RolByUserBySystem
	ADD CONSTRAINT PK_RolByUserBySystem PRIMARY KEY (IdRolByUserBySystem); 


---------------------------- Warehouse REGISTROS ENCONTRADOS 5578878 ------------------------------------------------- LISTO

	ALTER TABLE Warehouse
	ADD CONSTRAINT PK_Warehouse PRIMARY KEY (Id);
