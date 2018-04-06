USE [TIS]
GO

/****** Object:  StoredProcedure [dbo].[ProcessCase]    Script Date: 2/20/2017 11:55:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ProcessCase]
@CaseID		INT,
@ErrFlg		INT=1	OUTPUT
AS 
SET NOCOUNT ON
BEGIN TRY
	
	IF EXISTS(SELECT CaseID From OdysseyMessageTable WHERE (CaseID=@CaseID))
	BEGIN	
		INSERT INTO ArchOdysseyMessageTable
		SELECT * FROM OdysseyMessageTable WHERE (CaseID=@CaseID)
		UPDATE OdysseyMessageTable
		SET CaseID=@CaseID,
			ProcessedDT=CURRENT_TIMESTAMP,
			OdysseyAPIMessage=NULL, 
			OdysseyAPIResponse=NULL, 
			ErrorMessage=NULL
		WHERE (CaseID=@CaseID)
	END
	ELSE
	BEGIN
		INSERT INTO OdysseyMessageTable (CaseID) VALUES(@CaseID)
	END
	
	DECLARE @OdysseyAPIMessage	XML
	DECLARE @OdysseyAPIResponse	XML
	DECLARE @XmlDocument		Table (Doc XML)
	DECLARE @Party1ID			INT
	DECLARE @Party2ID			INT
	DECLARE @EventDate			DATETIME
	DECLARE @DocTable			Table (CaseDocumentID INT,CaseID INT, DocumentPath VarChar(1000))
	DECLARE @CaseDocumentID		INT
	DECLARE @SourcePath			nVarChar(1000)
	DECLARE @DestinationPath	nVarChar(1000)
	DECLARE @DocumentPath		nVarChar(1000)
	DECLARE @Command			nVarChar(1000)	
	
	SELECT TOP 1 @SourcePath=BaseCaseDocumentsPath,@DestinationPath=OdysseyDocUploadPath FROM TISConfig	
	
	SET @EventDate=GetDate()
	SET @OdysseyAPIMessage=dbo.AppOdysseyDoc(@CaseID)

	INSERT INTO @XmlDocument(Doc)VALUES(@OdysseyAPIMessage)

	SELECT 
		@Party1ID=Doc.value('(/Transaction/Message[1]/@ReferenceNumber)[1]','int'),
		@Party2ID=Doc.value('(/Transaction/Message[2]/@ReferenceNumber)[1]','int')
	FROM @XmlDocument	

-- Correct Reference Numbers

	UPDATE @XmlDocument
		SET Doc.modify('replace value of (/Transaction/Message[1]/@ReferenceNumber)[1] with 1')
	UPDATE @XmlDocument
		SET Doc.modify('replace value of (/Transaction/Message[2]/@ReferenceNumber)[1] with 2')
	UPDATE @XmlDocument
		SET Doc.modify('replace value of (/Transaction/Message[3]/@ReferenceNumber)[1] with 3')
	UPDATE @XmlDocument
		SET Doc.modify('replace value of (/Transaction/Message[4]/@ReferenceNumber)[1] with 4')
	UPDATE @XmlDocument
		SET Doc.modify('replace value of (/Transaction/Message[5]/@ReferenceNumber)[1] with 5')



--Remove Empty Elements from Party1

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/Name/Person/Title[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[1]/Name/Person/Title[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/Name/Person/Middle[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[1]/Name/Person/Middle[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/Name/Person/Suffix[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[1]/Name/Person/Suffix[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/OtherAgencyNumbers/OtherAgencyNumber[2]/AgencyNumber[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[1]/OtherAgencyNumbers/OtherAgencyNumber[2]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/Address/NonStandardUS/Line3[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[1]/Address/NonStandardUS/Line3[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/Address/NonStandardUS/Line2[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[1]/Address/NonStandardUS/Line2[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/Address/NonStandardUS/Line1[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[1]/Address/NonStandardUS/Line1[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/Address/NonStandardUS/City[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[1]/Address/NonStandardUS/City[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/Address/NonStandardUS/State[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[1]/Address/NonStandardUS/State[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/Address/NonStandardUS/Zip[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[1]/Address/NonStandardUS/Zip[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/Address/NonStandardUS[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('delete /Transaction/Message[1]/Address[1]')
		END
		
	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/Phones/Phone[3]/Number[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('delete /Transaction/Message[1]/Phones/Phone[3]')
		END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/Phones/Phone[2]/Number[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('delete /Transaction/Message[1]/Phones/Phone[2]')
		END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/Phones/Phone[1]/Number[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('delete /Transaction/Message[1]/Phones/Phone[1]')
		END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/Phones[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('delete /Transaction/Message[1]/Phones[1]')
		END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[1]/Email[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('delete /Transaction/Message[1]/Email[1]')
		END


--Remove Empty Elements from Party2

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/Name/Person/Title[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[2]/Name/Person/Title[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/Name/Person/Middle[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[2]/Name/Person/Middle[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/Name/Person/Suffix[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[2]/Name/Person/Suffix[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/OtherAgencyNumbers/OtherAgencyNumber[2]/AgencyNumber[1])[1]','nVarchar(50)'),'')	FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[2]/OtherAgencyNumbers/OtherAgencyNumber[2]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/Address/NonStandardUS/Line3[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[2]/Address/NonStandardUS/Line3[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/Address/NonStandardUS/Line2[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[2]/Address/NonStandardUS/Line2[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/Address/NonStandardUS/Line1[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[2]/Address/NonStandardUS/Line1[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/Address/NonStandardUS/City[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[2]/Address/NonStandardUS/City[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/Address/NonStandardUS/State[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[2]/Address/NonStandardUS/State[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/Address/NonStandardUS/Zip[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[2]/Address/NonStandardUS/Zip[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/Address/NonStandardUS[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[2]/Address[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/Phones/Phone[3]/Number[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('delete /Transaction/Message[2]/Phones/Phone[3]')
		END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/Phones/Phone[2]/Number[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('delete /Transaction/Message[2]/Phones/Phone[2]')
		END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/Phones/Phone[1]/Number[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('delete /Transaction/Message[2]/Phones/Phone[1]')
		END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/Phones[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('delete /Transaction/Message[2]/Phones[1]')
		END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[2]/Email[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('delete /Transaction/Message[2]/Email[1]')
		END

--Remove Empty Elements from Party3

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[3]/Address/NonStandardUS/Line3[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[3]/Address/NonStandardUS/Line3[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[3]/Address/NonStandardUS/Line2[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[3]/Address/NonStandardUS/Line2[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[3]/Address/NonStandardUS/Line1[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[3]/Address/NonStandardUS/Line1[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[3]/Address/NonStandardUS/City[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[3]/Address/NonStandardUS/City[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[3]/Address/NonStandardUS/State[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[3]/Address/NonStandardUS/State[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[3]/Address/NonStandardUS/Zip[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[3]/Address/NonStandardUS/Zip[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[3]/Address/NonStandardUS[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[3]/Address[1]')
	END

		IF (SELECT NULLIF(Doc.value('(/Transaction/Message[3]/Phones/Phone[1]/Number[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('delete /Transaction/Message[3]/Phones/Phone[1]')
		END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[3]/Phones[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('delete /Transaction/Message[3]/Phones[1]')
		END

--Remove Empty Elements from Party4

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[4]/Address/NonStandardUS/Line3[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[4]/Address/NonStandardUS/Line3[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[4]/Address/NonStandardUS/Line2[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[4]/Address/NonStandardUS/Line2[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[4]/Address/NonStandardUS/Line1[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[4]/Address/NonStandardUS/Line1[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[4]/Address/NonStandardUS/City[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[4]/Address/NonStandardUS/City[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[4]/Address/NonStandardUS/State[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[4]/Address/NonStandardUS/State[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[4]/Address/NonStandardUS/Zip[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[4]/Address/NonStandardUS/Zip[1]')
	END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[4]/Address/NonStandardUS[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
	BEGIN
	UPDATE @XmlDocument
		SET Doc.modify('delete /Transaction/Message[4]/Address[1]')
	END

		IF (SELECT NULLIF(Doc.value('(/Transaction/Message[4]/Phones/Phone[1]/Number[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('delete /Transaction/Message[4]/Phones/Phone[1]')
		END

	IF (SELECT NULLIF(Doc.value('(/Transaction/Message[4]/Phones[1])[1]','nVarchar(50)'),'') FROM @XmlDocument) IS NULL
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('delete /Transaction/Message[4]/Phones[1]')
		END

--Remove Degree if AOT

--	  SELECT 'Offense Code -- ',Doc.value('(/Transaction/Message[5]/Charges/Charge[1]/CaseFiling/Offense/Code)[1]','nVarchar(50)') FROM @XmlDocument

	IF (SELECT Doc.value('(/Transaction/Message[5]/Charges/Charge[1]/CaseFiling/Offense/Code)[1]','nVarchar(50)') FROM @XmlDocument) ='TRUANCY'
		BEGIN
		UPDATE @XmlDocument
			SET Doc.modify('replace value of (/Transaction/Message[5]/Charges/Charge[1]/CaseFiling/Offense/Degree/text())[1] with ("NONE")')

			--SET Salaries.modify('replace value of (/Salaries/Marketing/Employee[@ID=("2")]/Salary/text())[1] with ("60000")')
		
		END

INSERT INTO @DocTable (CaseDocumentID, CaseID, DocumentPath) 
SELECT CaseDocumentID,CaseID,DocumentPath FROM CaseDocument WHERE (CaseID=@CaseID)

WHILE (SELECT COUNT(CaseDocumentID) FROM @DocTable)>0
	BEGIN
		SELECT TOP 1 @CaseDocumentID=CaseDocumentID, @DocumentPath=DocumentPath FROM @DocTable
		
		SET @Command='xcopy /Y "'+@SourcePath+@DocumentPath+'" '+@DestinationPath
		
		--SELECT @Command
		
		EXEC xp_cmdShell @Command

		DELETE FROM @DocTable WHERE (CaseDocumentID=@CaseDocumentID)
	END

SELECT @OdysseyAPIMessage=Doc FROM @XmlDocument

	UPDATE OdysseyMessageTable
	SET OdysseyAPIMessage=@OdysseyAPIMessage
	WHERE (CaseID=@CaseID)
	
	SET @OdysseyAPIResponse=[TIS_Stage].[dbo].InvokeOdysseyAPI(CONVERT(NVARCHAR(MAX),@OdysseyAPIMessage),@CaseID)		

	UPDATE OdysseyMessageTable
	SET OdysseyAPIResponse=@OdysseyAPIResponse,
	ProcessedDT=CURRENT_TIMESTAMP
	WHERE (CaseID=@CaseID)		

	IF CHARINDEX('ERRORSTREAM',CONVERT(NVARCHAR(MAX),@OdysseyAPIResponse))=0
		BEGIN
			UPDATE Party
			SET ExternalPartyID=(SELECT OdysseyAPIResponse.value('(/TxnResponse/Result[1]/PartyID)[1]','nVarChar(50)') FROM OdysseyMessageTable WHERE (CaseID=@CaseID))
			WHERE (PartyID=@Party1ID)
			
			UPDATE Party
			SET ExternalPartyID=(SELECT OdysseyAPIResponse.value('(/TxnResponse/Result[2]/PartyID)[1]','nVarChar(50)') FROM OdysseyMessageTable WHERE (CaseID=@CaseID))
			WHERE (PartyID=@Party2ID)		
			
			Update [Case]
			SET CaseNumber=(SELECT OdysseyAPIResponse.value('(/TxnResponse/Result[5]/CaseNumber)[1]','nVarChar(50)') FROM OdysseyMessageTable WHERE (CaseID=@CaseID)), FilingStatusCD=9
			WHERE (CaseID=@CaseID)

			EXEC CaseEventInsertUpdate @CaseID=@CaseID,@CaseEventTypeID=9,@EventDate=@EventDate,@LastUserID=2
		
			SET @ErrFlg=0	
		END
	ELSE
		BEGIN
			UPDATE [Case]
			SET FilingStatusCD=8
			WHERE (CaseID=@CaseID)
			EXEC CaseEventInsertUpdate @CaseID=@CaseID,@CaseEventTypeID=8,@EventDate=@EventDate,@LastUserID=2
		END
	
END TRY
BEGIN CATCH
	UPDATE OdysseyMessageTable
	SET ErrorMessage=(SELECT 
	ERROR_NUMBER() AS ErrorNumber,
	ERROR_SEVERITY() AS ErrorSeverity,
	ERROR_STATE() AS ErrorState,
	ERROR_LINE() AS ErrorLine,
	ERROR_PROCEDURE() AS ErrorProcedure,
	ERROR_MESSAGE() AS ErrorMessage
FOR XML RAW('ProcessCaseError'))
WHERE (CaseID=@CaseID)
END CATCH
SET NOCOUNT OFF
GO


