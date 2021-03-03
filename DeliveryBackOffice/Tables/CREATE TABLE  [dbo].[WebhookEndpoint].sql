/*

  TableName: WebhookEndpoint
Description: se almacena la URI de cada cliente donde requiera que se notifique por medio del webhook, dependiendo del tipo de notificaciones que se asigne el cliente.
CreatedDate: 02/03/2021
     Author: Marco Jiménez
	  Email: marco.jimenez@forzalatam.com

*/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WebhookEndpoint](
	[WebhookEndpointId] [bigint] IDENTITY(1,1) NOT NULL,
	[IdCustomer] [int] NOT NULL,
	[URI]       [nvarchar] (MAX) NOT NULL,
	[StatusRow] [int] NOT NULL,
	[CreatedDate] [datetime]  NULL,
	[WebhookTypeId] [int] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[WebhookEndpointId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WebhookEndpoint]  WITH NOCHECK ADD  CONSTRAINT [FK_WebhookEndpoint_IdCustomer] FOREIGN KEY([IdCustomer])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO

ALTER TABLE [dbo].[WebhookEndpoint]  WITH NOCHECK ADD  CONSTRAINT [FK_WebhookEndpoint_WebhookTypeId] FOREIGN KEY([WebhookTypeId])
REFERENCES [dbo].[WebhookType] ([WebhookTypeId])
GO

