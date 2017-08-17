select [FirstName], PublicStudentID,
  patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,[FirstName]) as [Position],
  substring([FirstName],patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,[FirstName]),1) as [InvalidCharacter],
  ascii(substring([FirstName],patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,[FirstName]),1)) as [ASCIICode]
from  portal.student
where patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,[FirstName]) >0

select [Lastname],PublicStudentID,
  patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,[Lastname]) as [Position],
  substring([Lastname],patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,[Lastname]),1) as [InvalidCharacter],
  ascii(substring([Lastname],patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,[Lastname]),1)) as [ASCIICode]
from  portal.student
where patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,[Lastname]) >0

select [Username],PublicStudentID,
  patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,[Username]) as [Position],
  substring([Username],patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,[Username]),1) as [InvalidCharacter],
  ascii(substring([Username],patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,[Username]),1)) as [ASCIICode]
from  portal.student
where patindex('%[^ !-~]%' COLLATE Latin1_General_BIN,[Username]) >0