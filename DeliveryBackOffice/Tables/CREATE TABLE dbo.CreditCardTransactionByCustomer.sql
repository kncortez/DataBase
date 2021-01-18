use DeliveryBackOffice
go
IF OBJECT_ID('CreditCardTransactionByCustomer') IS NULL
BEGIN
 print('creando tabla')
 CREATE TABLE [dbo].[CreditCardTransactionByCustomer](
		[IdTransaction]			[bigint] IDENTITY(1,1)	NOT NULL,
		[System]				[int]					NOT NULL,
		[CardNumber]			[nvarchar](50)			NOT NULL,
		[TypeCardNumber]		[nvarchar](5)			NOT NULL,
		[Currency]				[int]					NOT NULL,
		[Ammount]				[decimal](18, 2)		NULL	,
		[OrderNumber]			[nvarchar](38)			NOT NULL,
		[Signature]				[nvarchar](100)			NULL	,
		[CustomerReference]		int						NOT NULL,
		[ReferenceNumber]		[varchar](50)			NOT NULL,
		[ECIIndicator]			[varchar](2)			NOT NULL,
		[Authenticationresult]	[varchar](1)			NOT NULL,
		[TransactionStain]		[varchar](50)			NOT NULL,
		[CAVV]					[nvarchar](50)			NOT NULL,
		[ReasonCode]			[nvarchar](50)			NULL,
		[ReasonDescription]		[nvarchar](100)			NULL,
		[StatusSend]			int						NULL,
		[RowStatus]				bit						NOT NULL,
		[TokenCreated]			[nvarchar](50)			NOT NULL,
		[DateCreated]			datetime				NOT NULL,
		[TokenUpdated]			[nvarchar](50)			NULL,
		[DateUpdated]			datetime				NULL,
		 CONSTRAINT [PK_CreditCardTransactionByCustomer] PRIMARY KEY CLUSTERED 
		(
			[IdTransaction] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]
		
		ALTER TABLE [dbo].[CreditCardTransactionByCustomer]  WITH CHECK ADD FOREIGN KEY([System])
		REFERENCES [dbo].[CatSystem] ([SysIdSystem])
		
		ALTER TABLE [dbo].[CreditCardTransactionByCustomer]  WITH CHECK ADD FOREIGN KEY([CustomerReference])
		REFERENCES [dbo].[Customer] ([IdCustomer])
		/*LLAVE DE NEGOCIO*/
		CREATE NONCLUSTERED INDEX [IX_NC_CreditCardTransactionByCustomerOrderNumber] ON [dbo].[CreditCardTransactionByCustomer]
		(
			[OrderNumber] 
		)

		print('tabla creada')
END