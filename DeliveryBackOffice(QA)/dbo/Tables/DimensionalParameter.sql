CREATE TABLE [dbo].[DimensionalParameter] (
    [IdDimensional]     INT           IDENTITY (1, 1) NOT NULL,
    [IdUnit]            INT           NULL,
    [ByRange]           BIT           NULL,
    [ByUnity]           BIT           NULL,
    [MinimunValue]      INT           NULL,
    [MaximunValue]      INT           NULL,
    [DimensionalStatus] BIT           NULL,
    [IdCountry]         NVARCHAR (2)  NULL,
    [TokenCreated]      NVARCHAR (50) NULL,
    [DateCreated]       DATETIME      NULL,
    [TokenUpdated]      NVARCHAR (50) NULL,
    [UpdatedCreated]    DATETIME      NULL,
    CONSTRAINT [PK_DimensionalParameter] PRIMARY KEY CLUSTERED ([IdDimensional] ASC),
    CONSTRAINT [FK_DimensionalParameters_Unit] FOREIGN KEY ([IdUnit]) REFERENCES [dbo].[Unit] ([IdUnit])
);

