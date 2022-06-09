CREATE TABLE [dbo].[ConfigParams] (
    [ConfigParamsId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [Name]           VARCHAR (500) NOT NULL,
    [Description]    VARCHAR (MAX) NULL,
    [Value]          VARCHAR (MAX) NOT NULL,
    [Status]         SMALLINT      NOT NULL,
    [CreateDate]     DATETIME      CONSTRAINT [DefaultDate] DEFAULT (getdate()) NOT NULL
);

