USE DeliveryBackOffice;

--ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DROP CONSTRAINT FK_DeliveryOrderBySettlement
--ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DROP CONSTRAINT PK_DeliveryOrderBySettlement
--DROP TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]

CREATE TABLE [dbo].[DeliveryOrderBySettlement](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Date_Printed] [datetime] NULL,
	[User_Dispatched] [nvarchar](50) NULL,
	[Date_Dispatched] [datetime] NULL,
	[Pieces_Dry_Dispatched] [smallint] NULL,
	[Pieces_Cold_Dispatched] [smallint] NULL,
	[Guides_Dispatched] [smallint] NULL,
	[User_Received] [nvarchar](50) NULL,
	[Date_Received] [datetime] NULL,
	[Pieces_Dry_Received] [smallint] NULL,
	[Pieces_Cold_Received] [smallint] NULL,
	[Guides_Received] [smallint] NULL,
	[ID_Courier] [int] NOT NULL,
 CONSTRAINT [PK_DeliveryOrderBySettlement] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
