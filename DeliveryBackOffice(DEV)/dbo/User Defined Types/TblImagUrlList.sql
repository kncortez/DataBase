CREATE TYPE [dbo].[TblImagUrlList] AS TABLE (
    [imageId]          INT             NULL,
    [imageName]        NVARCHAR (50)   NULL,
    [imageDescription] NVARCHAR (200)  NULL,
    [imageURL]         NVARCHAR (2000) NULL);

