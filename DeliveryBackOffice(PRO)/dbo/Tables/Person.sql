CREATE TABLE [dbo].[Person] (
    [PerIdPerson]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [PerFirstName]      VARCHAR (100) NOT NULL,
    [PerLastName]       VARCHAR (100) NOT NULL,
    [PerGender]         VARCHAR (2)   NULL,
    [PerBirthdate]      DATE          NULL,
    [PerIdentification] VARCHAR (50)  NOT NULL,
    [PerNationality]    VARCHAR (100) NOT NULL,
    [PerRowStatus]      BIT           NOT NULL,
    [PerTokenCreated]   VARCHAR (50)  NOT NULL,
    [PerDateCreated]    DATE          NOT NULL,
    [PerTokenUpdated]   VARCHAR (50)  NULL,
    [PerDateUpdated]    DATE          NULL,
    PRIMARY KEY CLUSTERED ([PerIdPerson] ASC)
);

