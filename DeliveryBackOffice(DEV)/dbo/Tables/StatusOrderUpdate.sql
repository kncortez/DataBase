CREATE TABLE [dbo].[StatusOrderUpdate] (
    [StatusOrderId]   TINYINT NOT NULL,
    [InvalidIdUpdate] TINYINT NOT NULL,
    PRIMARY KEY CLUSTERED ([StatusOrderId] ASC, [InvalidIdUpdate] ASC),
    FOREIGN KEY ([StatusOrderId]) REFERENCES [dbo].[StatusOrder] ([StatusOrderId])
);

