USE [TIS]
GO

/****** Object:  StoredProcedure [dbo].[AgencyGet]    Script Date: 2/16/2017 11:17:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
--Modification History------------
--02/16/2017  : Included Inactive Column (Anitha)
-- =============================================
ALTER PROCEDURE [dbo].[AgencyGet] 
	-- Add the parameters for the stored procedure here
		@ParentAgencyID int = null,	
		@AgencyID int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	if (@ParentAgencyID is not null)
	begin
		select AgencyID, AgencyTypeID, AgencyName, AgencyNickName, AgencyNumber, ParentAgencyID, OdysseyAgencyID, DefaultCourtID, OdysseyJudicialOfficerCd,
				defaultnotaryID,defaultaffiantid,Inactive
          from dbo.Agency (nolock)
         where /*Inactive = 0
		   and */ ParentAgencyID = @ParentAgencyID
			order by agencyname
	end
	else if (@AgencyID is null)
	Begin
		select AgencyID, AgencyTypeID, AgencyName, AgencyNickName, AgencyNumber, ParentAgencyID, OdysseyAgencyID, DefaultCourtID, OdysseyJudicialOfficerCd,
			defaultnotaryID,defaultaffiantid,Inactive
          from dbo.Agency (nolock)
		  /*where Inactive = 0*/
			order by agencyname
         
    end
	Else
	Begin
		Select AgencyID, AgencyTypeID, AgencyName, AgencyNickName, AgencyNumber, ParentAgencyID, OdysseyAgencyID, DefaultCourtID, OdysseyJudicialOfficerCd,
			defaultnotaryID,defaultaffiantid,Inactive
          from dbo.Agency (nolock)
         where /*Inactive = 0 and */AgencyID = @AgencyID
	end 
	
END









GO


