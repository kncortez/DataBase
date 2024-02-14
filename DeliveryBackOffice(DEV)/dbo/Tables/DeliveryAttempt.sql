CREATE TABLE [dbo].[DeliveryAttempt] (
    [ID]                           BIGINT        IDENTITY (1, 1) NOT NULL,
    [Guide_Serie]                  NVARCHAR (2)  NOT NULL,
    [Guide_Number]                 INT           NOT NULL,
    [Dry]                          BIT           NOT NULL,
    [Cold]                         BIT           NOT NULL,
    [Latitude]                     NVARCHAR (20) NULL,
    [Longitude]                    NVARCHAR (20) NULL,
    [Delivered]                    BIT           NOT NULL,
    [ID_Courier]                   INT           NULL,
    [ID_DeliveryOrderBySettlement] BIGINT        NULL,
    [User_Created]                 NVARCHAR (50) NOT NULL,
    [Date_Created]                 DATETIME      NOT NULL,
    [ID_Proof]                     INT           NULL,
    [Verified]                     BIT           NULL,
    [Accepted]                     BIT           NULL,
    [User_Verified]                NVARCHAR (50) NULL,
    [Date_Verified]                DATETIME      NULL,
    [Accuracy]                     NVARCHAR (20) NULL,
    [ID_Incident]                  TINYINT       NULL,
    [Guide_Piece]                  SMALLINT      NULL,
    [LogLatitude]                  NVARCHAR (20) NULL,
    [LogLongitude]                 NVARCHAR (20) NULL,
    [ConfirmationOfIncidenceId]    INT           NULL,
    [IsLastMileReturn]             BIT           NULL,
    CONSTRAINT [PK_DeliveryAttempt] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DeliveryAttempt_ConfirmationOfIncidence] FOREIGN KEY ([ConfirmationOfIncidenceId]) REFERENCES [dbo].[ConfirmationOfIncidence] ([IdConfirmationOfIncidence]),
    CONSTRAINT [FK_DeliveryAttempt_DeliveryOrder] FOREIGN KEY ([Guide_Serie], [Guide_Number]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_DeliveryAttempt_DeliveryOrderBySettlement] FOREIGN KEY ([ID_DeliveryOrderBySettlement]) REFERENCES [dbo].[DeliveryOrderBySettlement] ([ID]),
    CONSTRAINT [FK_DeliveryAttempt_DeliveryProof] FOREIGN KEY ([ID_Proof]) REFERENCES [dbo].[DeliveryProof] ([ID]),
    CONSTRAINT [FK_DeliveryAttempt_IDCourier] FOREIGN KEY ([ID_Courier]) REFERENCES [dbo].[SenderReceiver] ([ID])
);












GO
CREATE NONCLUSTERED INDEX [idx_deliveryattempt_guide]
    ON [dbo].[DeliveryAttempt]([Guide_Serie] ASC, [Guide_Number] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_ACCEPTED_DELIVERED]
    ON [dbo].[DeliveryAttempt]([Guide_Serie] ASC, [Guide_Number] ASC, [Delivered] ASC, [Accepted] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_Latitude]
    ON [dbo].[DeliveryAttempt]([Guide_Serie] ASC, [Guide_Number] ASC)
    INCLUDE([Latitude]);


GO
CREATE NONCLUSTERED INDEX [IDX_Longitude]
    ON [dbo].[DeliveryAttempt]([Guide_Serie] ASC, [Guide_Number] ASC)
    INCLUDE([Longitude]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bitácora de latitud relacionada al servicio la cual no entro dentro de una geocerca', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryAttempt', @level2type = N'COLUMN', @level2name = N'LogLatitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bitácora de longitud relacionada al servicio la cual no entro dentro de una geocerca', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryAttempt', @level2type = N'COLUMN', @level2name = N'LogLongitude';


GO
CREATE NONCLUSTERED INDEX [IDX_ID_Courier_Date_Created]
    ON [dbo].[DeliveryAttempt]([ID_Courier] ASC, [Date_Created] ASC)
    INCLUDE([Guide_Serie], [Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [IDX_Guide_Number]
    ON [dbo].[DeliveryAttempt]([Guide_Number] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de tabla ConfirmationOfIncidence que sirve para la landing page de incidencias.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryAttempt', @level2type = N'COLUMN', @level2name = N'ConfirmationOfIncidenceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para indicar devolución', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryAttempt', @level2type = N'COLUMN', @level2name = N'IsLastMileReturn';


GO
CREATE NONCLUSTERED INDEX [idx_ID_Incident]
    ON [dbo].[DeliveryAttempt]([ID_Incident] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20231128-000040]
    ON [dbo].[DeliveryAttempt]([ConfirmationOfIncidenceId] ASC)
    INCLUDE([Guide_Number], [ID_Incident]);

