/*

  TableName: WebhookLog
Description: se almacena el log de la información enviada, recibida y errores que se puedan registrar en el webhook
CreatedDate: 08/03/2021
     Author: Marco Jiménez
	  Email: marco.jimenez@forzalatam.com

*/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WebhookLog](
	[WebhookLogId] [bigint] IDENTITY(1,1) NOT NULL,
	[Guide_Serie] [varchar](5) NULL,
	[Guide_Number] [bigint] NULL,
	[WebhookTrackingQueueId] [bigint]  NULL,
	[DataSent] [nvarchar](max)  NULL,	
	[DataReceived] [nvarchar](max)  NULL,
	[ErrorDesc] [nvarchar](max)  NULL,
	[ErrorModule] [nvarchar](max)  NULL,
	[Date] [datetime] NOT NULL,	
	[RowStatus] [int] NULL
PRIMARY KEY CLUSTERED 
(
	[WebhookLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO





