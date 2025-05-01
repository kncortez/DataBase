
CREATE TABLE [dbo].[DefaultValuesPerCountry](
    [IdCountry] [nvarchar](4) NOT NULL,
    [UseMultiCountry] [bit] NOT NULL,
    [RowStatus] [bit] NOT NULL,
    [TokenCreated] [varchar](50) NOT NULL,
    [DateCreated] [datetime] NOT NULL,
    [TokenUpdated] [varchar](50) NULL,
    [DateUpdated] [datetime] NULL
) ON [PRIMARY]
GO
