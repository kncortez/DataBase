CREATE TABLE [dbo].[VentasUE] (
    [Fecha]     DATE            NOT NULL,
    [Año]       INT             NOT NULL,
    [MesNum]    INT             NOT NULL,
    [MesNombre] VARCHAR (20)    NULL,
    [Trimestre] VARCHAR (2)     NULL,
    [Pais]      VARCHAR (2)     NOT NULL,
    [Venta]     DECIMAL (18, 2) NULL,
    CONSTRAINT [pk_VentasUE] PRIMARY KEY CLUSTERED ([Fecha] ASC, [Año] ASC, [MesNum] ASC, [Pais] ASC)
);

