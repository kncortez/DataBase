/*

  TableName: WebhookTrackingQueue
Description: se almacena la cola de cambio de estado de las guías, 
             para posteriormente ser procesadas y enviar por medio de un HTTP POST al endpoint 
			 indicado por cada cliente en la tabla WebhookEndpoint.
CreatedDate: 02/03/2021
     Author: Marco Jiménez
	  Email: marco.jimenez@forzalatam.com

*/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WebhookTrackingQueue](
	[WebhookTrackingQueueId] [bigint] IDENTITY(1,1) NOT NULL,
	[Guide_Serie] [varchar](5) NULL,
	[Guide_Number] [bigint] NULL,
	[IdCustomer] [int],
	[Status] [int] NULL,
	[WebhookEndpointId] [bigint] NOT NULL,
	[HasNotified] [bit] NULL,
	[ChangedDate] [datetime],
PRIMARY KEY CLUSTERED 
(
	[WebhookTrackingQueueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WebhookTrackingQueue]  WITH NOCHECK ADD  CONSTRAINT [FK_WebhookTrackingQueue_IdCustomer] FOREIGN KEY([IdCustomer])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO


ALTER TABLE [dbo].[WebhookTrackingQueue]  WITH NOCHECK ADD  CONSTRAINT [FK_WebhookEndpointId_WebhookEndpointId] FOREIGN KEY([WebhookEndpointId])
REFERENCES [dbo].[WebhookEndpoint] ([WebhookEndpointId])
GO



