CREATE TABLE [dbo].[DeliveryOrder] (
    [Ticket_Number]                        NVARCHAR (150)  NULL,
    [Order_Number]                         INT             NULL,
    [Preparation_Date]                     DATETIME        NULL,
    [Shipping_Date]                        DATETIME        NULL,
    [Pieces_Dry]                           INT             NULL,
    [Pieces_Cold]                          INT             NULL,
    [Consolidated_Number]                  INT             NULL,
    [Recipe_Number]                        NVARCHAR (1000) NULL,
    [Sender_ID]                            INT             NULL,
    [Sender_FirstName]                     NVARCHAR (100)  NULL,
    [Sender_LastName]                      NVARCHAR (100)  NULL,
    [Sender_Address]                       NVARCHAR (200)  NULL,
    [Sender_Zone]                          NVARCHAR (100)  NULL,
    [Sender_Town]                          NVARCHAR (100)  NULL,
    [Sender_Department]                    NVARCHAR (100)  NULL,
    [Sender_Phone]                         NVARCHAR (50)   NULL,
    [Receiver_ID]                          INT             NULL,
    [Receiver_FirstName]                   NVARCHAR (100)  NULL,
    [Receiver_LastName]                    NVARCHAR (100)  NULL,
    [Receiver_Address]                     NVARCHAR (600)  NULL,
    [Receiver_Zone]                        NVARCHAR (100)  NULL,
    [Receiver_Town]                        NVARCHAR (100)  NULL,
    [Receiver_Department]                  NVARCHAR (100)  NULL,
    [Receiver_Phone]                       NVARCHAR (100)  NULL,
    [Receiver_Email]                       NVARCHAR (200)  NULL,
    [Receiver_SocialSecurity_ID]           NVARCHAR (200)  NULL,
    [Receiver_Alternant_ID]                INT             NULL,
    [Receiver_Alternant_FullName]          NVARCHAR (200)  NULL,
    [Receiver_Alternant_Address]           NVARCHAR (200)  NULL,
    [Receiver_Alternant_Zone]              NVARCHAR (100)  NULL,
    [Receiver_Alternant_Town]              NVARCHAR (100)  NULL,
    [Receiver_Alternant_Department]        NVARCHAR (100)  NULL,
    [Receiver_Alternant_Phone]             NVARCHAR (100)  NULL,
    [Receiver_Alternant_Email]             NVARCHAR (200)  NULL,
    [Receiver_Alternant_SocialSecurity_ID] NVARCHAR (200)  NULL,
    [Delivery_Max_Date]                    DATETIME        NULL,
    [printedStatus]                        TINYINT         NULL,
    [Guide_Serie]                          NVARCHAR (2)    NOT NULL,
    [Guide_Number]                         INT             NOT NULL,
    [Manifest_Serie]                       NVARCHAR (2)    NOT NULL,
    [Manifest_Number]                      INT             NOT NULL,
    [DateCreated]                          DATETIME        NOT NULL,
    [StatusOrderId]                        TINYINT         NOT NULL,
    [Receiver_CUI]                         NVARCHAR (25)   NULL,
    [Package_Description]                  NVARCHAR (200)  NULL,
    [Sender_Internal_Code]                 NVARCHAR (50)   NULL,
    [Receiver_Alternant_CUI]               NVARCHAR (25)   NULL,
    [Courier_Route]                        NVARCHAR (50)   NULL,
    [Courier_Name]                         NVARCHAR (200)  NULL,
    [Courier_Vehicle_Plate]                NVARCHAR (15)   NULL,
    [Dispatched_Date]                      DATETIME        NULL,
    [Dispatched_Token]                     NVARCHAR (50)   NULL,
    [NameOfReceiver]                       NVARCHAR (200)  NULL,
    [Package_Type]                         TINYINT         NULL,
    [Receiver_Updated]                     BIT             NULL,
    [Collect_OnDelivery]                   DECIMAL (14, 2) NULL,
    [Guide_Collected]                      BIT             NULL,
    [DateUpdated]                          DATETIME        NULL,
    [TokenUpdated]                         NVARCHAR (50)   NULL,
    [Deposit_Number]                       NVARCHAR (50)   NULL,
    [ID_ContactIncident]                   TINYINT         NULL,
    [Contact_Confirmed]                    BIT             NULL,
    [User_Contact]                         NVARCHAR (50)   NULL,
    [Date_Contact]                         DATETIME        NULL,
    [Contact_Instructions]                 NVARCHAR (200)  NULL,
    [DCBA_ID]                              BIGINT          NULL,
    [IsCollect]                            BIT             NULL,
    [PriceShippment]                       DECIMAL (14, 2) NULL,
    [SenderIdTownship]                     INT             NULL,
    [ReceiverIdTownship]                   INT             NULL,
    [User_Collect_OnDelivery]              NVARCHAR (50)   NULL,
    [Date_Collect_OnDelivery]              DATETIME        NULL,
    [IdCustomer]                           INT             NULL,
    [IndicationsToSendOrigin]              VARCHAR (1500)  NULL,
    [IndicationsToSendDestination]         VARCHAR (1500)  NULL,
    [IsInsuarance]                         BIT             NULL,
    [TypeService]                          VARCHAR (3)     NULL,
    [Sender_Mail]                          NVARCHAR (200)  NULL,
    [BilledWeight]                         DECIMAL (12, 2) NULL,
    [InsuranceAmount]                      DECIMAL (12, 2) NULL,
    [IdDeliveryOption]                     INT             NULL,
    [ReceiverIdSettlement]                 BIGINT          NULL,
    [SalePipeLineId]                       INT             NULL,
    [HubOriginId]                          INT             NULL,
    [HubDestinationId]                     INT             NULL,
    [LastCollectOnDelivery]                DECIMAL (14, 2) NULL,
    [OriginSenderId]                       INT             NULL,
    [IsReturn]                             BIT             NULL,
    [OrderUserCreated]                     VARCHAR (100)   NULL,
    [VisitpointClientPortfolioId]          BIGINT          NULL,
    [UserAddressId]                        BIGINT          NULL,
    [Segment]                              NVARCHAR (10)   NULL,
    [Sender_Lat]                           VARCHAR (50)    NULL,
    [Sender_Lng]                           VARCHAR (50)    NULL,
    [Receiver_Lat]                         VARCHAR (50)    NULL,
    [Receiver_Lng]                         VARCHAR (50)    NULL,
    [CatSystemId]                          INT             NULL,
    [CatModuleId]                          INT             NULL,
    [IsLastMileReturn]                     BIT             DEFAULT ((0)) NULL,
    [DeliveryETA]                          DATETIME        NULL,
    CONSTRAINT [pk_primary_key_delivery_order] PRIMARY KEY CLUSTERED ([Guide_Serie] ASC, [Guide_Number] ASC),
    FOREIGN KEY ([IdDeliveryOption]) REFERENCES [dbo].[CatDeliveryOptions] ([IdDeliveryOption]),
    FOREIGN KEY ([ReceiverIdSettlement]) REFERENCES [dbo].[Settlement] ([IdSettlement]),
    FOREIGN KEY ([SalePipeLineId]) REFERENCES [dbo].[CatSalePipelines] ([IdSalePipeLine]),
    CONSTRAINT [FK_Deliveryorder_CatModuleId] FOREIGN KEY ([CatModuleId]) REFERENCES [dbo].[CatModule] ([ModIdModule]),
    CONSTRAINT [FK_Deliveryorder_CatSystemId] FOREIGN KEY ([CatSystemId]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    CONSTRAINT [FK_DeliveryOrder_ContactIncident] FOREIGN KEY ([ID_ContactIncident]) REFERENCES [dbo].[ContactIncident] ([ID]),
    CONSTRAINT [FK_DeliveryOrder_ReceiverTownship] FOREIGN KEY ([ReceiverIdTownship]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [FK_DeliveryOrder_SenderTownship] FOREIGN KEY ([SenderIdTownship]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [FK_DeliveryOrder_ServiceRequest] FOREIGN KEY ([Manifest_Serie], [Manifest_Number]) REFERENCES [dbo].[ServiceRequest] ([Manifest_Serie], [Manifest_Number]),
    CONSTRAINT [FK_DeliveryOrder_StatusOrder] FOREIGN KEY ([StatusOrderId]) REFERENCES [dbo].[StatusOrder] ([StatusOrderId]),
    CONSTRAINT [FK_DeliveryOrder_VisitPointClient] FOREIGN KEY ([Sender_ID]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference]),
    CONSTRAINT [FK_DeliveryOrder_VisitPointClient1] FOREIGN KEY ([Receiver_ID]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference]),
    CONSTRAINT [fk_order_customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_PackageType] FOREIGN KEY ([Package_Type]) REFERENCES [dbo].[Package] ([Package_Type])
);


























GO
CREATE NONCLUSTERED INDEX [IndiceSenderIncludingFilters]
    ON [dbo].[DeliveryOrder]([Sender_ID] ASC)
    INCLUDE([Preparation_Date], [Receiver_FirstName], [Receiver_LastName], [Receiver_SocialSecurity_ID], [Sender_FirstName], [Sender_LastName], [Shipping_Date]);


GO
CREATE NONCLUSTERED INDEX [idx_deliveryorder_radiodispatch]
    ON [dbo].[DeliveryOrder]([Manifest_Number] ASC, [StatusOrderId] ASC)
    INCLUDE([Ticket_Number], [Pieces_Dry], [Pieces_Cold], [Sender_FirstName], [Sender_LastName], [Receiver_FirstName], [Receiver_LastName], [Receiver_Address], [Receiver_Zone], [Receiver_Town], [Receiver_Department], [Receiver_Phone], [Delivery_Max_Date], [Guide_Serie], [Guide_Number], [Manifest_Serie], [DateCreated], [Courier_Route], [Courier_Name], [Dispatched_Date], [Package_Type]);


GO
CREATE NONCLUSTERED INDEX [IDX_StatusandCollect]
    ON [dbo].[DeliveryOrder]([StatusOrderId] ASC, [Collect_OnDelivery] ASC)
    INCLUDE([Preparation_Date], [Shipping_Date], [Sender_ID], [Sender_FirstName], [Sender_LastName], [Receiver_FirstName], [Receiver_LastName], [Guide_Serie], [Guide_Number], [Manifest_Serie], [Manifest_Number], [NameOfReceiver], [Guide_Collected]);


GO
CREATE NONCLUSTERED INDEX [idorRZone]
    ON [dbo].[DeliveryOrder]([Receiver_Zone] ASC);


GO
CREATE NONCLUSTERED INDEX [idorRDep]
    ON [dbo].[DeliveryOrder]([Receiver_Department] ASC);


GO
CREATE NONCLUSTERED INDEX [idorRTown]
    ON [dbo].[DeliveryOrder]([Receiver_Town] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_IdCustomersByGuideDeliveryOrder]
    ON [dbo].[DeliveryOrder]([IdCustomer] ASC, [Guide_Serie] ASC, [Guide_Number] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TypeServiceDeliveryOrder]
    ON [dbo].[DeliveryOrder]([TypeService] ASC);


GO
CREATE NONCLUSTERED INDEX [Ticket_status_include]
    ON [dbo].[DeliveryOrder]([Manifest_Number] ASC, [StatusOrderId] ASC)
    INCLUDE([Ticket_Number], [Pieces_Dry], [Pieces_Cold], [Sender_FirstName], [Sender_LastName], [Receiver_FirstName], [Receiver_LastName], [Receiver_Address], [Receiver_Zone], [Receiver_Town], [Receiver_Department], [Receiver_Phone], [Delivery_Max_Date], [Guide_Serie], [Guide_Number], [Manifest_Serie], [DateCreated], [Courier_Route], [Courier_Name], [Dispatched_Date], [Package_Type], [Contact_Confirmed], [Contact_Instructions]);


GO
CREATE NONCLUSTERED INDEX [IX_DeliveryOrder_ReceiverIdTownship_Guides]
    ON [dbo].[DeliveryOrder]([ReceiverIdTownship] ASC)
    INCLUDE([Guide_Serie], [Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [IX_DeliveryOrder_ReceiverIdTownship_HubDestinationId]
    ON [dbo].[DeliveryOrder]([ReceiverIdTownship] ASC, [HubDestinationId] ASC)
    INCLUDE([Guide_Serie], [Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [IX_DeliveryOrder_ReceiverIdTownship_Receiver_Town_Guides]
    ON [dbo].[DeliveryOrder]([ReceiverIdTownship] ASC)
    INCLUDE([Receiver_Town], [Guide_Serie], [Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [idx_sendertown]
    ON [dbo].[DeliveryOrder]([Sender_Town] ASC);

GO
CREATE NONCLUSTERED INDEX [idx_Guide_2023]
ON [dbo].[DeliveryOrderDetail] ([StatusOrderId],[DateCreatedInSystem])
INCLUDE ([UserCreated],[DeliveryAttemptId])


GO


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha máximo de servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'Delivery_Max_Date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 Impreso, 2 Reimpreso', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'printedStatus';


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar el monto COD antes de modificarlo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'LastCollectOnDelivery';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla VisitpointClientPortfolio, con el cuál se relaciona el cliente de la cartera de EXC con la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'VisitpointClientPortfolioId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla UserAddress, con el cuál se relaciona la dirección del cliente de la cartera de EXC con la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'UserAddressId';


GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latitud de la dirección del remitente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'Sender_Lat';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Longitud de la dirección del remitente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'Sender_Lng';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latitud de la dirección del destinatario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'Receiver_Lat';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Longitud de la dirección del destinatario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'Receiver_Lng';


GO
CREATE NONCLUSTERED INDEX [IX_Guide_Number]
    ON [dbo].[DeliveryOrder]([Guide_Number] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_StatusOrderId_Guide_Number_DateCreated]
    ON [dbo].[DeliveryOrder]([StatusOrderId] ASC, [Guide_Number] ASC, [DateCreated] ASC)
    INCLUDE([Ticket_Number], [Order_Number], [Preparation_Date], [Shipping_Date], [Pieces_Dry], [Pieces_Cold], [Consolidated_Number], [Recipe_Number], [Sender_ID], [Sender_FirstName], [Sender_LastName], [Sender_Address], [Sender_Zone], [Sender_Town], [Sender_Department], [Sender_Phone], [Receiver_ID], [Receiver_FirstName], [Receiver_LastName], [Receiver_Address], [Receiver_Zone], [Receiver_Town], [Receiver_Department], [Receiver_Phone], [Receiver_Email], [Receiver_SocialSecurity_ID], [Receiver_Alternant_ID], [Receiver_Alternant_FullName], [Receiver_Alternant_Address], [Receiver_Alternant_Zone], [Receiver_Alternant_Town], [Receiver_Alternant_Department], [Receiver_Alternant_Phone], [Receiver_Alternant_Email], [Receiver_Alternant_SocialSecurity_ID], [Delivery_Max_Date], [printedStatus], [Manifest_Serie], [Manifest_Number], [Receiver_CUI], [Package_Description], [Sender_Internal_Code], [Receiver_Alternant_CUI], [Courier_Route], [Courier_Name], [Courier_Vehicle_Plate], [Dispatched_Date], [Dispatched_Token], [NameOfReceiver], [Package_Type], [Collect_OnDelivery], [Guide_Collected]);


GO
CREATE NONCLUSTERED INDEX [IDX_OriginSenderId]
    ON [dbo].[DeliveryOrder]([OriginSenderId] ASC)
    INCLUDE([Preparation_Date], [Shipping_Date], [Sender_ID], [Sender_FirstName], [Sender_LastName], [Sender_Address], [Receiver_FirstName], [Receiver_LastName], [DateCreated], [StatusOrderId], [Collect_OnDelivery], [IsCollect], [PriceShippment], [SenderIdTownship], [ReceiverIdTownship], [TypeService]);


GO
CREATE NONCLUSTERED INDEX [idx_DateCreated]
    ON [dbo].[DeliveryOrder]([DateCreated] ASC)
    INCLUDE([Sender_ID], [Guide_Serie], [Guide_Number]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Segmento del servicio LOC, MET, FOR ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'Segment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador para el VisitPoint del Express Center.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'OriginSenderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si es una devolución.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'IsReturn';


GO
CREATE NONCLUSTERED INDEX [idx_Sender_ID_DateCreated]
    ON [dbo].[DeliveryOrder]([Sender_ID] ASC, [DateCreated] ASC)
    INCLUDE([Ticket_Number], [Order_Number], [Shipping_Date], [Pieces_Dry], [Pieces_Cold], [Sender_FirstName], [Sender_LastName], [Receiver_FirstName], [Receiver_LastName], [Receiver_Address], [Receiver_Department], [Receiver_Alternant_FullName], [Receiver_Alternant_Phone], [Receiver_Alternant_SocialSecurity_ID], [Guide_Serie], [Guide_Number], [Manifest_Serie], [Manifest_Number], [StatusOrderId], [Receiver_CUI], [Receiver_Alternant_CUI], [NameOfReceiver], [Collect_OnDelivery], [IsCollect], [PriceShippment], [IdCustomer]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatSystem, el cual indica en que sistema se creo la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'CatSystemId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatModule, el cual indica en que módulo del sistema se creo la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'CatModuleId';


GO
CREATE NONCLUSTERED INDEX [idx_status]
    ON [dbo].[DeliveryOrder]([StatusOrderId] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_SenderIdTownship]
    ON [dbo].[DeliveryOrder]([SenderIdTownship] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_ReceiverIdTownship]
    ON [dbo].[DeliveryOrder]([ReceiverIdTownship] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la guía va a proceso devolución.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'IsLastMileReturn';


GO
CREATE NONCLUSTERED INDEX [IDX_StatusOrderId_IdCustomer]
    ON [dbo].[DeliveryOrder]([StatusOrderId] ASC, [IdCustomer] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_IdCustomer_INCLUDE]
    ON [dbo].[DeliveryOrder]([IdCustomer] ASC)
    INCLUDE([StatusOrderId]);


GO
CREATE NONCLUSTERED INDEX [IDX_Sender_Address]
    ON [dbo].[DeliveryOrder]([Sender_Address] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_Sender_Mail]
    ON [dbo].[DeliveryOrder]([Sender_Mail] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_DCBA_ID]
    ON [dbo].[DeliveryOrder]([DCBA_ID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica el tiempo estimado de entrega de la guía, cálculado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrder', @level2type = N'COLUMN', @level2name = N'DeliveryETA';


GO
CREATE NONCLUSTERED INDEX [IDX_DeliveryOrder_Sender_Mail]
    ON [dbo].[DeliveryOrder]([Sender_Mail] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DeliveryOrder_MyShippments]
    ON [dbo].[DeliveryOrder]([StatusOrderId] ASC, [Sender_ID] ASC, [OriginSenderId] ASC, [DateCreated] ASC)
    INCLUDE([Guide_Serie], [Guide_Number], [Pieces_Dry], [Pieces_Cold], [Ticket_Number], [Receiver_FirstName], [Receiver_LastName], [Receiver_Phone], [IsCollect], [PriceShippment], [Collect_OnDelivery], [TypeService]);


GO
CREATE NONCLUSTERED INDEX [IDX_DeliveryOrder_User_Contact]
    ON [dbo].[DeliveryOrder]([User_Contact] ASC)
    INCLUDE([ID_ContactIncident], [Contact_Confirmed]);

GO
CREATE NONCLUSTERED INDEX [IDX_DeliveryOrder_GetDailyCodPayment]
		ON [dbo].[DeliveryOrder]( [SalePipeLineId] )
		INCLUDE([Sender_Mail],[Sender_ID],[DCBA_ID],[IdCustomer]);
GO
CREATE NONCLUSTERED INDEX [IDX_Guide_Serie_Guide_Number_IsLastMileReturn]
    ON [dbo].[DeliveryOrder]([Guide_Serie] ASC, [Guide_Number] ASC, [IsLastMileReturn] ASC);

GO
--CREATE NONCLUSTERED INDEX [IX_DeliveryOrder_GetCustomerGuideListByStatus] ON [DeliveryBackOffice].[dbo].[DeliveryOrder] 
--(
--	[IdCustomer] ASC,
--	[DateCreated] ASC,
--	[StatusOrderId] ASC
--)
--INCLUDE (
--	[Sender_ID],
--	[Sender_FirstName],
--	[Sender_LastName],
--	[Receiver_FirstName],
--	[Receiver_LastName],
--	[Receiver_Department]
--)
GO
CREATE NONCLUSTERED INDEX [IX_DeliveryOrder_GetCustomerGuideListByStatus]
    ON [dbo].[DeliveryOrder]([IdCustomer] ASC, [DateCreated] ASC, [StatusOrderId] ASC)
    INCLUDE([Sender_ID], [Sender_FirstName], [Sender_LastName], [Receiver_FirstName], [Receiver_LastName], [Receiver_Department]);


GO
CREATE NONCLUSTERED INDEX [IX_DeliveryOrder_GetQueryRelationshipPieceCode]
	ON [dbo].[DeliveryOrder] ([Ticket_Number],[Guide_Number]);

