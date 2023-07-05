CREATE TABLE [dbo].[ExpressAccountServiceCartDetail] (
    [IdExpressAccountServiceCartDetail] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ExpressAccountServiceCartId]       BIGINT        NOT NULL,
    [GuideSerie]                        NVARCHAR (2)  NOT NULL,
    [GuideNumber]                       INT           NOT NULL,
    [RowStatus]                         BIT           CONSTRAINT [DF_ExpressAccountServiceCartDetail_RowStatus] DEFAULT ((1)) NOT NULL,
    [DateCreated]                       DATETIME      NOT NULL,
    [TokenCreated]                      NVARCHAR (50) NOT NULL,
    [DateUpdated]                       DATETIME      NULL,
    [TokenUpdated]                      NVARCHAR (50) NULL,
    CONSTRAINT [PK_ExpressAccountServiceCartDetail] PRIMARY KEY CLUSTERED ([IdExpressAccountServiceCartDetail] ASC)
);

