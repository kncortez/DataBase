USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[del_ParametrosFactura]    Script Date: 25/11/2020 1:47:05 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[del_ParametrosFactura](
	[dpf_VpCodeOfReference] [int] NOT NULL,
	[dpf_FELRequestor] [varchar](200) NOT NULL,
	[dpf_FELTransaction] [varchar](200) NOT NULL,
	[dpf_FELCountry] [varchar](10) NOT NULL,
	[dpf_FELEntity] [varchar](20) NOT NULL,
	[dpf_FELUser] [varchar](200) NOT NULL,
	[dpf_FELUserName] [varchar](50) NOT NULL,
	[dpf_FELData1] [varchar](50) NOT NULL,
	[dpf_FELData3] [varchar](10) NOT NULL,
	[dpf_FELCorreo] [varchar](50) NOT NULL,
	[dpf_FELAsuntoCorreoFactura] [varchar](200) NOT NULL,
	[dpf_FELAsuntoCorreoNotaCredito] [varchar](200) NOT NULL,
	[dpf_FELEstablecimiento] [varchar](15) NOT NULL,
	[dpf_FELCorreoCCO] [varchar](50) NOT NULL,
	[dpf_SAPServidorLicencias] [varchar](50) NOT NULL,
	[dpf_SAPCompania] [varchar](50) NOT NULL,
	[dpf_SAPUsuario] [varchar](50) NOT NULL,
	[dpf_SAPContrasenia] [nvarchar](100) NOT NULL,
	[dpf_SAPServidor] [varchar](50) NOT NULL,
	[dpf_SAPUsuarioBD] [varchar](50) NOT NULL,
	[dpf_SAPContraseniaBD] [nvarchar](100) NOT NULL,
	[dpf_SAPserieFactura] [varchar](50) NOT NULL,
	[dpf_SAPserieNC] [varchar](50) NOT NULL,
	[dpf_SAPseriePago] [varchar](50) NOT NULL,
	[dpf_SAPcardCode] [varchar](50) NOT NULL,
	[dpf_SAParticulo] [varchar](50) NOT NULL,
	[dpf_SAPvendor] [varchar](50) NOT NULL,
	[dpf_SAPcreditCard] [varchar](50) NOT NULL,
 CONSTRAINT [PK_del_ParametrosFactura] PRIMARY KEY CLUSTERED 
(
	[dpf_VpCodeOfReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


