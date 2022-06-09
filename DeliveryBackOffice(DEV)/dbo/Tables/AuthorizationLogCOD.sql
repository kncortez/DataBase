CREATE TABLE [dbo].[AuthorizationLogCOD] (
    [IdAuthorizationLogCOD] BIGINT          IDENTITY (1, 1) NOT NULL,
    [GuideSerie]            VARCHAR (4)     NOT NULL,
    [GuideNumber]           INT             NOT NULL,
    [Voucher]               NVARCHAR (800)  NULL,
    [AuthorizedBy]          VARCHAR (MAX)   NOT NULL,
    [ReasonId]              BIGINT          NOT NULL,
    [OldCODAmount]          DECIMAL (14, 2) NOT NULL,
    [NewCODAmount]          DECIMAL (14, 2) NOT NULL,
    [RowStatus]             BIT             NOT NULL,
    [TokenCreated]          VARCHAR (50)    NOT NULL,
    [DateCreated]           DATETIME        NOT NULL,
    [TokenUpdated]          VARCHAR (50)    NULL,
    [DateUpdated]           DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdAuthorizationLogCOD] ASC)
);

