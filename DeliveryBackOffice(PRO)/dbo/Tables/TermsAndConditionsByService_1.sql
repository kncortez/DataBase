CREATE TABLE [dbo].[TermsAndConditionsByService] (
    [IdTermsAndConditionsByService] BIGINT       IDENTITY (1, 1) NOT NULL,
    [TermsAndConditionsId]          BIGINT       NOT NULL,
    [ServiceManagementId]           INT          NOT NULL,
    [IsAccepted]                    BIT          NOT NULL,
    [RowStatus]                     BIT          NOT NULL,
    [TokenCreated]                  VARCHAR (50) NOT NULL,
    [DateCreated]                   DATETIME     NOT NULL,
    [TokenUpdated]                  VARCHAR (50) NULL,
    [DateUpdated]                   DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdTermsAndConditionsByService] ASC),
    CONSTRAINT [FK_TACBYSERVICE_SERVICEM] FOREIGN KEY ([ServiceManagementId]) REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement]),
    CONSTRAINT [FK_TACBYSERVICE_TAC] FOREIGN KEY ([TermsAndConditionsId]) REFERENCES [dbo].[TermsAndConditions] ([IdTAC])
);

