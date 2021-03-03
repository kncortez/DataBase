/*

  TableName: WebhookType
Description: se almacena los tipos de respuesta a los que este asignado el endpoint del cliente.
CreatedDate: 02/03/2021
     Author: Marco Jiménez
	  Email: marco.jimenez@forzalatam.com

*/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WebhookType](
	[WebhookTypeId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](250) NOT NULL,
	[Description]       [nvarchar] (500) NOT NULL,
	[StatusRow] [int] NOT NULL,
	[CreatedDate] [datetime]  NULL,
PRIMARY KEY CLUSTERED 
(
	[WebhookTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


