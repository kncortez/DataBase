CREATE TABLE [dbo].[ConfigParams] (
    [ConfigParamsId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [Name]           VARCHAR (500) NOT NULL,
    [Description]    VARCHAR (MAX) NULL,
    [Value]          VARCHAR (MAX) NOT NULL,
    [Status]         SMALLINT      NOT NULL,
    [CreateDate]     DATETIME      CONSTRAINT [DefaultDate] DEFAULT (getdate()) NOT NULL,
    [IdCountry]      VARCHAR(2)    NULL,
    [IdCurrencyCOD]  INT           NULL,
    CONSTRAINT [PK_ConfigParams] PRIMARY KEY CLUSTERED ([ConfigParamsId] ASC),
    FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry]),
    FOREIGN KEY ([IdCurrencyCOD]) REFERENCES [dbo].[CatCurrencyCOD] ([IdCatCurrencyCOD])
);

