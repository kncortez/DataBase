CREATE TABLE [dbo].[MetaCrecimiento] (
    [Fecha]           DATE            NOT NULL,
    [Año]             INT             NOT NULL,
    [MesNum]          INT             NOT NULL,
    [MesNombre]       VARCHAR (20)    NULL,
    [Trimestre]       VARCHAR (2)     NULL,
    [Pais]            VARCHAR (2)     NOT NULL,
    [MetaMensualPlus] DECIMAL (18, 2) NULL,
    [MetaTrimestral]  DECIMAL (18, 2) NULL,
    [MetaAnual]       DECIMAL (18, 2) NULL,
    [MetaMensual]     DECIMAL (18, 2) NULL,
    CONSTRAINT [pk_metacrecimiento] PRIMARY KEY CLUSTERED ([Fecha] ASC, [Año] ASC, [MesNum] ASC, [Pais] ASC)
);

