CREATE TABLE [dbo].[PR_DeliveryOrder] (
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
    [IsLastMileReturn]                     BIT             CONSTRAINT [PR_DF_IsLastMileReturn] DEFAULT ((0)) NULL,
    [DeliveryETA]                          DATETIME        NULL,
    [SenderCountryId]                      VARCHAR (2)     NULL,
    [ReceiverCountryId]                    VARCHAR (2)     NULL,
    [GuideType]                            NVARCHAR (3)    NULL,
    [SenderIdSettlement]                   BIGINT          NULL,
    CONSTRAINT [PR_pk_primary_key_delivery_order] PRIMARY KEY CLUSTERED ([Guide_Serie] ASC, [Guide_Number] ASC) ON [PS_DelORDER_Guide_Number] ([Guide_Number])
) ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_NCI_DeliveryOrderIsReturn]
    ON [dbo].[PR_DeliveryOrder]([IdCustomer] ASC, [VisitpointClientPortfolioId] ASC, [DateCreated] ASC, [IsReturn] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IX_NC_TypeServiceDeliveryOrder]
    ON [dbo].[PR_DeliveryOrder]([TypeService] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IX_NC_IdCustomersByGuideDeliveryOrder]
    ON [dbo].[PR_DeliveryOrder]([IdCustomer] ASC, [Guide_Serie] ASC, [Guide_Number] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_ix_IsLastMileReturn]
    ON [dbo].[PR_DeliveryOrder]([IsLastMileReturn] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IX_Guide_Number]
    ON [dbo].[PR_DeliveryOrder]([Guide_Number] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IX_DeliveryOrder_StatusOrderId_AllIncludes]
    ON [dbo].[PR_DeliveryOrder]([StatusOrderId] ASC)
    INCLUDE([Sender_ID], [DCBA_ID], [IdCustomer], [IsLastMileReturn], [SenderCountryId])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IX_DeliveryOrder_SenderMail_Guide]
    ON [dbo].[PR_DeliveryOrder]([Sender_Mail] ASC, [Guide_Serie] ASC, [Guide_Number] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IX_DeliveryOrder_SenderCountryId]
    ON [dbo].[PR_DeliveryOrder]([SenderCountryId] ASC)
    INCLUDE([Guide_Serie], [Guide_Number])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IX_DeliveryOrder_SalePipeLineId_AllIncludes]
    ON [dbo].[PR_DeliveryOrder]([SalePipeLineId] ASC)
    INCLUDE([Sender_Mail], [Sender_ID], [DCBA_ID], [IdCustomer], [Sender_Zone], [Sender_Town], [Sender_Department], [SenderIdTownship], [TypeService])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IX_DeliveryOrder_MyShippments]
    ON [dbo].[PR_DeliveryOrder]([StatusOrderId] ASC, [Sender_ID] ASC, [OriginSenderId] ASC, [DateCreated] ASC)
    INCLUDE([Guide_Serie], [Guide_Number], [Pieces_Dry], [Pieces_Cold], [Ticket_Number], [Receiver_FirstName], [Receiver_LastName], [Receiver_Phone], [IsCollect], [PriceShippment], [Collect_OnDelivery], [TypeService])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IX_DeliveryOrder_GuideLookup]
    ON [dbo].[PR_DeliveryOrder]([Guide_Serie] ASC, [Guide_Number] ASC)
    INCLUDE([StatusOrderId], [IdCustomer], [PriceShippment], [IsLastMileReturn], [SenderCountryId], [IsCollect], [Sender_ID], [Receiver_ID], [Ticket_Number], [Dispatched_Date], [Courier_Route], [Collect_OnDelivery])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IX_DeliveryOrder_GetQueryRelationshipPieceCode]
    ON [dbo].[PR_DeliveryOrder]([Ticket_Number] ASC, [Guide_Serie] ASC, [Guide_Number] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IX_DeliveryOrder_GetCustomerGuideListByStatus]
    ON [dbo].[PR_DeliveryOrder]([IdCustomer] ASC, [DateCreated] ASC, [StatusOrderId] ASC)
    INCLUDE([Sender_ID], [Sender_FirstName], [Sender_LastName], [Receiver_FirstName], [Receiver_LastName], [Receiver_Department])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IndiceSenderIncludingFilters]
    ON [dbo].[PR_DeliveryOrder]([Sender_ID] ASC)
    INCLUDE([Preparation_Date], [Receiver_FirstName], [Receiver_LastName], [Receiver_SocialSecurity_ID], [Sender_FirstName], [Sender_LastName], [Shipping_Date])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_idx_Ticket_Number_Consolidated]
    ON [dbo].[PR_DeliveryOrder]([Ticket_Number] ASC)
    INCLUDE([Preparation_Date], [Pieces_Dry], [Pieces_Cold])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IDX_StatusOrderId_IdCustomer]
    ON [dbo].[PR_DeliveryOrder]([StatusOrderId] ASC, [IdCustomer] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IDX_StatusOrderId_Guide_Number_DateCreated]
    ON [dbo].[PR_DeliveryOrder]([StatusOrderId] ASC, [Guide_Number] ASC, [DateCreated] ASC)
    INCLUDE([Ticket_Number], [Order_Number], [Preparation_Date], [Shipping_Date], [Pieces_Dry], [Pieces_Cold], [Consolidated_Number], [Recipe_Number], [Sender_ID], [Sender_FirstName], [Sender_LastName], [Sender_Address], [Sender_Zone], [Sender_Town], [Sender_Department], [Sender_Phone], [Receiver_ID], [Receiver_FirstName], [Receiver_LastName], [Receiver_Address], [Receiver_Zone], [Receiver_Town], [Receiver_Department], [Receiver_Phone], [Receiver_Email], [Receiver_SocialSecurity_ID], [Receiver_Alternant_ID], [Receiver_Alternant_FullName], [Receiver_Alternant_Address], [Receiver_Alternant_Zone], [Receiver_Alternant_Town], [Receiver_Alternant_Department], [Receiver_Alternant_Phone], [Receiver_Alternant_Email], [Receiver_Alternant_SocialSecurity_ID], [Delivery_Max_Date], [printedStatus], [Manifest_Serie], [Manifest_Number], [Receiver_CUI], [Package_Description], [Sender_Internal_Code], [Receiver_Alternant_CUI], [Courier_Route], [Courier_Name], [Courier_Vehicle_Plate], [Dispatched_Date], [Dispatched_Token], [NameOfReceiver], [Package_Type], [Collect_OnDelivery], [Guide_Collected])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IDX_SenderIdTownship]
    ON [dbo].[PR_DeliveryOrder]([SenderIdTownship] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IDX_SenderCountryId]
    ON [dbo].[PR_DeliveryOrder]([Guide_Serie] ASC, [Guide_Number] ASC, [SenderCountryId] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_idx_Sender_Mail]
    ON [dbo].[PR_DeliveryOrder]([Sender_Mail] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_idx_Sender_ID_DateCreated]
    ON [dbo].[PR_DeliveryOrder]([Sender_ID] ASC, [DateCreated] ASC)
    INCLUDE([Ticket_Number], [Order_Number], [Shipping_Date], [Pieces_Dry], [Pieces_Cold], [Sender_FirstName], [Sender_LastName], [Receiver_FirstName], [Receiver_LastName], [Receiver_Address], [Receiver_Department], [Receiver_Alternant_FullName], [Receiver_Alternant_Phone], [Receiver_Alternant_SocialSecurity_ID], [Guide_Serie], [Guide_Number], [Manifest_Serie], [Manifest_Number], [StatusOrderId], [Receiver_CUI], [Receiver_Alternant_CUI], [NameOfReceiver], [Collect_OnDelivery], [IsCollect], [PriceShippment], [IdCustomer])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IDX_Sender_Address]
    ON [dbo].[PR_DeliveryOrder]([Sender_Address] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IDX_ReceiverIdTownship_Consolidated]
    ON [dbo].[PR_DeliveryOrder]([ReceiverIdTownship] ASC)
    INCLUDE([Receiver_Town], [Guide_Serie], [Guide_Number])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IDX_OriginSenderId]
    ON [dbo].[PR_DeliveryOrder]([OriginSenderId] ASC)
    INCLUDE([Preparation_Date], [Shipping_Date], [Sender_ID], [Sender_FirstName], [Sender_LastName], [Sender_Address], [Receiver_FirstName], [Receiver_LastName], [DateCreated], [StatusOrderId], [Collect_OnDelivery], [IsCollect], [PriceShippment], [SenderIdTownship], [ReceiverIdTownship], [TypeService])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IDX_IdCustomer_DateCreated_Consolidated]
    ON [dbo].[PR_DeliveryOrder]([IdCustomer] ASC, [DateCreated] ASC)
    INCLUDE([Pieces_Dry], [Pieces_Cold], [StatusOrderId], [Collect_OnDelivery], [Ticket_Number], [Shipping_Date], [Sender_ID], [Sender_FirstName], [Sender_LastName], [Receiver_FirstName], [Receiver_LastName], [Receiver_Address], [Receiver_Alternant_SocialSecurity_ID], [Manifest_Serie], [Manifest_Number], [Receiver_CUI], [NameOfReceiver])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IDX_IdCustomer_Consolidated]
    ON [dbo].[PR_DeliveryOrder]([IdCustomer] ASC)
    INCLUDE([StatusOrderId], [Ticket_Number], [Pieces_Dry], [Pieces_Cold])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IDX_Guide_Serie_Guide_Number_IsLastMileReturn_Consolidated]
    ON [dbo].[PR_DeliveryOrder]([Guide_Serie] ASC, [Guide_Number] ASC, [IsLastMileReturn] ASC)
    INCLUDE([Sender_FirstName], [Sender_LastName], [Sender_Phone], [Receiver_Phone], [Receiver_Address], [PriceShippment], [Collect_OnDelivery], [StatusOrderId])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IDX_generate_batch_SenderCountryId_IsLastMileReturn_SenderCountryId]
    ON [dbo].[PR_DeliveryOrder]([SenderCountryId] ASC, [IsLastMileReturn] ASC, [StatusOrderId] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IDX_DeliveryOrder_User_Contact]
    ON [dbo].[PR_DeliveryOrder]([User_Contact] ASC)
    INCLUDE([ID_ContactIncident], [Contact_Confirmed])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IDX_DeliveryOrder_Ticket_Number_Customer]
    ON [dbo].[PR_DeliveryOrder]([Ticket_Number] ASC, [IdCustomer] ASC, [Preparation_Date] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_IDX_DeliveryOrder_Manifest_Status_Includes]
    ON [dbo].[PR_DeliveryOrder]([Manifest_Number] ASC, [StatusOrderId] ASC)
    INCLUDE([Ticket_Number], [Pieces_Dry], [Pieces_Cold], [Sender_FirstName], [Sender_LastName], [Receiver_FirstName], [Receiver_LastName], [Receiver_Address], [Receiver_Zone], [Receiver_Town], [Receiver_Department], [Receiver_Phone], [Delivery_Max_Date], [Guide_Serie], [Guide_Number], [Manifest_Serie], [DateCreated], [Courier_Route], [Courier_Name], [Dispatched_Date], [Package_Type], [Contact_Confirmed], [Contact_Instructions])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_idx_DCBA_ID]
    ON [dbo].[PR_DeliveryOrder]([DCBA_ID] ASC)
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [PR_idx_DateCreated_Consolidated]
    ON [dbo].[PR_DeliveryOrder]([DateCreated] ASC)
    INCLUDE([Sender_ID], [Guide_Serie], [Guide_Number], [Sender_FirstName], [Receiver_FirstName], [Receiver_LastName], [Receiver_Town], [Collect_OnDelivery], [IsCollect], [PriceShippment], [ReceiverIdTownship], [IdCustomer], [TypeService])
    ON [PS_DelORDER_Guide_Number] ([Guide_Number]);

