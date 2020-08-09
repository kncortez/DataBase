USE DeliveryBackOffice;

CREATE TABLE [dbo].[DeliveryProof](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Guide_Serie] NVARCHAR(2) NOT NULL,
	[Guide_Number] INT NOT NULL,
	[Date_Photo] DATETIME NOT NULL,
	[Proof_Dry] VARBINARY(MAX) NULL,
	[Proof_Cold] VARBINARY(MAX) NULL,
 CONSTRAINT [PK_DeliveryProof] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE DeliveryProof ADD CONSTRAINT [FK_DeliveryOrder_DeliveryProof] FOREIGN KEY([Guide_Serie], [Guide_Number])
REFERENCES DeliveryOrder ([Guide_Serie], [Guide_Number])

ALTER TABLE DeliveryBackOffice.dbo.DeliveryAttempt ADD ID_Proof INT NULL
ALTER TABLE DeliveryBackOffice.dbo.DeliveryAttempt ADD Verified BIT NULL

ALTER TABLE DeliveryAttempt ADD CONSTRAINT FK_DeliveryAttempt_DeliveryProof FOREIGN KEY (ID_Proof) REFERENCES DeliveryProof (ID)
