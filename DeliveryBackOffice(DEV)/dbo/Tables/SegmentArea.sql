CREATE TABLE [dbo].[SegmentArea] (
    [IdSegmentArea]      INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [NameSegmentOfArea]  VARCHAR (50)   NULL,
    [Abrevation]         VARCHAR (10)   NULL,
    [SegmentDescription] NVARCHAR (200) NULL,
    [SegmentStatus]      BIT            NULL,
    [TokenCreated]       NVARCHAR (50)  NULL,
    [DateCreated]        DATETIME       NULL,
    [TokenUpdated]       NVARCHAR (50)  NULL,
    [DateUpdated]        DATETIME       NULL,
    [IdTypeOfSegment]    INT            NULL,
    CONSTRAINT [PK_SegmentArea] PRIMARY KEY CLUSTERED ([IdSegmentArea] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 Geografia , 2 Kilometraje', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SegmentArea', @level2type = N'COLUMN', @level2name = N'IdTypeOfSegment';

