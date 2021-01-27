use DeliveryBackOffice
go
IF OBJECT_ID('DeliveryOrderPiece') IS not NULL
BEGIN
	drop  table DeliveryBackOffice.[dbo].[DeliveryOrderPiece](
End
go
CREATE TABLE DeliveryBackOffice.[dbo].[DeliveryOrderPiece](
	[GuidePiece]  bigint IDENTITY(1,1),
	[GuideSerie] [nvarchar](2) NOT NULL,
	[GuideNumber] [int] NOT NULL,
	[PiecePhysicalWeight] [decimal](12, 2) NULL,
	[PieceHeight] [decimal](12, 2) NULL,
	[PieceWidth] [decimal](12, 2) NULL,
	[PieceLength] [decimal](12, 2) NULL,
	[PieceWeight] [decimal](12, 2) NULL,
	[Detail]	  varchar(2500) null,
	[Currency]    varchar(20) null,
	[Amount]		[decimal](12,2) null,
	[DateCreated] [datetime] NOT NULL,
	[PieceUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
	[fragile]		bit NULL,
 CONSTRAINT [PK_DeliveryOrderPiece] PRIMARY KEY NONCLUSTERED
(
	[GuideSerie] ASC,
	[GuideNumber] ASC,
	[GuidePiece] ASC
)
) ON [PRIMARY]
GO
